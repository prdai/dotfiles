---
name: council
description: Runs a critical decision or code review through four independent models, an anonymized peer review, and a chaired verdict, looping until delegates are satisfied. Use when a decision hits the critical bar (irreversible or destructive action, public API or architecture, large refactor or release, production incident) or when the user says "council", "council this", "run the council", "critical check", or "pressure-test this". Do not use for routine edits, factual lookups, or reversible low-cost choices.
---

# Council

Four models answer independently. They review each other blind. The current
agent chairs and verifies. The point is to surface disagreement, not manufacture
consensus.

## When to convene

Convene only when at least one is true:

- irreversible or destructive action: delete, force-push, credential change, infra teardown
- public API, architecture, or dependency contract
- large refactor, release, or breaking change
- production incident, rollback, or hotfix
- anything else the user explicitly flags as critical

Do not convene for routine edits, formatting, single-file fixes, factual
lookups, brainstorming without stakes, or anything cheap to reverse.

The agent proposes, the user confirms. State which criterion matched and the cost
(four voices, two rounds, eight model calls: four on the NVIDIA free tier and
four Copilot calls), then wait for an explicit yes. Manual triggers: "council",
"council this", "run the council", "critical check", "pressure-test this".

## Before a review round

When the request is a code review, address outstanding PR comments, fix known
issues, and run relevant checks first. Give council the updated implementation;
do not defer known fixes until reviews return. If the user wants to discard the
implementation and explore new ideas, skip fixes to code being replaced.

## Voices

Two voices run on the NVIDIA hosted NIM API through
`~/.dotfiles/scripts/nvidia-chat.sh`, which reads `NVIDIA_API_KEY` from
`~/.dotfiles/.env`. Two voices run on the GitHub Copilot CLI through
`~/.dotfiles/scripts/copilot-chat.sh`, using the logged-in Copilot account.

| Voice | Provider | Model | Notes |
|---|---|---|---|
| 1 | NVIDIA NIM | `nvidia/nemotron-3-ultra-550b-a55b` | 550B MoE, ~2s, strongest fast model |
| 2 | NVIDIA NIM | `moonshotai/kimi-k3.1-pro` | frontier reasoning, ~2min, slowest |
| 3 | GitHub Copilot | `auto` | Copilot Fusion picks the model; uses AI credits |
| 4 | GitHub Copilot | `auto` | same Fusion router as voice 3 |

The NVIDIA pair spans two unrelated families, which is the point. The two
Copilot seats share one Auto router, so they are two samples of the same lineage,
not two independent families. On the Copilot Student plan `auto` is the only
usable model: every specific id in `/model` is gated. Do not claim four distinct
families.

NVIDIA model ids are the upstream ids. Availability is per key: some catalog
models return `404 Function ... not found for account`. If a voice fails that
way, report it and continue with the voices that answered.

A project overrides the lineup in its `AGENTS.md` with:

```
Council: model, model, model, model
```

Prefix a member with `copilot/` to run it through Copilot; anything else runs on
NVIDIA NIM. For example:

```
Council: nvidia/nemotron-3-ultra-550b-a55b, moonshotai/kimi-k3.1-pro, copilot/auto, copilot/auto
```

Use the override when it is in context. If the user names council members, use
those. The chair is the agent reading this skill. Never delegate the chair. If a
named member is unavailable, report it instead of substituting.

## Build the blind input

Write one neutral decision brief:

- the decision as a question, without the user's preference, recommendation, or lean
- facts and constraints, including relevant file paths and short excerpts
- success criteria and what is out of scope
- open unknowns

Do not include "the user thinks", "I lean toward", or any phrasing that invites
agreement. If the decision only exists because of the user's proposal, state it
as "Evaluate: migrate X to Y", not "Should we do what the user wants".

## Round 1: independent answers

Send the same brief to all four, in parallel. Tell each voice:

- it is one of four independent advisors and cannot see the others
- do not edit files, do not run commands, do not ask questions, do not start subagents
- label uncertain facts as unverified

Ask for:

1. recommendation in one sentence
2. strongest case for it, max five bullets
3. strongest case against it and its failure modes, max five bullets
4. assumptions made
5. what evidence would change the recommendation
6. for a code review, a score out of 10

### Running the voices

Run all four in parallel, one background job each:

