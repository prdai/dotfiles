import type { EmailFilters, EmailRecord, EmailRow, EmailSummary } from "./types";

const WAIT_INTERVAL_MS = 2_000;

export async function insertEmail(db: D1Database, record: EmailRecord): Promise<void> {
  await db
    .prepare(
      `INSERT INTO emails (id, received_at, from_addr, to_addr, subject, text_body, html_body, message_id, otp, truncated)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    )
    .bind(
      record.id,
      record.receivedAt,
      record.from,
      record.to,
      record.subject,
      record.text,
      record.html,
      record.messageId,
      record.otp,
      record.truncated,
    )
    .run();
}

export async function listEmails(db: D1Database, filters: EmailFilters): Promise<EmailSummary[]> {
  const { clause, params } = filterClause(filters);
  const { results } = await db
    .prepare(
      `SELECT id, received_at, from_addr, to_addr, subject, truncated
       FROM emails ${clause} ORDER BY received_at DESC LIMIT ?`,
    )
    .bind(...params, filters.limit)
    .all<EmailRow>();

  return results.map(toSummary);
}

export async function latestEmail(db: D1Database, filters: EmailFilters): Promise<EmailRecord | null> {
  const { clause, params } = filterClause(filters);
  const row = await db
    .prepare(`SELECT * FROM emails ${clause} ORDER BY received_at DESC LIMIT 1`)
    .bind(...params)
    .first<EmailRow>();

  return row ? toRecord(row) : null;
}

export async function getEmail(db: D1Database, id: string): Promise<EmailRecord | null> {
  const row = await db.prepare(`SELECT * FROM emails WHERE id = ?`).bind(id).first<EmailRow>();
  return row ? toRecord(row) : null;
}

export async function waitForEmail(
  db: D1Database,
  filters: EmailFilters,
  timeoutMs: number,
): Promise<EmailRecord | null> {
  const deadline = Date.now() + timeoutMs;

  while (true) {
    const email = await latestEmail(db, filters);
    if (email) return email;
    if (Date.now() >= deadline) return null;

    await new Promise((resolve) => setTimeout(resolve, WAIT_INTERVAL_MS));
  }
}

export async function deleteEmail(db: D1Database, id: string): Promise<boolean> {
  const result = await db.prepare(`DELETE FROM emails WHERE id = ?`).bind(id).run();
  return (result.meta.changes ?? 0) > 0;
}

export async function deleteBefore(db: D1Database, receivedBefore: number): Promise<number> {
  const result = await db
    .prepare(`DELETE FROM emails WHERE received_at < ?`)
    .bind(receivedBefore)
    .run();

  return result.meta.changes ?? 0;
}

function filterClause(filters: EmailFilters): { clause: string; params: unknown[] } {
  const clauses: string[] = [];
  const params: unknown[] = [];

  if (filters.to) {
    clauses.push("to_addr = ?");
    params.push(filters.to.toLowerCase());
  }
  if (filters.from) {
    clauses.push("from_addr LIKE ?");
    params.push(`%${filters.from}%`);
  }
  if (filters.subject) {
    clauses.push("subject LIKE ?");
    params.push(`%${filters.subject}%`);
  }
  if (filters.since !== undefined) {
    clauses.push("received_at >= ?");
    params.push(filters.since);
  }
  if (filters.q) {
    clauses.push("(subject LIKE ? OR text_body LIKE ?)");
    params.push(`%${filters.q}%`, `%${filters.q}%`);
  }

  return {
    clause: clauses.length > 0 ? `WHERE ${clauses.join(" AND ")}` : "",
    params,
  };
}

function toSummary(row: EmailRow): EmailSummary {
  return {
    id: row.id,
    receivedAt: row.received_at,
    from: row.from_addr,
    to: row.to_addr,
    subject: row.subject,
    truncated: row.truncated === 1,
  };
}

function toRecord(row: EmailRow): EmailRecord {
  return {
    id: row.id,
    receivedAt: row.received_at,
    from: row.from_addr,
    to: row.to_addr,
    subject: row.subject,
    text: row.text_body,
    html: row.html_body,
    messageId: row.message_id,
    otp: row.otp,
    truncated: row.truncated,
  };
}
