---
name: agent-commit-provenance
description: Commit attribution rules for agent-assisted work, covering the Co-authored-by identity each tool gets, when to add session and log URL trailers, and how user review is signed off. Use when writing, amending, squashing, or reviewing commits that an agent contributed to.
---

# Agent Commit Provenance

Commit trailers are the only place to record which tools contributed. Keep them accurate, minimal, and stable across model versions.

## Co-author identities

One trailer per tool that actually contributed. Use the official identity, never a model name or version.

| Tool | Trailer |
|---|---|
| Claude, any model | `Co-authored-by: Claude <noreply@anthropic.com>` |
| Codex and OpenAI | `Co-authored-by: Codex <codex@openai.com>` |
| Cursor | `Co-authored-by: Cursor <cursoragent@cursor.com>` |
| Everything else | `Co-authored-by: Codex <codex@openai.com>` |

- OpenCode, pi, Gemini CLI, Copilot, and unknown harnesses have no official identity of their own. Attribute them to Codex.
- Drop variants such as `Claude Sonnet 5`, `Claude Opus 4.8 (1M context)`, and `OpenAI Codex`. Same tool, same line.
- Never attribute a tool that did not touch the commit. Never add attribution prose such as "Generated with ..."; the `writing-style` skill bans it.

## Session and log trailers

Add these directly after the body, only when the tool printed the URL:

```
Claude-Session: https://claude.ai/code/session_<id>
Agent-Logs-URL: <url>
```

- `Claude-Session` for Claude Code sessions.
- `Agent-Logs-URL` for harnesses that expose a run or log URL.
- Never construct an ID, guess a URL, or reuse one from another commit.

## Review sign-off

- `Signed-off-by: User` when the user has reviewed the change.
- No review-coverage trailer. Do not write `Review: Limited user review before commit` or a variant. If review was incomplete, say so in chat before committing and let the user decide.
- Keep `Signed-off-by` when the user asks for it, even if the review was partial.

## Shape and order

Subject line first, following the repo's commit convention. Trailers go after a blank line:

```
feat(cf-stack): add PR preview deploys

Signed-off-by: User
Co-authored-by: Claude <noreply@anthropic.com>
```

- Order: `Signed-off-by`, session or log URL, `Co-authored-by`.
- One contributing tool means one `Co-authored-by` line. Multiple tools mean one line each, no duplicates.
- A commit with no agent involvement has no co-author trailer.

## Amending and squashing

- Rebase and squash keep every distinct contributing tool, then dedupe.
- Normalize off-spec lines while amending: `Claude Sonnet 5 <noreply@anthropic.com>` becomes `Claude <noreply@anthropic.com>`, `pi <pi@local>` becomes `Codex <codex@openai.com>`.
- Do not rewrite history to add trailers unless the user asks.

## Checklist before committing

- Every contributing tool has exactly one correct trailer.
- Every tool other than Claude and Cursor maps to Codex.
- A session URL is present only if the tool printed one.
- `Signed-off-by: User` is present only when the user reviewed.
- No `Review:` trailer, no model versions, no attribution prose.