```bash
mkdir -p /tmp/council
brief=/tmp/council/brief.md
~/.dotfiles/scripts/nvidia-chat.sh nvidia/nemotron-3-ultra-550b-a55b < "$brief" > /tmp/council/voice-1.md 2>&1 &
~/.dotfiles/scripts/nvidia-chat.sh moonshotai/kimi-k3.1-pro < "$brief" > /tmp/council/voice-2.md 2>&1 &
~/.dotfiles/scripts/copilot-chat.sh auto < "$brief" > /tmp/council/voice-3.md 2>&1 &
~/.dotfiles/scripts/copilot-chat.sh auto < "$brief" > /tmp/council/voice-4.md 2>&1 &
wait
```

Neither script caps tokens and both run to their own stop. Kimi is the slowest
by far; several minutes is normal, not a hang. If a call exits non-zero, its
error sits in that voice file: report it and continue with the others. Do not
retry more than once.

Keep the four outputs separate and labelled by voice. If one provider cannot run
at all (`NVIDIA_API_KEY` unset, Copilot not logged in, network down), report that
gap; do not invent answers for the missing voices.

## Round 2: anonymized peer review

Relabel the answers A, B, C, D in a fixed order. Remove model names and anything
self-identifying. Send all four answers to all four voices with:

- the same neutral brief
- all four anonymous answers
- do not guess authors
- do not converge for agreement's sake

Ask for:

1. ranking by decision quality, with reasons
2. factual errors or unsupported claims, quoted
3. the strongest objection to the current leading answer
4. whether their round-1 view changed, and why

Use the same scripts and the same parallel pattern. Keep the label map to
yourself until synthesis.

## Synthesis

Before writing the verdict, verify what is cheap to verify: repo facts,
versions, documented API behavior, current official docs. The chair does this,
not the voices. If a claim cannot be checked, keep it in `Unverified`.

Output in chat:

```
Verdict: <recommendation>
Confidence: high | medium | low, with the reason
Consensus: <what held across voices>
Disagreements: <the real split, with the strongest dissent quoted or paraphrased>
Evidence checked: <what was verified, how>
Unverified: <claims left unchecked>
What would change this: <the evidence or condition>
Bias check: <relation to the user's stated position; say plainly if the evidence contradicts it>
Next step: <one action>
```

Rules:

- Majority is not truth. Model agreement is not evidence; shared training bias is possible.
- Preserve dissent. Do not average incompatible recommendations.
- Do not soften a verdict to match the user. If their position lost, say so.
- Do not say "all four agreed" unless they did.
- Do not edit code during the council. Implement only after the verdict and the user's go-ahead.

## Loop after fixes

When the council recommends changes and the user agrees, make them and request a
fresh round. Count each full review pass as one round; a fresh review after
fixes starts a new round. Continue until all delegates are satisfied or an item
stays disputed after two replies, then show both sides in two or three lines and
let the user decide.

Do not let repeated reviews grow scope. Keep the change at the size the goal
needs, decline nits with a written reason, and prefer fixes that delete or
narrow code.

## Council results in a PR

If the work ends in a pull request, put the results in the PR description, above
the model and harness line:

```markdown
## Council review

Rounds: 2

| Delegate | Round 1 | Round 2 |
| --- | --- | --- |
| Nemotron 3 Ultra | 7/10 | 9/10 |
| Kimi K3.1 Pro | 7/10 | 9/10 |
| Copilot Auto A | 7/10 | 9/10 |
| Copilot Auto B | 8/10 | 9/10 |
```

Use the real delegate names. If a delegate gives no score, write `no score`; do
not invent one. If the PR is open, edit the description instead of posting a
comment. If there is no PR, put the same results in the final reply only.

## Failure handling

| Failure | Action |
|---|---|
| One voice fails | Continue with three, state the gap, lower confidence |
| Two or more fail | Stop. Report the errors. Do not invent answers |
| Round 2 partial | Synthesize from available reviews, mark confidence low |
| Same decision asked twice | Reuse the verdict unless new evidence exists |

Retry a failed voice at most once.

## Cost

Eight model calls across a two-round pass: four independent answers, then four
reviews. The two NVIDIA voices run free on the NIM tier and share its roughly
40 requests/minute budget. The two Copilot voices draw on the 200-credit monthly
allowance of the Copilot Student plan, so a full pass costs about 4 credits;
roughly 50 passes per month, and NVIDIA keeps working after Copilot credits run
out. Do not run the council twice for the same decision without new evidence. If
a model is unavailable, report the gap instead of reaching for a paid provider.

Origin: adapted from Karpathy's LLM Council by way of aiwithremy/claude-skills-llm-council and gcpdev/llm-council-skill, merged with t3dotgg/tstack council.
