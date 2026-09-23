---
name: goal
description: Run Codex-style goal mode for a long-running objective with the goal tools (create_goal, get_goal, update_goal, update_goal_status, clear_goal). Use when the user sets, views, pauses, resumes, edits, completes, or clears a session goal, or wants the agent to keep working toward one objective until it is done or blocked.
---

# Goal

Drive one explicit long-running objective per session with the goal tools from
`@prevalentware/opencode-goal-plugin`. This skill exists so goal mode is reachable
from frontends that surface OpenCode skills but not plugin slash commands, such as
T3 Code.

## Workflow

1. Call `get_goal` first and read the current state.
2. Viewing: report the returned state and stop.
3. Creating: only when `get_goal` returns no non-closed goal, call `create_goal` once with a faithful objective. If it returns the same non-closed goal, continue from it; if it returns a different non-closed goal, report the conflict instead of replacing it.
4. Editing: call `update_goal_objective`. Pausing or resuming: call `update_goal_status`. Clearing: call `clear_goal`.
5. Completing: audit real files, command output, tests, or PR state first, then call `update_goal` with `status: "complete"` and concise `evidence`. If the goal cannot be achieved, call `update_goal` with `status: "unmet"` and a concrete `blocker`.
6. After creating or resuming, keep working toward the goal.

Never infer a goal from unrelated context, and never create one unless the user
explicitly asks for a goal.
