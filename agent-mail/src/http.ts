import { authorized } from "./auth";
import {
  deleteBefore,
  deleteEmail,
  getEmail,
  latestEmail,
  listEmails,
  waitForEmail,
} from "./db";
import { extractCodes, extractLinks, htmlToText } from "./extract";
import type { Env } from "./env";
import type { EmailFilters, EmailRecord } from "./types";

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 100;
const DEFAULT_WAIT_MS = 15_000;
const MAX_WAIT_MS = 25_000;

export async function handleRequest(request: Request, env: Env): Promise<Response> {
  const url = new URL(request.url);

  try {
    if (url.pathname === "/health") return json({ ok: true });
    if (!authorized(request, env.API_TOKEN)) return json({ error: "unauthorized" }, 401);

    return await route(request, url, env);
  } catch (error) {
    const message = error instanceof Error ? error.message : "internal error";
    return json({ error: message }, 500);
  }
}

async function route(request: Request, url: URL, env: Env): Promise<Response> {
  const parts = url.pathname.split("/").filter(Boolean);
  const id = parts[1] ?? "";
  if (parts[0] !== "emails") return json({ error: "not found" }, 404);

  if (request.method === "GET" && parts.length === 1) return listHandler(url, env);
  if (request.method === "GET" && id === "latest") return latestHandler(url, env);
  if (request.method === "GET" && id === "wait") return waitHandler(url, env);
  if (request.method === "GET" && parts.length === 2) return getHandler(id, env);
  if (request.method === "DELETE" && parts.length === 1) return purgeHandler(url, env);
  if (request.method === "DELETE" && parts.length === 2) return deleteHandler(id, env);

  return json({ error: "not found" }, 404);
}

async function listHandler(url: URL, env: Env): Promise<Response> {
  const emails = await listEmails(env.DB, parseFilters(url));
  return json({ count: emails.length, emails });
}

async function latestHandler(url: URL, env: Env): Promise<Response> {
  const email = await latestEmail(env.DB, parseFilters(url));
  if (!email) return json({ error: "no matching email" }, 404);

  return json({ email: present(email) });
}

async function waitHandler(url: URL, env: Env): Promise<Response> {
  const filters = parseFilters(url);
  const startedAt = Date.now();
  const timeoutMs = clamp(intParam(url.searchParams.get("timeout"), DEFAULT_WAIT_MS), 1_000, MAX_WAIT_MS);

  if (filters.since === undefined) filters.since = startedAt;

  const email = await waitForEmail(env.DB, filters, timeoutMs);
  return json({
    email: email ? present(email) : null,
    waitedMs: Date.now() - startedAt,
  });
}

async function getHandler(id: string, env: Env): Promise<Response> {
  const email = await getEmail(env.DB, id);
  if (!email) return json({ error: "not found" }, 404);

  return json({ email: present(email) });
}

async function deleteHandler(id: string, env: Env): Promise<Response> {
  const deleted = await deleteEmail(env.DB, id);
  if (!deleted) return json({ error: "not found" }, 404);

  return json({ deleted: true });
}

async function purgeHandler(url: URL, env: Env): Promise<Response> {
  const before = intParam(url.searchParams.get("before"), 0);
  if (before <= 0) {
    return json({ error: "before must be a positive unix millisecond timestamp" }, 400);
  }

  const deleted = await deleteBefore(env.DB, before);
  return json({ deleted });
}

function parseFilters(url: URL): EmailFilters {
  const params = url.searchParams;

  return {
    to: params.get("to") ?? undefined,
    from: params.get("from") ?? undefined,
    subject: params.get("subject") ?? undefined,
    since: params.has("since") ? intParam(params.get("since"), 0) : undefined,
    q: params.get("q") ?? undefined,
    limit: clamp(intParam(params.get("limit"), DEFAULT_LIMIT), 1, MAX_LIMIT),
  };
}

function present(email: EmailRecord) {
  const plainText = email.text || htmlToText(email.html);

  return {
    id: email.id,
    receivedAt: email.receivedAt,
    from: email.from,
    to: email.to,
    subject: email.subject,
    text: email.text,
    html: email.html,
    messageId: email.messageId,
    truncated: email.truncated === 1,
    otp: email.otp,
    codes: extractCodes(plainText),
    links: extractLinks(email.text, email.html),
  };
}

function intParam(value: string | null, fallback: number): number {
  const parsed = Number.parseInt(value ?? "", 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body, null, 2), {
    status,
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}
