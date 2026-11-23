#!/usr/bin/env bash
set -euo pipefail

: "${AGENT_MAIL_URL:?set AGENT_MAIL_URL to the agent-mail worker base URL}"
: "${AGENT_MAIL_TOKEN:?set AGENT_MAIL_TOKEN to the worker API token}"

base="${AGENT_MAIL_URL%/}"
cmd="${1:-list}"
shift || true

auth=(-H "Authorization: Bearer ${AGENT_MAIL_TOKEN}")

case "$cmd" in
  list) curl -fsS "${auth[@]}" "${base}/emails?$*" ;;
  latest) curl -fsS "${auth[@]}" "${base}/emails/latest?$*" ;;
  wait) curl -fsS "${auth[@]}" "${base}/emails/wait?$*" ;;
  get) curl -fsS "${auth[@]}" "${base}/emails/${1:?usage: agent-mail get <id>}" ;;
  purge) curl -fsS -X DELETE "${auth[@]}" "${base}/emails?$*" ;;
  health) curl -fsS "${base}/health" ;;
  *)
    printf 'usage: agent-mail <list|latest|wait|get|purge|health> [query]\n' >&2
    exit 2
    ;;
esac
