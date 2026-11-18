---
description: Prepare or update the pull request for the current branch
model: opencode-go/deepseek-v4.1-flash#high
---

Prepare or update the pull request for this branch.

1. Push the branch. Never force-push unless I ask.
2. Create or update the PR. Title and body follow AGENTS.md and the `writing-style` skill.
3. If the change touches UI, capture before/after screenshots and a short screen recording, commit them to an `assets/pr-<number>` branch in the head fork, and link them from the PR body. Do this without asking.
4. Do not mark the PR ready for review unless I ask. When I ask, run `/judge` first and mark ready only after `PASS`.
5. Report the PR URL, head SHA, and anything not verified.
