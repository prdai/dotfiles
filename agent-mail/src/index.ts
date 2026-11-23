import PostalMime from "postal-mime";
import type { Address } from "postal-mime";
import { insertEmail } from "./db";
import { handleRequest } from "./http";
import type { Env } from "./env";
import type { EmailRecord } from "./types";

const MAX_RAW_BYTES = 5 * 1024 * 1024;
const MAX_BODY_CHARS = 200_000;

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    return handleRequest(request, env);
  },

  async email(message: ForwardableEmailMessage, env: Env): Promise<void> {
    const raw = await new Response(message.raw).arrayBuffer();

    if (raw.byteLength > MAX_RAW_BYTES) {
      await insertEmail(env.DB, skippedRecord(message));
      return;
    }

    const parsed = await PostalMime.parse(raw);
    await insertEmail(env.DB, {
      id: crypto.randomUUID(),
      receivedAt: Date.now(),
      from: addressOf(parsed.from) || message.from,
      to: addressOf(parsed.to?.[0]) || message.to,
      subject: parsed.subject ?? "",
      text: trimBody(parsed.text),
      html: trimBody(parsed.html),
      messageId: parsed.messageId ?? "",
      otp: parsed.otp?.code ?? "",
      truncated: isTruncated(parsed.text, parsed.html) ? 1 : 0,
    });
  },
} satisfies ExportedHandler<Env>;

function addressOf(address: Address | undefined): string {
  if (!address) return "";
  if ("group" in address) return address.group?.[0]?.address ?? "";
  return address.address ?? "";
}

function trimBody(value: string | undefined): string {
  if (!value) return "";
  return value.length > MAX_BODY_CHARS ? value.slice(0, MAX_BODY_CHARS) : value;
}

function isTruncated(text: string | undefined, html: string | undefined): boolean {
  return (text?.length ?? 0) > MAX_BODY_CHARS || (html?.length ?? 0) > MAX_BODY_CHARS;
}

function skippedRecord(message: ForwardableEmailMessage): EmailRecord {
  return {
    id: crypto.randomUUID(),
    receivedAt: Date.now(),
    from: message.from,
    to: message.to,
    subject: message.headers.get("subject") ?? "",
    text: "",
    html: "",
    messageId: "",
    otp: "",
    truncated: 1,
  };
}
