---
name: doc-coauthoring
description: Guides co-authoring a document through context gathering, section-by-section refinement, and reader testing. Use when asked to write a doc, proposal, spec, decision doc, RFC, or PRD, or when a substantial writing task starts.
---

# Doc co-authoring

Three stages: gather context, build the doc section by section, test it with a
reader that has none. Run them in order unless the user asks for freeform.

At the start, describe the three stages in one line each, say the point is a doc
that works when other people read it, and ask whether to use the workflow or
write freeform. If they decline, write freeform.

## Stage 1: Context gathering

Close the gap between what the user knows and what you know before guiding
anything.

Ask the meta questions:

1. What type of document is this?
2. Who is the primary audience?
3. What should the reader do or believe after reading it?
4. Is there a template or format to follow?
5. What constraints apply?

Say they can answer in shorthand.

If they name a template or doc type, ask for the template. If they link a shared
document, read it with the available integration. If they hand over a file, read
it. If they want to edit an existing shared doc, read the current state first and
flag images without alt text, since readers using an agent cannot see them.

Then ask for a dump of everything they have: project background, related
discussions, alternatives rejected and why, team dynamics and past incidents,
timeline pressure, architecture and dependencies, stakeholder concerns. Say not
to organize it, and accept a stream of consciousness, links to channels or
threads, or documents.

Mention connectors or MCP servers that can pull context directly when they are
available. When they are not, say so and offer to work from pasted content.

Track what was learned and what stays unclear. Ask before searching connected
tools for unknown entities.

Once the dump lands, ask 5-10 numbered questions that target the gaps. They can
answer with `1: yes, 2: see #channel, 3: no, backwards compat`.

Exit when you can ask about edge cases and trade-offs without the basics being
explained again. Ask whether more context is coming or it is time to draft.

## Stage 2: Refinement and structure

Build the doc one section at a time.

Agree on 3-5 sections based on the doc type and template. Start with the section
that has the most unknowns, usually the core proposal for a decision doc or the
technical approach for a spec. Leave the summary for last.

Create the scaffold before writing: the file with every heading and a short
placeholder such as `[To be written]`, or an artifact when the environment has
artifacts. Share the link or filename.

For each section:

1. Announce the section and ask 5-10 questions about what belongs in it.
2. Brainstorm 5-20 numbered candidates, including context the user forgot and
   angles not yet raised. Offer to brainstorm more.
3. Take their picks as `Remove 3`, `Combine 11 and 12`. Parse freeform feedback
   into keep, remove, and change.
4. Ask whether anything important is missing.
5. Draft the section into the placeholder.
6. Refine with surgical edits. Never reprint the whole document for one change.

On the first section, ask them to describe changes instead of editing the doc
directly. That is how their voice carries into later sections. Example: "Drop
the second bullet, the intro already covers it."

Note changes they make themselves and apply the same preference later.

After three rounds with no substantial change, ask what could be removed without
losing meaning. Then confirm the section and move on.

At 80% complete, reread the whole document for flow, contradictions, redundancy,
generic filler, and sentences that carry no weight. Report what you find.

## Stage 3: Reader testing

Predict 5-10 questions a reader would ask while trying to use the doc.

With subagents available, run the testing yourself: give each subagent only the
document and one question, then summarize what the reader got right and wrong.
Add a pass for ambiguity, unstated assumptions, and internal contradictions.

Without subagents, hand the user the questions and have them paste the doc into a
fresh chat session, then ask that session the same questions plus the three
checks above. Collect what failed.

Fix the gaps in the affected sections and retest. Stop when a fresh reader
answers consistently and surfaces no new gaps.

## Final review

Tell the user the doc passed reader testing, then ask them to read it once
themselves, check facts, links, and numbers, and confirm it lands the way they
wanted.

If they want a last pass, give it. Otherwise close out with two notes: link the
authoring conversation in an appendix when the history helps, and update the doc
as real readers respond.

## Working rules

- Ask when context is missing. Do not fill gaps with plausible detail.
- Keep brainstorming in chat and the doc clean.
- Follow the document's own voice rules when it has them.
- If the user wants to skip a stage or speed up, name the trade-off and let them
  choose.
