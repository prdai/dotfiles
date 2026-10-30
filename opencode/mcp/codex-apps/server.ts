#!/usr/bin/env bun
const CODEX_APPS_SERVER = "codex_apps";
const CODEX_BIN = process.env.CODEX_BIN || "codex";
const CONNECTORS = parseList(process.env.CODEX_APPS_CONNECTORS);
const EXCLUDE = parseList(process.env.CODEX_APPS_EXCLUDE);
const READ_ONLY = process.env.CODEX_APPS_READ_ONLY === "1";
const LINK_OVERRIDES = parseJson(process.env.CODEX_APPS_LINKS, {});
const TOOL_TIMEOUT_MS = Number(process.env.CODEX_APPS_TIMEOUT_MS || 120000);

type JsonObject = Record<string, any>;
type CodexTool = {
  name: string;
  description?: string;
  title?: string;
  inputSchema?: JsonObject;
  annotations?: JsonObject;
  _meta?: JsonObject;
};
type CatalogEntry = {
  originalName: string;
  name: string;
  description: string;
  inputSchema: JsonObject;
  annotations?: JsonObject;
  hasLinkId: boolean;
  linkId?: string;
};

function parseList(value?: string): Set<string> | null {
  if (!value || value === "all") return null;
  return new Set(
    value
      .split(",")
      .map((item) => item.trim().toLowerCase())
      .filter(Boolean),
  );
}

function parseJson(value: string | undefined, fallback: JsonObject): JsonObject {
  if (!value) return fallback;
  try {
    return JSON.parse(value);
  } catch (error) {
    console.error(`codex-apps: invalid CODEX_APPS_LINKS: ${error}`);
    return fallback;
  }
}

async function forEachLine(
  stream: ReadableStream<Uint8Array>,
  onLine: (line: string) => void | Promise<void>,
) {
  const decoder = new TextDecoder();
  let buffer = "";
  for await (const chunk of stream) {
    buffer += decoder.decode(chunk, { stream: true });
    let index = buffer.indexOf("\n");
    while (index >= 0) {
      const line = buffer.slice(0, index);
      buffer = buffer.slice(index + 1);
      if (line.trim()) await onLine(line);
      index = buffer.indexOf("\n");
    }
  }
  if (buffer.trim()) await onLine(buffer);
}

function connectorSlug(tool: Pick<CodexTool, "name" | "_meta">): string {
  const name = tool._meta?.connector_name || tool.name.split(".")[0];
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_|_$/g, "");
}

function isReadOnly(tool: CodexTool): boolean {
  return tool.annotations?.readOnlyHint === true;
}

function included(tool: CodexTool): boolean {
  const slug = connectorSlug(tool);
  if (EXCLUDE && (EXCLUDE.has(slug) || EXCLUDE.has("*"))) return false;
  if (READ_ONLY && !isReadOnly(tool)) return false;
  if (!CONNECTORS) return true;
  return CONNECTORS.has(slug) || CONNECTORS.has(tool._meta?.connector_name?.toLowerCase());
}

class AppServer {
  private proc: ReturnType<typeof Bun.spawn> | null = null;
  private nextId = 1;
  private pending = new Map<
    number,
    { resolve: (value: any) => void; reject: (error: Error) => void; timer: Timer }
  >();
  private threadId: string | null = null;
  private catalog: Map<string, CatalogEntry> | null = null;

  async ensureStarted() {
    if (this.proc) return;
    const proc = Bun.spawn([CODEX_BIN, "app-server", "--stdio"], {
      stdin: "pipe",
      stdout: "pipe",
      stderr: "inherit",
    });
    this.proc = proc;

    void proc.exited.then((code) => {
      for (const { reject } of this.pending.values()) {
        reject(new Error(`codex app-server exited with code ${code}`));
      }
      this.pending.clear();
      this.proc = null;
    });

    void forEachLine(proc.stdout as ReadableStream<Uint8Array>, (line) =>
      this.handleLine(line),
    ).catch((error) => console.error(`codex-apps: app-server stream failed: ${error}`));
  }

  private handleLine(line: string) {
    let message: JsonObject;
    try {
      message = JSON.parse(line);
    } catch {
      console.error(`codex-apps: unparseable app-server line: ${line.slice(0, 200)}`);
      return;
    }
    if (message.id !== undefined && message.method) {
      this.write({
        jsonrpc: "2.0",
        id: message.id,
        error: { code: -32601, message: `unsupported app-server request: ${message.method}` },
      });
      return;
    }
    if (message.id !== undefined && this.pending.has(message.id)) {
      const { resolve, reject, timer } = this.pending.get(message.id)!;
      clearTimeout(timer);
      this.pending.delete(message.id);
      if (message.error) reject(new Error(message.error.message));
      else resolve(message.result);
    }
  }

  private write(message: JsonObject) {
    const stdin = this.proc?.stdin;
    if (!stdin) throw new Error("codex app-server is not running");
    stdin.write(`${JSON.stringify(message)}\n`);
    void stdin.flush();
  }

