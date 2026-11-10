#!/usr/bin/env bash
# Start or stop a Cloudflare quick tunnel for one local port.
#
# The URL and the process live only as long as cloudflared runs. For a stable
# hostname, a custom domain, or SSE, use a named tunnel instead (see SKILL.md).
set -euo pipefail

PORT=3000
TARGET_URL=""
ALLOWED_MAIL=()
STOP=0
WAIT_SECONDS=30

usage() {
  cat <<'EOF'
Usage: quick-tunnel.sh [options]

  --port N               local port to expose (default: 3000)
  --url URL              full local URL instead of --port
  --allowed-mail ADDR    require email OTP for this address (repeatable)
  --stop                 stop the tunnel started for this port and exit
  --wait SECONDS         how long to wait for the public URL (default: 30)
  -h, --help             show this help

Examples:
  quick-tunnel.sh --port 3001
  quick-tunnel.sh --port 3001 --allowed-mail alice@example.com
  quick-tunnel.sh --port 3001 --stop
EOF
}

die() {
  echo "quick-tunnel: $*" >&2
  exit 1
}

while [ $# -gt 0 ]; do
  case "$1" in
    --port)
      [ $# -ge 2 ] || die "--port needs a value"
      PORT="$2"
      shift 2
      ;;
    --url)
      [ $# -ge 2 ] || die "--url needs a value"
      TARGET_URL="$2"
      shift 2
      ;;
    --allowed-mail)
      [ $# -ge 2 ] || die "--allowed-mail needs a value"
      ALLOWED_MAIL+=("$2")
      shift 2
      ;;
    --stop)
      STOP=1
      shift
      ;;
    --wait)
      [ $# -ge 2 ] || die "--wait needs a value"
      WAIT_SECONDS="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

case "$PORT" in
  '' | *[!0-9]*) die "port must be a number" ;;
esac
[ "$PORT" -ge 1 ] && [ "$PORT" -le 65535 ] || die "port must be between 1 and 65535"

if [ -z "$TARGET_URL" ]; then
  TARGET_URL="http://localhost:${PORT}"
fi
case "$TARGET_URL" in
  http://* | https://*) ;;
  *) die "--url must start with http:// or https://" ;;
esac

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cloudflare-tunnel"
mkdir -p "$STATE_DIR"
LOG_FILE="$STATE_DIR/${PORT}.log"
PID_FILE="$STATE_DIR/${PORT}.pid"

running() {
  [ -f "$PID_FILE" ] || return 1
  local pid
  pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

public_url() {
  grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' "$LOG_FILE" 2>/dev/null | head -n 1
}

if [ "$STOP" -eq 1 ]; then
  if ! running; then
    rm -f "$PID_FILE"
    echo "No tunnel is running for port ${PORT}."
    exit 0
  fi
  pid="$(cat "$PID_FILE")"
  kill "$pid" 2>/dev/null || true
  for _ in $(seq 1 30); do
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.5
  done
  kill -9 "$pid" 2>/dev/null || true
  rm -f "$PID_FILE"
  echo "Stopped the tunnel for port ${PORT} (pid ${pid})."
  exit 0
fi

if running; then
  url="$(public_url || true)"
  echo "A tunnel is already running for port ${PORT} (pid $(cat "$PID_FILE"))."
  [ -n "$url" ] && echo "URL: ${url}"
  echo "Log: ${LOG_FILE}"
  exit 0
fi

BIN="${CLOUDFLARED:-}"
if [ -z "$BIN" ]; then
  if command -v cloudflared >/dev/null 2>&1; then
    BIN="$(command -v cloudflared)"
  elif [ -x "$HOME/.local/bin/cloudflared" ]; then
    BIN="$HOME/.local/bin/cloudflared"
  else
    die "cloudflared not found. Install it first (see SKILL.md)."
  fi
fi

command -v curl >/dev/null 2>&1 || die "curl is required for the URL check"

args=(tunnel --url "$TARGET_URL" --no-autoupdate)
for address in "${ALLOWED_MAIL[@]}"; do
  args+=(--allowed-mail "$address")
done

: >"$LOG_FILE"
if command -v setsid >/dev/null 2>&1; then
  setsid "$BIN" "${args[@]}" >"$LOG_FILE" 2>&1 </dev/null &
else
  nohup "$BIN" "${args[@]}" >"$LOG_FILE" 2>&1 </dev/null &
fi
pid=$!
echo "$pid" >"$PID_FILE"

url=""
tries=$((WAIT_SECONDS * 4))
for _ in $(seq 1 "$tries"); do
  if ! kill -0 "$pid" 2>/dev/null; then
    echo "cloudflared exited before publishing a URL. Log:" >&2
    tail -n 20 "$LOG_FILE" >&2 || true
    rm -f "$PID_FILE"
    exit 1
  fi
  url="$(public_url || true)"
  [ -n "$url" ] && break
  sleep 0.25
done

if [ -z "$url" ]; then
  echo "No public URL after ${WAIT_SECONDS}s. cloudflared is still running (pid ${pid})." >&2
  echo "Log: ${LOG_FILE}" >&2
  exit 1
fi

status=""
for _ in $(seq 1 30); do
  status="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 5 "$url" 2>/dev/null || true)"
  [ -n "$status" ] && [ "$status" != "000" ] && break
  sleep 1
done
echo "URL:  ${url}"
echo "Port: ${PORT}"
echo "PID:  ${pid}"
echo "Log:  ${LOG_FILE}"
if [ -n "$status" ] && [ "$status" != "000" ]; then
  echo "HTTP: ${status} from the tunnel root"
else
  echo "HTTP: could not reach the tunnel yet; check the local service and the log" >&2
fi
echo "Stop: $(basename "$0") --port ${PORT} --stop"
