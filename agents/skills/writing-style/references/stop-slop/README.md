# Slop audit

Eliminate predictable AI writing patterns from prose. Full checklist for a dedicated pass; `writing-style` is the default voice.

## Core Rules

1. **Cut filler phrases.** Remove throat-clearing openers, emphasis crutches, and all adverbs. See [phrases.md](phrases.md).

2. **Break formulaic structures.** Avoid binary contrasts, negative listings, dramatic fragmentation, rhetorical setups, false agency. See [structures.md](structures.md).

3. **Use active voice.** Every sentence needs a human subject doing something. No passive constructions. No inanimate objects performing human actions ("the complaint becomes a fix").

4. **Be specific.** No vague declaratives ("The reasons are structural"). Name the specific thing. No lazy extremes ("every," "always," "never") doing vague work.

5. **Put the reader in the room.** No narrator-from-a-distance voice. "You" beats "People." Specifics beat abstractions.

6. **Vary rhythm.** Mix sentence lengths. Two items beat three. End paragraphs differently. No em dashes.

7. **Trust readers.** State facts directly. Skip softening, justification, hand-holding.

8. **Cut quotables.** If it sounds like a pull-quote, rewrite it.

9. **Say what it does, not how it feels.** "The database stays close at hand" names a feeling. Name the mechanism or a number instead: "`.toSQL()` returns the exact string sent to the database". If you cannot restate a sentence as a concrete instruction, fact, or number, cut it. If it could appear unchanged in another project's docs, it says nothing about this one.

10. **Prefer the plain word and the whole sentence.** "Utilize" and "leverage" become "use". Cut abstract metaphor nouns (substrate, wedge, vector, harness, surface, paradigm, north star) for the concrete word. Repeat one noun instead of cycling synonyms. Avoid "from X to Y" ranges that are not on a real scale. Write whole sentences with articles and verbs, not symbol-speak like "Parser rejects bad date -> exit 2, no write".

11. **Strip formatting tells.** Sentence-case headings, straight quotes, no decorative emoji, no bold labels that merely restate the line. Use a colon only before a list or example, never as a mid-sentence connector.

## Quick Checks

Before delivering prose:

- Any adverbs? Kill them.
- Any passive voice? Find the actor, make them the subject.
- Inanimate thing doing a human verb ("the decision emerges")? Name the person.
- Sentence starts with a Wh- word? Restructure it.
- Any "here's what/this/that" throat-clearing? Cut to the point.
- Any "not X, it's Y" contrasts? State Y directly.
- Three consecutive sentences match length? Break one.
- Paragraph ends with punchy one-liner? Vary it.
- Em-dash anywhere? Remove it.
- Vague declarative ("The implications are significant")? Name the specific implication.
- Narrator-from-a-distance ("Nobody designed this")? Put the reader in the scene.
- Meta-joiners ("The rest of this essay...")? Delete. Let the essay move.
- Superficial -ing clause ("highlighting...", "ensuring...")? Delete or back it with a real source.
- "-ing" or participle phrase tacked onto a sentence to fake depth? Split it or cut it.
- "From X to Y" where X and Y are not on a scale? List the items directly.
- One idea named four ways in a paragraph? Pick one word and repeat it.
- Bold label plus colon restating the bullet? Convert to prose.
- Colon in the middle of a sentence? Rewrite without it.
- Title-case heading, curly quotes, or emoji in a heading? Fix it.
- Sentence that has to be decoded, not read? Split it into two.

## Scoring

Rate 1-10 on each dimension:

| Dimension | Question |
|-----------|----------|
| Directness | Statements or announcements? |
| Rhythm | Varied or metronomic? |
| Trust | Respects reader intelligence? |
| Authenticity | Sounds human? |
| Density | Anything cuttable? |

Below 35/50: revise.

## Examples

See [examples.md](examples.md) for before/after transformations.

## License

MIT. Portions adapted from cursor/plugins pstack unslop. Copyright (c) 2026
Lauren Tan. See [../../../ATTRIBUTION.md](../../../ATTRIBUTION.md).
