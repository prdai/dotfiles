# agent-mail

Receive-only inbox for `agent@prdai.dev`. Cloudflare Email Routing delivers mail to
a Worker, the Worker parses it with `postal-mime`, stores it in D1, and serves a
token-protected HTTP API for agents to read it.

Inbound mail is free and unlimited. Sending to arbitrary recipients needs the
Workers Paid plan, so this Worker only receives.

## Endpoints

All routes except `/health` require `Authorization: Bearer $API_TOKEN`.

| Route | Purpose |
|---|---|
| `GET /health` | liveness |
| `GET /emails` | list summaries, filters: `to`, `from`, `subject`, `q`, `since`, `limit` |
| `GET /emails/latest` | newest matching email with body, codes, links |
| `GET /emails/wait` | long-poll for a new email, `timeout` up to 25000 ms |
| `GET /emails/:id` | one email with body |
| `DELETE /emails/:id` | delete one email |
| `DELETE /emails?before=<ms>` | purge mail older than a unix millisecond timestamp |

`latest`, `wait`, and `:id` return `text`, `html`, `codes` (4 to 8 digit runs),
`links` (http/https), and `otp` (from an `OTP-Token` header when present).

Bodies are capped at 200k characters and messages over 5 MiB are stored as a
subject-only stub with `truncated: true`.

## Deploy

```bash
cd agent-mail
npm install

npx wrangler login
npx wrangler d1 create agent-mail
# replace database_id in wrangler.jsonc with the new one

npm run db:init
npx wrangler secret put API_TOKEN
npx wrangler deploy
```

The committed `wrangler.jsonc` already points at the live account and D1
database, so a redeploy only needs `npx wrangler deploy`.

`API_TOKEN` is any long random string, for example `openssl rand -hex 32`.

## Wire up Email Routing

1. Cloudflare dashboard, select the `prdai.dev` zone.
2. Compute > Email Service > Email Routing. Enable it. Enabling requires one
   verified destination address; a personal address already on the account
   works.
3. Routing rules > create a rule: custom address `agent@prdai.dev`, action
   `Send to a Worker`, Worker `agent-mail`.

Verify:

```bash
export AGENT_MAIL_URL="https://agent-mail.<subdomain>.workers.dev"
export AGENT_MAIL_TOKEN="<the secret>"
curl -sS -H "Authorization: Bearer $AGENT_MAIL_TOKEN" "$AGENT_MAIL_URL/health"
```

Then send a test message to `agent@prdai.dev` and read it back:

```bash
curl -sS -H "Authorization: Bearer $AGENT_MAIL_TOKEN" "$AGENT_MAIL_URL/emails/latest"
```

## Local development

```bash
npm run db:init:local
npx wrangler dev
```

Wrangler exposes `POST /cdn-cgi/local/email` to trigger the `email()` handler
locally. See the commit history in the Cloudflare docs for the payload shape.

## Storage and privacy

Mail sits in D1 until deleted. The inbox is shared, so every agent can read every
message. Purge after a flow finishes:

```bash
curl -sS -X DELETE -H "Authorization: Bearer $AGENT_MAIL_TOKEN" \
  "$AGENT_MAIL_URL/emails?before=$(date +%s%3N)"
```
