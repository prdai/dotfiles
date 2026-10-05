---
name: coding-style
description: prdai's personal code style. REQUIRED when writing, editing, or reviewing any code, and when writing commits or PRs. Triggers include comments, nesting, decomposition, SDK usage, error handling, tests, commit messages, PR bodies, code review, reuse, naming, security.
---

# Coding Style

Patterns distilled from prdai's authored PRs across repos (dotfiles, sfia-skill-extraction-comparison, GDPR, litellm, drizzle-orm, wso2/fhir-server). Match these unless the repo's own conventions say otherwise.

## Comments: near-zero, "why" only

- Default to no comments. Never narrate what the code already says.
- The only acceptable comment is a non-obvious **why**: a deliberate tradeoff, a platform quirk, a cross-file pointer ("see userdata.sh.tmpl"), or a pinned supply-chain/security justification.
- No dashed section dividers, no commented-out code, no AI attribution footers.
- Before handing work back, do a trim pass: delete redundant comments, shrink multi-line comments to one line, drop ones that became obsolete after a refactor. In existing repos, do this as its own commit (e.g. `Trim comments in attest.go`) rather than mixed into feature commits.
- Docstrings/doc comments only at the class or function that embodies a design decision; keep them 1-4 lines, present tense.
- Config files (dotfiles, lua, bash) are the exception: block-level "why" comments explaining intent are fine there.

## Control flow: flat, happy-path first

- Guard clauses and early returns. Max nesting depth ~2.
- Reorder functions so the happy path reads top-to-bottom and error handling falls off the end ("Reorder attest/track flow to happy-path-first with early returns").
- Prefer `or`-defaults, ternaries, and flat if-chains over nested conditionals. Prefer `select`/dispatch over conditional ladders.

## Decomposition: one concern per file

- Files stay small and single-purpose. When a file grows, split it by concern (`attest.go` -> `runconfig.go`, `vsock_transport.go`).
- Extract small pure helpers aggressively, even 4-line ones if the concept deserves a name (`searchBandEnd`). Share helpers instead of duplicating.
- Module-level named constants grouped at the top of the file: paths, timeouts, feature flags, model IDs. No magic values inline; if one must stay inline, give it a why-comment.
- Keep entry points (`main`, CLI) thin; push work into modules.
- Prefer pipelines/one-adapter-per-module structure: one ABC or interface, one adapter module per implementation.

## SDKs and platform primitives over hand-rolling

- Use the official SDK / typed platform interfaces when one exists; encode platform limits explicitly in validation (e.g. "KV TTL must be >= 60 seconds") rather than as magic checks.
- Delete custom code when the platform offers it as a service (replaced a Puppeteer crawler with Cloudflare's `/crawl` REST API and shrank the codebase).
- When inside a framework, use the framework's client and contracts (httpx transformation configs, `BaseRerankConfig`), not raw urllib.
- Raw HTTP only where no SDK fits; then isolate it in one small module (a `workers_ai.py` that is just HTTP + retry).

## Errors: fail fast, carry context

- Fail fast in library code: raise/return wrapped errors with context, always chained (`%w`, `raise ... from e`).
- Error messages include remediation: name the env var AND the parameter alternative.
- Distinguish error classes: `TypeError` for wrong shape, `ValueError` for wrong/missing value; reuse the provider's own error type with the raw payload attached.
- At pipeline/CLI boundaries, log-and-continue to stderr with a per-item FAILED line instead of aborting the batch; keep progress output on stderr.
- Retries: explicit retryable-predicate (timeouts, connection errors, 429/5xx) + exponential backoff + `reraise`, not blanket retry.

## Typing and data edges

- Full modern type signatures (`str | None`, `dict[str, T]`, generics, `satisfies`). No `any`-heavy TS, no untyped Python.
- Structured models (pydantic, TypedDict) at I/O edges; LLM/API output validated against a schema with enum constraints, then deterministic post-filters (dedupe, range checks).

## Tests

- Table-driven (`parametrize`, Go `[]struct` cases that read as sentences). Heavy on negative/error paths.
- Assert real behavior, not just return values (query plans, no Seq Scan, actual store integration).
- Minimal hand-rolled fakes (a Map-backed ~30-line fake) over mocking libraries.
- If no test harness fits, verify empirically: sweeps, benchmarks, and honest `[x]/[ ]` test plans in the PR.

## Commits and PRs

- Match each repo's convention: Conventional Commits (`feat(scope): ...`, single line, no body) in upstream/agent repos; plain imperative sentences in dotfiles and personal repos.
- Style-trim passes, typo fixes, and renames get their own commits. One concern per commit; stacked PRs say "Stacked on #N".
- PR bodies: `## what changed` / `## why` / `## verification` (exact commands, honest not-verified gaps). Skip sections that add nothing.
- No emoji, anywhere.

## Generalize, don't machine-code

- No hardcoded user paths, hostnames, or machine-specific values; resolve from PATH/env, provide portable fallbacks.
- Prefer cross-platform parity and explicit portability notes over per-machine hacks.

## Generic and reusable over specific (review standard)

- Shared docs (coding standards, READMEs, workflows) stay generic and reusable; repo-specific details do not belong in them.
- No magic values inline — `bruh`-tier hardcoded literals get a named constant or config. Convention for "all/unbounded": use `-1` as the sentinel for max, any positive number is an actual limit.
- Reuse before duplication: extract shared helpers/components (`formatLoanDate` into `@/lib/utils`); one copy per concept. New files that parallel an existing one are suspect — refactor so the pair shares everything except the one point of difference.
- When a concern grows (endpoint, query, route), generalize it once and file a follow-up issue to roll it out everywhere — one-off fixes that later need "do this for the other endpoints too" are a smell.

## Ecosystem research before hand-rolling

- Before writing custom code for a solved problem (camera handling, caching, retries, date math), web-search for a maintained SDK/package and evaluate it. Propose it; justify skipping it (e.g. "wrapper is thin, single maintainer, stale" or "sensitive code, not worth swapping in this PR").
- Check what the platform offers at the service level (CDN caching headers, built-in bindings) before building app-level mechanisms.

## Naming, placement, and consistency

- Question placement: does this helper live where it conceptually belongs? Check naming conventions against sibling files before adding new ones.
- Challenge redundancy: if a type/wrapper/column looks redundant, ask how it maintains compatibility rather than accepting it.

## Security edges on review

- Treat every externally-reachable route as an attack surface: SSRF (allowlist + DNS-rebinding + redirect re-validation), auth on upload/ingest paths, credentials never committed, secrets from env/Secrets.
- Rate limits: weigh per-IP limits against shared-ISP/CGNAT collateral; prefer user-scoped zones where practical.
