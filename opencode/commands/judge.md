---
description: Judge the staged diff before committing
---

Judge the staged diff before committing. Load the `commit-judge` skill and follow it.

Use an independent model from the quota policy in the skill. Report `PASS` or numbered blockers with `path:line` and the fix. Do not commit until the result is `PASS`.
