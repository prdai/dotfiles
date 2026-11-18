---
description: Judge the PR before marking it ready for review
---

Judge the full PR diff before marking it ready for review. Load the `pr-judge` skill and follow it.

Use an independent model from the quota policy in the skill. Report `PASS` or numbered blockers with `path:line` and the fix. Do not mark the PR ready until the result is `PASS`.
