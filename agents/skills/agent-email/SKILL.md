---
name: agent-email
description: Read and act on the shared agent inbox agent@prdai.dev, served by a self-hosted DearAgent instance on Cloudflare. Use when a task needs an email verification link or code, when signing up for a service as the agent, when asked to check the agent inbox, or when reading mail sent to agent@prdai.dev.
---

# Agent Email

`agent@prdai.dev` is a real inbox served by a self-hosted DearAgent deployment
(`prdai-archive/dearagent`) on the operator's Cloudflare account. Cloudflare
Email Routing delivers mail to the Worker, which stores it in D1 and exposes a
REST API plus an MCP endpoint.

The deployment is pinned to one address. Only local parts matching `^agent$` are
accepted, other mail at `prdai.dev` is rejected, and mail is kept for 7 days.
Receiving is free. Sending needs a paid Workers plan and is not relied on here.

## Before use

The wrapper resolves configuration on its own. `DEARAGENT_URL` defaults to
`https://dearagent.prdai.dev`. The key comes from `DEARAGENT_API_KEY`,
else `~/.config/dearagent/token`, else the repo `.env`.

If no key exists anywhere, do not stop and ask. Generate one, install it as the
Worker secret, and persist it:

```bash
KEY="da_$(openssl rand -hex 24)"
cd ~/Storage/projects/dearagent
printf '%s' "$KEY" | npx wrangler secret put API_KEY
mkdir -p ~/.config/dearagent
printf '%s' "$KEY" > ~/.config/dearagent/token
chmod 600 ~/.config/dearagent/token
```

That rotates the shared key, so other holders must pick up the new value. If
`wrangler` is not authenticated, run `npx wrangler login` first; no chat round
trip is needed.

Never bypass auth. Every request must carry the bearer key and the Worker
rejects anything else; a made-up key will just return 401.

## Endpoints

| Call | Purpose |
|---|---|
| `dearagent list limit=10` | newest messages, body omitted |
| `dearagent latest since=<ms>` | newest message newer than `since` |
| `dearagent wait since=<ms> timeout=25` | block until a newer message arrives |
| `dearagent get <id>` | one message with body and attachments |
| `dearagent delete <id>` | delete one message |
| `dearagent health` | liveness |

`since` is unix milliseconds. `timeout` is seconds, max 25. `list` also takes
`from`, `unread`, `has_attachment`, `include_body`, and `limit`.

Wrapper script:
`agents/skills/agent-email/scripts/dearagent.sh`.

Equivalent curl:

```bash
curl -sS -H "Authorization: Bearer $DEARAGENT_API_KEY" \
  "$DEARAGENT_URL/inboxes/agent%40prdai.dev/messages/wait?since=$(date +%s%3N)&timeout=25"
```

`wait` returns `{ message, timed_out }`. `timed_out: true` with `message: null`
is a timeout, not an error; call it again with the same `since`. `latest` returns
404 when nothing is newer than `since`.

The same server exposes MCP at `${DEARAGENT_URL}/mcp` with the same bearer
header, if the client supports MCP.

## The verification loop

1. Confirm the target service and what the account is for. Accounts on
   `agent@prdai.dev` are pre-authorized; do not ask before creating them.
2. Record `since` before submitting the form: `date +%s%3N`. Every later query
   uses it so stale mail cannot be mistaken for the new message.
3. Fill the form with `agent@prdai.dev` using the built-in browser or preview
   tools, then submit.
4. Wait for the message:

   ```bash
   dearagent wait since=<ms> timeout=25 | jq '.message | {subject, from, text, html}'
   ```

   Retry with the same `since` if it times out.
5. Read it. Many senders send HTML only, so `text` can be empty; when it is, read
   `html` and extract the link from the anchor whose text mentions confirming or
   verifying. Never pick tracking, unsubscribe, or preference links.
6. Open the link in the same browser session that submitted the form. Many
   services tie the link to the session cookie, so fetching it with curl does not
   confirm the account in the browser.
7. Confirm the account works, then delete the message or rely on the 7-day
   retention.

## Rules

- The inbox is shared and every agent can read every message. Never treat all
  mail as belonging to the current task; filter by `since` and sender or subject.
- Create accounts with `agent@prdai.dev` without asking; it is the dedicated
  agent identity. Never use the user's personal address. Skip financial,
  government, and identity/KYC accounts, payment details, and phone or SMS
  verification, and report those as blockers.
- Never commit, log, or paste message bodies, keys, or verification links into
  files, commits, or public text. Read them from the API at use time.
- Verification links expire and are single use. Do not reuse an old one; trigger
  a new email instead.
- A service may rate-limit repeated signups or require a CAPTCHA. Report the
  blocker instead of retrying in a loop.
- Delete sensitive mail after use: `dearagent delete <id>`.

## Troubleshooting

- 401: `DEARAGENT_API_KEY` is missing or wrong.
- 404 from `latest`: no mail newer than `since` yet.
- Empty `text`: read `html` instead.
- Mail never arrives: check that Email Routing sends `agent@prdai.dev` to the
  `dearagent` Worker and that the Worker is deployed. See `prdai-archive/dearagent`.
