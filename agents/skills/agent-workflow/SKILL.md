---
name: agent-workflow
description: prdai's agent PR loop — how agents must submit work, respond to review, verify, and communicate. REQUIRED whenever an agent puts up a PR, addresses review feedback, posts PR/issue comments on prdai's behalf, or hands work back for review. Triggers: PR review, review feedback, re-review, verification, PR comments, supersede, rebase/squash.
---

# Agent Workflow — the review loop with prdai

prdai reviews every PR. The loop is: agent opens PR → prdai reviews (or delegates review, then spot-checks) → agent applies feedback → repeat until merged. Work to make his review only about the logic, not the basics.

## Responding to review feedback

- Fix **every** comment, including nitpicks. Nothing gets silently skipped; if you disagree, say so with evidence and let him decide.
- Per-comment replies in his voice: **"Done in `<short-sha>` — <what changed and why>"**, then `Resolving.` when the thread is genuinely addressed. One reply per comment, not one giant summary comment.
- Investigate before answering. If he asks "why are we doing it with chunks?" / "isn't this redundant?" / "can't this be reused?" — actually dig in (code, DB, git history, docs) and answer with facts: what the code does, what the platform caps are, what the alternatives cost. Never answer from assumption.
- When you disagree or propose an alternative, give options with a recommendation: "(a) ... (b) ... (c) ... I'd go (a) because ... Shout if you disagree." He picks ("let's do A"). Do not implement an option until he picks, unless he delegated the call.
- Scope changes he requests: implement in this PR; genuinely-out-of-scope work becomes a filed follow-up issue with a cross-link, noted in the reply.

## Verification bar (non-negotiable)

- Run the tests/linters/build before handing back, and report exact results ("8 passed", "723/723"). Never claim verified without having run it.
- State honest gaps explicitly: "I could not probe the live table because the credentials don't own the deployed stack" — not silence, not hand-waving.
- "Works" means verified across the whole application, not just the touched file. He will ask "re verify that this works for the entire application and that it is consistent" — pre-empt it.
- UI changes: attach screenshots of the running app. Docs claims ("matches the upstream matrix"): verify against the source, link it.
- Distinguish **pre-existing** issues from regressions your diff introduced ("this failure pre-exists on main; `git diff main...HEAD` touches no X code"). Fix regressions; report pre-existing ones separately.
- When he says "you can over do it and i will correct it within the pr" — take the fuller implementation; he'd rather trim than chase.

## Review passes before handing back

- Do a self-review against the `coding-style` skill before requesting review: comment trim pass, no magic values, reuse check, types at edges, happy-path-first.
- On bug-prone or invariant-touching work (money, auth, migrations, data integrity), run adversarial review passes with **independent reviewers** (fresh-eyes agent + codebase-aware agent). Reviewer diversity matters: fresh-eyes agents repeatedly caught bugs codebase-aware reviewers rubber-stamped.
- Track fixes in numbered findings tables with file:line and severity (RED = correctness/invariant bug, YELLOW = style/deferred). Refute false positives explicitly with evidence — verify against actual consumers before "fixing" (a sign-convention "bug" may match the UI's convention).
- Fix in commits scoped by iteration/concern: `fix(ledger): iter1 double-insert + specialPayment fixes`.

## PR and issue hygiene

- Keep a single reviewable change. If multiple open issues/PRs reference the same thing, **combine them into one and close the extras with "Superseded by #N — <reason>"** cross-links. Same for conflicted PRs: supersede via a fresh branch/PR rather than fighting the head.
- Before requesting review: rebased on current main, conflicts resolved, commits squashed to one logical commit per concern unless he wants the history.
- Session handoffs on long-running work: post a state comment — branch, gate results, what's verified, what's in flight, what's left — so any agent can resume.
- Answering "Partially done" status: name the merged PR and enumerate exactly what **remains**.
- Multi-issue-scope features: "let's do each one of the mentioned things in a singular PR" — batch coherent units, not one PR per micro-change.

## When he delegates to you as reviewer

- He reviews others' code with options and evidence, not orders: "nitpick: ...", "we could remove the else here right?", "is there a sdk we can use for this man? web search and see", "can't this be re used?", "isn't this redundant?"
- Comments are short, specific, and constructive; each one carries either a concrete suggestion (code block) or a question that forces investigation.
- Gentler tone with external contributors ("nitpick:", "thanks!") than with internal agents. Never disparage other projects/maintainers — their work is a reference point, not a failure.

## Voice (when posting on his behalf)

- Casual and brief: "thanks!", "pl", "js", "man", "asw", "imo", ":))" are fine in comments. No emoji in code, commits, PR bodies, or docs.
- Direct directives over polite hedging. Ask him specific questions when blocked ("what exactly do you need verified for this? ask me the specific questions you required to proceed") instead of stalling.