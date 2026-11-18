---
name: pr-judge
description: Independent review gate that runs before a PR is marked ready for review. Judges the full PR diff, title, and body against the task, repo conventions, and coding-style, blocks on real problems, loops until resolved, then allows the ready transition. Use when asked to make a PR ready, before a draft-to-ready flip, or via the /judge command.
---

# PR Judge

Run when the user asks to make a PR ready for review, after the work is pushed and before the draft-to-ready flip. The implementer does not judge its own PR.

## Gate

1. Identify the base and head (`gh pr view --json baseRefName,headRefOid,title,body,isDraft`). Judge the full diff `git diff base...head`, the PR title, and the PR body.
2. Judge against the task the user asked for, the repo's conventions, and `coding-style`.
3. BLOCK on any of:
   - correctness bug or regression, or behavior change with no verification
   - scope creep, unrelated files, generated artifacts, commented-out code
   - secrets, tokens, credentials, or machine-specific paths
   - PR title not Conventional Commits where the repo uses them, or a body missing what changed, why, or verification
   - UI change with no before/after screenshots and no screen recording
   - stale references: docs, config, symlinks, or callers left inconsistent
4. Fix blockers, push new commits (never force-push a PR under review), and re-run. Mark ready only after `PASS`.
5. Report `PASS` or the blockers. State what was checked and what was not verified.

## Model selection

Judge on an independent model, never the implementer model.

1. Check remaining quota with `mystatus`. If it errors (expired token, no quota data), treat OpenAI as unavailable.
2. OpenAI available: `codex` / `gpt-6.1-sol` with `reasoningEffort: low`. Use `gpt-6-astra` with `reasoningEffort: low` when the PR needs deeper product or ambiguous-spec judgment. Pick by remaining usage: prefer the model with more headroom.
3. No OpenAI: `opencode` / `opencode-go/deepseek-v4.1-flash` (DeepSeek V4.1 Flash 1017) with `variant: high`. Use `variant: max` when quota allows and the PR is large or risky.
4. If the promised model is at capacity, retry once, then move to the next option in the chain.

## Delegate

Prefer T3 `delegate_task`:

- `target: { providerInstanceId: "codex", model: "gpt-6.1-sol", options: { reasoningEffort: "low" } }`
- `target: { providerInstanceId: "opencode", model: "opencode-go/deepseek-v4.1-flash", options: { variant: "high" } }`

Give the judge the base and head SHAs, the full diff, the PR title and body, the task intent, repo conventions, and the verification commands already run. Ask for `PASS` or `BLOCK` only.

If `delegate_task` is unavailable, use the harness's subagent tool with the same model preference.

## Output

`PASS` or `BLOCK: <n>`, then numbered blockers as `path:line` plus the fix. No praise, no diff summary.
