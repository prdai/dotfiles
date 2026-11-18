# Comments audit

A comment-only review pass. Use for "clean up comments", "trim comments", or a diff-wide audit.

Run the audit yourself. No subagent and no second opinion: read the diff, judge
every comment against the rules below, and make the smallest fix in scope.

## Scope

Use the files or diff the caller named. Otherwise use the current diff against
the base branch, default `main`, including the working tree. Stop at the fence:
do not widen it, and do not fix instances outside it.

## What a comment may be

A comment survives only when it explains a non-obvious **why** that the code
cannot express: a deliberate tradeoff, a platform quirk, a cross-file pointer, a
pinned supply-chain or security justification, or a constraint we cannot change.
Everything else goes.

Kill on sight:

- narration of what the next line already says
- commented-out code, dashed section dividers, AI attribution footers
- changelog and history notes that belong in git
- restated types, params, or return values
- multi-line comments that shrink to one line without losing the why
- obsolete comments left behind by a refactor
- comments that explain a workaround instead of the reason the workaround exists

Keeps for `do not remove`, `do not change wording`, or `talk to X before
changing` need proof that the constraint is about something we cannot change. No
proof means delete; a refuted or ambiguous keep is deleted. If the why is
unclear, trace the referenced symbol or API before deciding. Never restore a
comment you cannot justify.

## Suppressions

Audit scoped lint and type suppressions as comments too. A suppression for
correctness or safety stays an actionable kill. A suppression that hides a real
failure has to be fixed, not kept.

## Fixes

Fix a flagged comment by removing the dead path, dropping the parameter, or using
the real API. If the fix needs a shape, sketch it first, then implement the
smallest root-cause fix in scope. Remove every named workaround. If the root
cause is out of scope, land the smallest in-scope fix and report the rest open.

Do not bolt on symptom guards or replace a bad comment with a different bad
comment.

## Encoding constraints

When a comment exists only because a type, runtime, test, or CI check is missing,
offer the cheapest in-scope encoding for that constraint and wait for approval.
Under unattended or eval runs, require caller pre-approval. If approved, encode
the constraint and delete the comment. Otherwise delete the comment, report the
constraint open, and sketch the out-of-scope work.

## Report

Report the deletion count, any restored comments, fixes made, encoding offers and
results, unenforced constraints, and other open work. State what was verified and
what was not.

Origin: adapted from cursor/plugins pstack no-comments. MIT, Copyright (c) 2026
Lauren Tan. See [../../ATTRIBUTION.md](../../ATTRIBUTION.md).
