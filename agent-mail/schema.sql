CREATE TABLE IF NOT EXISTS emails (
  id TEXT PRIMARY KEY,
  received_at INTEGER NOT NULL,
  from_addr TEXT NOT NULL,
  to_addr TEXT NOT NULL,
  subject TEXT NOT NULL DEFAULT '',
  text_body TEXT NOT NULL DEFAULT '',
  html_body TEXT NOT NULL DEFAULT '',
  message_id TEXT NOT NULL DEFAULT '',
  otp TEXT NOT NULL DEFAULT '',
  truncated INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS emails_received_at ON emails (received_at DESC);
CREATE INDEX IF NOT EXISTS emails_to_addr ON emails (to_addr, received_at DESC);
