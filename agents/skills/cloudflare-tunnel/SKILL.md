---
name: cloudflare-tunnel
description: Exposes a local HTTP port on a public HTTPS URL with cloudflared. Quick tunnels for temporary previews, named tunnels for stable hostnames, custom domains, and access control. Use when asked to port forward, share a localhost dev server, create a tunnel, expose a port publicly, or put a custom domain in front of local work.
---

# Cloudflare Tunnel

Give a local server a public HTTPS URL without opening an inbound port. Use the
quick start for a temporary look, a named tunnel for anything that must keep its
address.

## Pick the mode

| | Quick tunnel | Named tunnel |
|---|---|---|
| Account or domain | neither | Cloudflare account plus a zone |
| URL | random `trycloudflare.com`, changes every start | stable, on your own hostname |
| Access control | `--allowed-mail` only | Cloudflare Access (email, SSO, service tokens) |
| Long-lived? | no | yes |
| Limits | 200 in-flight requests, no SSE | 1,000 tunnels/account, 25 replicas/tunnel |
| Use for | demos, webhooks, a shared preview | staging, persistent demos, custom domains |

Default to a quick tunnel for a short-lived share. Switch to a named tunnel when
the user asks for a custom domain, a stable URL, SSE streaming, or access
control.

## Before exposing anything

- The whole service becomes reachable to anyone with the URL. Confirm with the
  user before exposing anything beyond loopback.
- Never expose a database, an admin surface, or a service holding real
  credentials without a named tunnel behind Access. A login page is not a
  substitute for network access control.
- Prefer the built application over a development server. `next dev` exposes
  source maps and the dev overlay, and quick tunnels do not officially support
  SSE, which breaks streamed responses and hot reload.
- Stop the tunnel when the task ends unless the user asked to keep it. A quick
  tunnel ends with its process.

## Quick start

Use the bundled script; it starts `cloudflared`, waits for the URL, verifies it,
and records the PID and log.

```bash
agents/skills/cloudflare-tunnel/scripts/quick-tunnel.sh --port 3001
agents/skills/cloudflare-tunnel/scripts/quick-tunnel.sh --port 3001 --allowed-mail alice@example.com
agents/skills/cloudflare-tunnel/scripts/quick-tunnel.sh --port 3001 --stop
```

Equivalent manual command when the script is unavailable:

```bash
cloudflared tunnel --url http://localhost:3001 --no-autoupdate
```

Read the `https://<words>.trycloudflare.com` line from the output. Keep the
process in the background and save its PID and log path, for example under
`${XDG_CACHE_HOME:-$HOME/.cache}/cloudflare-tunnel/`. Verify before sharing:

```bash
curl -sS -o /dev/null -w '%{http_code}\n' https://<host>/health
```

Quick tunnels need no login. If `cloudflared` is missing, install the release
binary into `~/.local/bin` rather than requiring root:

```bash
case "$(uname -m)" in
  x86_64) arch=amd64 ;;
  aarch64 | arm64) arch=arm64 ;;
  armv7l) arch=arm ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac
mkdir -p ~/.local/bin
curl -fL -o ~/.local/bin/cloudflared \
  "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${arch}"
chmod +x ~/.local/bin/cloudflared
~/.local/bin/cloudflared --version
```

## Named tunnel with a custom domain

The hostname must belong to a zone in the same Cloudflare account.

```bash
cloudflared tunnel login
cloudflared tunnel create hybrid-chat
cloudflared tunnel route dns hybrid-chat chat.example.com
cloudflared tunnel run hybrid-chat
```

For more than one hostname, or to keep the tunnel configuration in the repo,
create `~/.cloudflared/config.yml`:

```yaml
tunnel: <tunnel-uuid>
credentials-file: /home/<user>/.cloudflared/<tunnel-uuid>.json

ingress:
  - hostname: chat.example.com
    service: http://localhost:3001
  - hostname: api.example.com
    service: http://localhost:8080
  - service: http_status:404
```

Protect it in Zero Trust: Access, Applications, Add a self-hosted application,
choose the hostname, add a policy such as `Emails` or an identity provider. For
automation, use a service token instead of an interactive session.

Run at least two connectors (replicas) for a tunnel that must survive a host
restart. All replicas share the tunnel ID and its published services.

## Limits

- Quick tunnels: no uptime guarantee, 200 in-flight requests, no SSE support,
  hostname changes on each start.
- Named tunnels: 1,000 per account included; beyond that, Tunnels for Platforms
  adds capacity at $4.50 per tunnel per month. 25 active replicas per tunnel,
  50,000 routes per account, published hostnames bounded by the 1 MB tunnel
  configuration.

## Troubleshooting

- `1033` or `502`: the origin is down, the service URL is wrong, or no connector
  is connected. Check the tunnel status and that the local port answers.
- Streaming stalls or reloads never finish: quick tunnels do not support SSE.
  Use a named tunnel or the built app.
- Cross-origin dev requests are blocked by Next.js: add the tunnel host to
  `allowedDevOrigins`, or use the production build.
- Public HTTPS does not make app cookies `Secure`; that is set by the
  application. Do not treat the tunnel's TLS as application hardening.
- A quick tunnel URL stops working when the process exits. If the URL is gone,
  start a new tunnel and share the new address.