  rpc(method: string, params: JsonObject, timeoutMs = TOOL_TIMEOUT_MS): Promise<any> {
    return new Promise((resolve, reject) => {
      const id = this.nextId++;
      const timer = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`codex app-server timed out on ${method}`));
      }, timeoutMs);
      this.pending.set(id, { resolve, reject, timer });
      this.write({ jsonrpc: "2.0", id, method, params });
    });
  }

  async loadCatalog(): Promise<Map<string, CatalogEntry>> {
    if (this.catalog) return this.catalog;
    await this.ensureStarted();
    await this.rpc("initialize", {
      clientInfo: { name: "codex-apps-mcp", version: "0.1.0" },
      capabilities: { experimentalApi: true },
    });
    this.write({ jsonrpc: "2.0", method: "initialized" });

    const thread = await this.rpc("thread/start", {
      cwd: process.env.CODEX_APPS_CWD || process.cwd(),
      ephemeral: true,
      approvalPolicy: "never",
    });
    this.threadId = thread?.thread?.id ?? null;
    if (!this.threadId) throw new Error("codex app-server did not return a thread id");

    const listed = await this.rpc("mcpServerStatus/list", {});
    const server = (listed?.data || []).find(
      (item: JsonObject) => item.name === CODEX_APPS_SERVER,
    );
    if (!server) throw new Error(`codex app-server did not expose ${CODEX_APPS_SERVER}`);

    const catalog = new Map<string, CatalogEntry>();
    for (const tool of Object.values<CodexTool>(server.tools || {})) {
      if (!included(tool)) continue;
      catalog.set(tool.name, prepareTool(tool));
    }
    this.catalog = catalog;
    return catalog;
  }

  async callTool(name: string, args?: JsonObject) {
    const catalog = await this.loadCatalog();
    const entry = catalog.get(name);
    if (!entry) throw new Error(`unknown tool: ${name}`);
    const toolArgs = { ...(args || {}) };
    if (entry.hasLinkId && toolArgs.link_id == null && entry.linkId) {
      toolArgs.link_id = entry.linkId;
    }
    const result = await this.rpc("mcpServer/tool/call", {
      server: CODEX_APPS_SERVER,
      threadId: this.threadId,
      tool: entry.originalName,
      arguments: toolArgs,
    });
    return {
      content: result?.content || [],
      isError: result?.isError === true,
      ...(result?.structuredContent !== undefined
        ? { structuredContent: result.structuredContent }
        : {}),
    };
  }

  stop() {
    this.proc?.kill();
  }
}

function prepareTool(tool: CodexTool): CatalogEntry {
  const schema = structuredClone(tool.inputSchema || { type: "object", properties: {} });
  const hasLinkId = Boolean(schema.properties?.link_id);
  if (hasLinkId && Array.isArray(schema.required)) {
    schema.required = schema.required.filter((key: string) => key !== "link_id");
  }
  const key = connectorSlug(tool);
  return {
    originalName: tool.name,
    name: tool.name,
    description: tool.description || tool.title || tool.name,
    inputSchema: schema,
    annotations: tool.annotations,
    hasLinkId,
    linkId: LINK_OVERRIDES[key] || tool._meta?.link_id,
  };
}

function exposeTool(entry: CatalogEntry) {
  return {
    name: entry.name,
    description: entry.description,
    inputSchema: entry.inputSchema,
    ...(entry.annotations ? { annotations: entry.annotations } : {}),
  };
}

const app = new AppServer();

function send(message: JsonObject) {
  process.stdout.write(`${JSON.stringify(message)}\n`);
}

function reply(id: any, result: JsonObject) {
  send({ jsonrpc: "2.0", id, result });
}

function replyError(id: any, code: number, message: string) {
  send({ jsonrpc: "2.0", id, error: { code, message } });
}

async function handle(request: JsonObject) {
  const { id, method, params } = request;
  if (method === "initialize") {
    reply(id, {
      protocolVersion: params?.protocolVersion || "2025-06-18",
      capabilities: { tools: {} },
      serverInfo: { name: "codex-apps", version: "0.1.0" },
    });
    return;
  }
  if (method === "ping") {
    reply(id, {});
    return;
  }
  if (method === "tools/list") {
    const catalog = await app.loadCatalog();
    reply(id, { tools: Array.from(catalog.values(), exposeTool) });
    return;
  }
  if (method === "tools/call") {
    reply(id, await app.callTool(params?.name, params?.arguments));
    return;
  }
  if (method === "resources/list") {
    reply(id, { resources: [] });
    return;
  }
  if (method === "prompts/list") {
    reply(id, { prompts: [] });
    return;
  }
  if (id !== undefined) replyError(id, -32601, `method not found: ${method}`);
}

async function main() {
  if (process.argv.includes("--list")) {
    const catalog = await app.loadCatalog();
    const counts = new Map<string, number>();
    for (const entry of catalog.values()) {
      const key = entry.originalName.split(".")[0];
      counts.set(key, (counts.get(key) || 0) + 1);
    }
    console.error(`codex-apps: ${catalog.size} tools`);
    for (const [key, count] of [...counts].sort()) console.error(`  ${key}: ${count}`);
    app.stop();
    return;
  }

  for (const signal of ["SIGINT", "SIGTERM"] as const) {
    process.on(signal, () => {
      app.stop();
      process.exit(0);
    });
  }

  await forEachLine(Bun.stdin.stream(), async (line) => {
    let request: JsonObject;
    try {
      request = JSON.parse(line);
    } catch {
      replyError(null, -32700, "parse error");
      return;
    }
    if (request.id === undefined) return;
    try {
      await handle(request);
    } catch (error) {
      replyError(request.id, -32603, error instanceof Error ? error.message : String(error));
    }
  });
}

await main();
