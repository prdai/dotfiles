---
name: arena
description: Runs N parallel candidates at the same task, picks one base, and grafts the strongest parts of the losers into it. Use for /arena, "arena this", "throw it in the arena", or when a single attempt at a non-trivial artifact would lock in the wrong shape.
---

# Arena

Several models attempt the same artifact independently. You pick a base against a
written rubric, port the best ideas from the losers, and verify the result. The
point is coverage of shape, not a vote.

Open a todolist with one entry per phase (Frame, Fan out, Cross-judge, Pick,
Graft, Verify) before launching anything.

## Phase A: Frame

Every candidate gets the same prompt, so the prompt is the contract.

1. State the artifact each candidate is producing.
2. Derive the rubric: 3-6 concrete, gradeable criteria for success on this task.
   The rubric is your picker's tool in Phase D. Candidates only see the task.
3. Pick the runners.
   - Call `orchestrator_capabilities` once per thread before the first
     `delegate_task`, then choose models from its catalog.
   - Default trio, one candidate per provider, same as Council: Codex
     `gpt-6-luna`, Antigravity `gemini-3.8-flash-high`, OpenCode Go
     `opencode-go/mimo-v2.6-flash`.
   - A project overrides the trio in its `AGENTS.md` with
     `Arena: providerInstanceId:model:option=value, ...`. Use the override when it
     is in context.
   - If the user names runners, use those. If a named provider or model is
     unavailable, report it instead of substituting.
   - Spawn more runners when the arena covers multiple design directions. Use the
     same model N times when the work is generation-bound rather than
     judgment-sensitive.
   - Set reasoning level and speed per runner to fit the job.
4. Give each candidate its own output location. Use `isolation: "worktree"` on
   `delegate_task` so candidates cannot see or clobber each other's edits. If
   worktrees are unavailable, use `/tmp/arena-<slug>/candidate-<n>/`.

## Phase B: Fan out

Spawn all N candidates in one message with `mode: "async"`, each with the task,
the shared grounding, its own output path, and instructions to produce the
artifact plus a short rationale naming the alternatives it considered and what it
rejected.

Use `delegate_task` for any runner that differs from your provider or needs a
worktree or settings beyond yours. Use your native subagent tool only for a
runner that uses your own provider, model, and settings.

Fan out runs in parallel. Do not start Phase C until every candidate has
finished. If a candidate produces no output, continue with N-1 and note the
dropout.

## Phase C: Cross-judge

After all candidates complete, spawn one read-only judge. The judge must come
from a provider other than the one running this agent.

- Parent on OpenCode Go: prefer Antigravity `gemini-3.8-flash-high`, then Codex
  `gpt-6-luna`.
- Parent on Codex: prefer Antigravity `gemini-3.8-flash-high`, then OpenCode Go
  `opencode-go/mimo-v2.6-flash`.
- Parent on Antigravity: prefer Codex `gpt-6-luna`, then OpenCode Go
  `opencode-go/mimo-v2.6-flash`.

If the parent's model cannot be determined, try the providers in catalog order
and say the vendor check did not run. If every candidate judge provider is
unavailable, skip the judge, pick the base alone in Phase D, and say so.

The judge sees the rubric and the candidates by path label only, scores each
criterion, and recommends a base with rationale. It must not edit files or run
commands. It runs in parallel with your own reading in Phase D. Do not spawn it
while candidates are still writing.

## Phase D: Pick a base

Read every candidate end to end before picking. Score each against the rubric
criterion by criterion, not on holistic feel, and compare with the cross-judge
when Phase C ran one.

Agreement on the base confirms the pick. Disagreement means one of you is biased
or the rubric was ambiguous. Read both rationales before deciding.

Pick the base a future maintainer can extend most easily without breaking its
invariants. When two feel tied, prefer the cleaner boundary or smaller surface
area.

## Phase E: Graft

Walk each losing candidate once more for what is worth porting into the base,
usually one or two things per candidate, not most of it. Fold each graft in by
hand so the result stays coherent under one mental model. Do not paste
mechanically, and keep the code style of the base.

If the candidates converge on one shape, that is strong agreement. Note it and
ship the consensus shape. No graft is needed. If they diverge wildly, Phase A
was under-specified: reframe and re-run rather than averaging the divergence.

## Phase F: Verify

Verify the synthesized artifact like any other output: run the checks, compare
against the rubric, and report what was and was not verified. If verification
finds a problem the arena missed, either Phase A was wrong (reframe and re-run)
or a candidate caught it and you missed the graft (go back to Phase E). Do not
paper over it.

## Failure handling

| Failure | Action |
|---|---|
| One candidate fails | Continue with N-1, note the dropout |
| Fewer than two candidates succeed | Re-run the arena or fall back to a single attempt and say so |
| Cross-judge unavailable | Pick the base alone and say so |
| Candidates converge | Ship the consensus shape, skip the graft |
| Candidates diverge wildly | Reframe Phase A and re-run |

Retry a failed candidate at most once.

## Outputs

One synthesized artifact, plus a short synthesis note alongside it:

- the base chosen and why
- the cross-judge's verdict, or that Phase C skipped the judge
- each graft with its source candidate
- what was rejected and why
- convergence or dropouts
- the verification result

Origin: adapted from cursor/plugins pstack arena for this repo's providers and
T3 Code delegation.
