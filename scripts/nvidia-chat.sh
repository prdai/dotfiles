#!/usr/bin/env bash
# Call an NVIDIA hosted NIM model. Prompt is read from stdin.
#
# Usage: nvidia-chat.sh <model> [max_tokens]
# Env:   NVIDIA_API_KEY (required), NVIDIA_BASE_URL (optional)
set -euo pipefail

model="${1:?usage: nvidia-chat.sh <model> [max_tokens]}"
max_tokens="${2:-1024}"
base="${NVIDIA_BASE_URL:-https://integrate.api.nvidia.com/v1}"

: "${NVIDIA_API_KEY:?NVIDIA_API_KEY is not set; copy .env.example to .env in ~/.dotfiles}"

prompt="$(cat)"
payload=$(jq -n --arg m "$model" --arg p "$prompt" --argjson t "$max_tokens" \
  '{model: $m, messages: [{role: "user", content: $p}], max_tokens: $t, temperature: 0}')

resp=$(curl -sS --fail-with-body -m 300 "$base/chat/completions" \
  -H "Authorization: Bearer $NVIDIA_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$payload") || { echo "$resp" >&2; exit 1; }

echo "$resp" | jq -r '.choices[0].message.content // .choices[0].message.reasoning_content // empty'
