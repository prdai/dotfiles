---
description: Prepare or update the pull request for the current branch
model: opencode-go/deepseek-v4.1-flash#high
---

Prepare or update the pull request for this branch.

1. If there are uncommitted changes, run the `commit-judge` skill first, fix every blocker, then commit.
2. Push the branch. Never force-push unless I ask.
3. Create or update the PR. Title and body follow AGENTS.md and the `writing-style` skill.
4. If the change touches UI, capture before/after screenshots and a short screen recording, commit them to an `assets/pr-<number>` branch in the head fork, and link them from the PR body. Do this without asking.
5. Report the PR URL, head SHA, and anything not verified.
