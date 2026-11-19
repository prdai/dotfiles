---
name: pr-review-loop
description: Drive one pull request through review and CI to merge readiness: watch for comments and check changes, triage and fix findings, keep CI green, reply per thread, and re-request review. Use when asked to babysit, monitor, or keep a PR moving through review, especially when reviewer or CI activity must be handled without polling.
---

# PR review loop

Run one PR review cycle until it is approved and merged, or until the user stops it. The user sets scope; merging always needs explicit authorization.

## Setup

- Link the PR if the harness has a link tool. Links persist across pushes.
- Watch the PR with the harness watch (`watch_pull_request` in T3 Code). It wakes the thread on new comments, reviews, failed checks, required checks passing, and conflicts. That watch is the loop; do not poll with `sleep`, loops, or `gh --watch`.
- If there is no watch, use the harness scheduler with a short prompt. Do not start a background shell loop.
- Watch only the PRs in scope. Keep a stacked base PR watched separately when its merge changes what the current PR should rebase onto.
- Unwatch before handing the work back when no checks or reviews are pending.

## Loop

1. **Read what is new.** Fetch inline review comments, review bodies, and issue comments created since the last handled point. A review summary is not a finding list: confirm the reviewed commit is the current head before acting on it.
2. **Triage each item.** Verify the claim against the current code before changing anything. Classify it as actionable, already fixed, stale or wrong, or a scope decision for the user. Do not implement a finding that contradicts the spec or pulls in a larger design change without asking.
3. **Fix in small commits.** One concern per commit, Conventional Commits. Run the repository gates locally (format, lint, typecheck, tests) before pushing. Add a regression test for every behavior fix.
4. **Push and wait.** Push the branch and let the watch report CI. Never rerun a run that is still in progress.
5. **Handle CI failures.** Read the failing job log and name the failing test. If the change caused it, fix it. If it is unrelated and flaky, say so with the test name and error, wait for the run to finish, then rerun only the failed jobs. Do not edit unrelated code to make a flaky test pass.
6. **Reply per finding.** After the fix is pushed, post one reply per thread: `Done in <short-sha> — <what changed and the evidence>.` Include the test or command that proves it. If a finding is not fixed, say why with evidence and let the user decide. Resolve the thread only when it is genuinely addressed.
7. **Re-request review.** Request the reviewer or reviewers who asked for changes, not a generic list. Do it after the fix is pushed, and again after each round.
8. **Repeat.** Handle the next wake the same way. Stop when the PR is merged, approved with nothing pending, or blocked on a user decision.

## Review and reply rules

- Read `coding-style` before changing code: flat control flow, comments only for a non-obvious why, one concern per file, reuse before duplication, fail-fast errors with context.
- Read `writing-style` before writing public text: direct, short, evidence first, no emoji or chat tics.
- Read `leaving-pr-comments` before posting. Posting is the user's call; do not post a reply, resolve a thread, approve, or dismiss a review unless the user authorized it for that task.
- Prefer a reply in the thread. Use one summary comment only when the review has no inline threads.
- Do not bury a disagreement. State the evidence, name the tradeoff, and let the user pick.

## CI rules

- Report exact commands and outcomes. State what was not verified and what still needs a live check.
- Rerun only failed jobs, and only after the run is complete. Identify a flake by test name; do not call a failure flaky without the log.
- Do not force-push a PR under review unless the user asks. Keep review fixes as new commits; rebase only when the user asks or the base requires it, then say so.
- Do not merge, approve, or resolve other people's threads on the user's behalf. A green CI result is not merge authorization.
- Do not commit unrelated files, secrets, or private machine details. Preserve other work in the checkout.
- On a stacked PR, land the base first or rebase after it lands, and say which commit the rebase is based on.

## Done

Before handback, stop the watch if nothing is pending. Report the current head, CI state, and any comments still waiting on the user.
