#!/usr/bin/env bash
# One-shot GitHub Copilot CLI call. Prompt is read from stdin.
#
# Usage: copilot-chat.sh [model]
# Env:   COPILOT_MODEL  default model when no argument is given (default: auto)
set -euo pipefail

model="${1:-${COPILOT_MODEL:-auto}}"

MISE_QUIET=1 copilot --model "$model" --silent \
  --deny-tool shell --deny-tool write
