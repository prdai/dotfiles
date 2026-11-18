---
description: Sync the current repo with its default branch
model: opencode-go/deepseek-v4.1-flash#low
---

Sync this repository with its default branch and report the result.

1. Detect the default branch from `origin/HEAD`, falling back to `main`.
2. Run `git fetch --prune`.
3. If the working tree is dirty, stop and list the changed files. Do not stash, reset, or discard anything.
4. Show ahead/behind with `git rev-list --left-right --count HEAD...origin/<default>`.
5. On the default branch, run `git pull --ff-only`. On a feature branch, do not rebase unless I ask; report the divergence and stop.
6. Report the branch, old and new SHA, and anything that needs my decision.

Never force-push, never `git reset --hard`, never discard uncommitted work.
