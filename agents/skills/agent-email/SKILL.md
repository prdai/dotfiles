---
name: agent-email
description: Read the shared agent inbox at agent@prdai.dev through its HTTP API to finish signups, confirmations, password resets, magic links, and OTP flows. Use when a task needs an email verification link or code, when signing up for a service as the agent, when asked to check the agent inbox, or when reading mail sent to agent@prdai.dev.
---

# Agent Email

`agent@prdai.dev` receives mail through Cloudflare Email Routing into a Worker
that stores it in D1 and exposes a token-protected HTTP API. Use it to complete
flows that need a real mailbox: account signup, email confirmation, password
reset, magic links, invite acceptance, one-time codes.

Receive only. Outbound mail to arbitrary recipients needs the Workers Paid plan,
so do not promise to send mail. The Worker and its setup live in `agent-mail/`.

## Before use

The environment must provide:

- `AGENT_MAIL_URL`: worker base URL, no trailing slash.
- `AGENT_MAIL_TOKEN`: bearer token for the API.

Both are required by the bundled script. Verbatim curl works too.

```bash
export AGENT_MAIL_URL="https://agent-mail.example.workers.dev"
export AGENT_MAIL_TOKEN="..."
```

If either is missing, stop and ask the user; do not guess a URL.

## Endpoints

| Call | Purpose |
|---|---|
| `agent-mail list limit=10` | newest summaries, no bodies |
| `agent-mail latest subject=verify` | newest match with body, codes, links |
| `agent-mail wait since=<ms> subject=verify timeout=20000` | block until a new match |
| `agent-mail get <id>` | one message by id |
| `agent-mail purge before=<ms>` | delete mail older than a timestamp |
| `agent-mail health` | liveness |

Filters on `list`, `latest`, and `wait`: `to`, `from`, `subject`, `q`, `since`
(unix ms, inclusive), `limit` (default 20, max 100). `wait` also takes `timeout`
in ms, max 25000.

Script path: `agents/skills/agent-email/scripts/agent-mail.sh`.

Equivalent curl:

```bash
curl -sS -H "Authorization: Bearer $AGENT_MAIL_TOKEN" \
  "$AGENT_MAIL_URL/emails/wait?since=$(date +%s%3N)&timeout=20000&subject=verify"
```

Details come back as `email` with `text`, `html`, `codes` (4 to 8 digit runs),
`links` (http/https URLs), and `otp` (from an `OTP-Token` header when present).

## The verification loop

1. Confirm the target service and the address the user approved. The inbox is
   shared, so state which flow the mail belongs to.
2. Record `since` before submitting the form: `date +%s%3N`. Every later query
   uses it so a stale message cannot be mistaken for the new one.
3. Fill the signup form with `agent@prdai.dev` using the built-in browser or
   preview tools, then submit.
4. Wait for the message, filtered by `since` and a narrow `subject` or `from`:

   ```bash
   agent-mail wait since=<ms> subject=verify timeout=20000 | jq '.email'
   ```

   A 200 response with `"email": null` means the timeout elapsed, not an error.
   Retry once or twice, then check spam-like senders with `agent-mail list
   since=<ms>`.
5. Prefer `email.otp` and `email.codes` for a code field. For a link, use
   `email.links` and pick the URL on the service's own domain, not tracking or
   unsubscribe links.
6. Open the verification link in the same browser session that submitted the
   form. Many services tie the link to the session cookie. Do not fetch the link
   with curl and expect the account to be confirmed in the browser.
7. Confirm the account now works, then purge the flow's mail if the user asked
   for cleanup.

## Rules

- The inbox is shared and every agent can read every message. Never treat all
  mail as belonging to the current task; always filter by `since` and sender or
  subject.
- Only create accounts the user authorized. Confirm before submitting personal
  data, payment details, or anything that accepts terms on the user's behalf.
- Never commit, log, or paste message bodies, tokens, or verification links into
  files, commits, or public text. Read them from the API at use time.
- Verification links expire and are single use. Do not re-open an old one; issue
  a new email instead.
- A service may rate-limit repeated signups or require a CAPTCHA. Report the
  blocker instead of retrying in a loop.
- Purge after sensitive flows: `agent-mail purge before=$(date +%s%3N)`.

## Troubleshooting

- 401: `AGENT_MAIL_TOKEN` is missing or wrong.
- 404 on `latest`: no mail matches the filters yet.
- `truncated: true` with a large message: the body exceeded the 200k character
  cap or the message exceeded 5 MiB. Use `links` and `codes`, which still work.
- Mail never arrives: check that the routing rule sends `agent@prdai.dev` to the
  `agent-mail` Worker and that the Worker is deployed. See `agent-mail/README.md`.
