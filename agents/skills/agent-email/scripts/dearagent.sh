#!/usr/bin/env bash
set -euo pipefail

: "${DEARAGENT_URL:=https://dearagent.prdai.workers.dev}"

if [[ -z "${DEARAGENT_API_KEY:-}" && -r "${HOME}/.config/dearagent/token" ]]; then
  DEARAGENT_API_KEY="$(tr -d '\r\n' < "${HOME}/.config/dearagent/token")"
fi

if [[ -z "${DEARAGENT_API_KEY:-}" ]]; then
  printf 'missing DEARAGENT_API_KEY and ~/.config/dearagent/token; install one with: wrangler secret put API_KEY\n' >&2
  exit 1
fi

base="${DEARAGENT_URL%/}"
inbox="agent%40prdai.dev"
cmd="${1:-list}"
shift || true

auth=(-H "Authorization: Bearer ${DEARAGENT_API_KEY}")

case "$cmd" in
  list) curl -fsS "${auth[@]}" "${base}/inboxes/${inbox}/messages?$*" ;;
  latest) curl -fsS "${auth[@]}" "${base}/inboxes/${inbox}/messages/latest?$*" ;;
  wait) curl -fsS "${auth[@]}" "${base}/inboxes/${inbox}/messages/wait?$*" ;;
  get) curl -fsS "${auth[@]}" "${base}/inboxes/${inbox}/messages/${1:?usage: dearagent get <id>}" ;;
  delete) curl -fsS -X DELETE "${auth[@]}" "${base}/inboxes/${inbox}/messages/${1:?usage: dearagent delete <id>}" ;;
  health) curl -fsS "${base}/health" ;;
  *)
    printf 'usage: dearagent <list|latest|wait|get|delete|health> [query]\n' >&2
    exit 2
    ;;
esac
