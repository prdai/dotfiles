---
name: llm-council
description: Runs a critical decision through three independent OpenCode models, an anonymized peer review, and a chair verdict. Use when a decision hits the critical bar (irreversible or destructive action, public API or architecture, large refactor or release, production incident) or when the user says "council this", "critical check", "run the council", or "pressure-test this". Do not use for routine edits, factual lookups, or reversible low-cost choices.
---

# LLM Council

Three models answer independently. They review each other blind. The current agent chairs and verifies. The point is to surface disagreement, not manufacture consensus.

## When to convene

Convene only when at least one is true:

- irreversible or destructive action: delete, force-push, credential change, infra teardown
- public API, architecture, or dependency contract
- large refactor, release, or breaking change
- production incident, rollback, or hotfix
- anything else the user explicitly flags as critical

Do not convene for routine edits, formatting, single-file fixes, factual lookups, brainstorming without stakes, or anything cheap to reverse.

The agent proposes, the user confirms. State which criterion matched and the cost (three voices, two rounds, six model calls), then wait for an explicit yes. Manual triggers: "council this", "critical check", "run the council", "pressure-test this".

## Voices

Default trio:

| Voice | Model |
|---|---|
| 1 | `opencode-go/kimi-k3.1-pro` |
| 2 | `opencode-go/deepseek-v4-pro` |
| 3 | `opencode-go/glm-5.3` |

A project overrides the trio in its `AGENTS.md` with:

```
Council: provider/model, provider/model, provider/model
```

Use the override when it is in context. The chair is the agent reading this skill. Never delegate the chair.

## Build the blind input

Write one neutral decision brief:

- the decision as a question, without the user's preference, recommendation, or lean
- facts and constraints, including relevant file paths and short excerpts
- success criteria and what is out of scope
- open unknowns

Do not include "the user thinks", "I lean toward", or any phrasing that invites agreement. If the decision only exists because of the user's proposal, state it as "Evaluate: migrate X to Y", not "Should we do what the user wants".

## Round 1: independent answers

Send the same brief to all three, in parallel. Tell each voice:

- it is one of three independent advisors and cannot see the others
- do not edit files, do not run commands, do not ask questions
- label uncertain facts as unverified

Ask for:

1. recommendation in one sentence
2. strongest case for it, max five bullets
3. strongest case against it and its failure modes, max five bullets
4. assumptions made
5. what evidence would change the recommendation

### T3 Code

If a `delegate_task` tool is available, call it three times in one message:

```
delegate_task(
  task: "<brief + round 1 instructions>",
  role: "research",
  isolation: "shared",
  mode: "wait",
  target: { providerInstanceId: "opencode", model: "opencode-go/kimi-k3.1-pro" }
)
```

Repeat for the other two models. Keep the three outputs separate and labelled by voice.

### CLI fallback

Use this when T3 tools or the provider are unavailable:

```bash
mkdir -p /tmp/llm-council
opencode run -m opencode-go/kimi-k3.1-pro "$(cat /tmp/llm-council/brief.md)" > /tmp/llm-council/voice-1.md 2>&1
opencode run -m opencode-go/deepseek-v4-pro "$(cat /tmp/llm-council/brief.md)" > /tmp/llm-council/voice-2.md 2>&1
opencode run -m opencode-go/glm-5.3 "$(cat /tmp/llm-council/brief.md)" > /tmp/llm-council/voice-3.md 2>&1
```

Run the three commands in parallel. Add `--pure` only if plugins interfere with a non-interactive run.

## Round 2: anonymized peer review

Relabel the answers A, B, C in a fixed order. Remove model names and anything self-identifying. Send all three answers to all three voices with:

- the same neutral brief
- all three anonymous answers
- do not guess authors
- do not converge for agreement's sake

Ask for:

1. ranking by decision quality, with reasons
2. factual errors or unsupported claims, quoted
3. the strongest objection to the current leading answer
4. whether their round-1 view changed, and why

Use the same T3 or CLI path. Keep the label map to yourself until synthesis.

## Synthesis

Before writing the verdict, verify what is cheap to verify: repo facts, versions, documented API behavior, current official docs. The chair does this, not the voices. If a claim cannot be checked, keep it in `Unverified`.

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
- Do not say "all three agreed" unless they did.
- Do not edit code during the council. Implement only after the verdict and the user's go-ahead.

## Failure handling

| Failure | Action |
|---|---|
| One voice fails | Continue with two, state the gap, lower confidence |
| Two or more fail | Stop. Report the errors. Do not invent answers |
| Round 2 partial | Synthesize from available reviews, mark confidence low |
| Same decision asked twice | Reuse the verdict unless new evidence exists |

Retry a failed voice at most once.

## Cost

Six model calls per run: three independent answers, three reviews. The default trio is the fast and cheap tier. Do not run the council twice for the same decision without new evidence.

Origin: adapted from Karpathy's LLM Council by way of aiwithremy/claude-skills-llm-council and gcpdev/llm-council-skill.
