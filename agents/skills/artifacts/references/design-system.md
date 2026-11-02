# Design system

The canonical source is [`../assets/template.html`](../assets/template.html). Copy it and replace content. Do not invent a new palette, type scale, or component style.

The look is T3 Code's dark workspace: plum-tinted near-black, low-chroma surfaces, one pink accent, crisp 1px lines, mono for metadata and numbers. The content structure follows the standardized ChatGPT-style reading layout: clear hierarchy, generous spacing, scannable sections, progressive disclosure.

## Tokens

| Role | Value | Use |
| --- | --- | --- |
| `--bg` | `#1f1a24` | Page canvas |
| `--surface` | `#29232d` | Cards, callouts, details |
| `--surface-2` | `#2c2631` | Table headers, raised rows |
| `--surface-3` | `#362d3d` | Hover borders |
| `--line` | `#322028` | Component borders |
| `--line-soft` | `#27242c` | Section dividers |
| `--text` | `#f9f8fb` | Headings, primary body |
| `--text-2` | `#e7d0dd` | Secondary body |
| `--text-3` | `#a898b3` | Metadata, labels |
| `--accent` | `#db2777` | Focus, indices, callout edge |
| `--accent-fill` | `#a3004c` | Filled buttons only |
| `--link` | `#f472b6` | Inline links |
| `--code-bg` | `#171018` | Code surface |
| `--code-fg` | `#d8c3ef` | Code text |
| `--ok` | `#6ee7b7` | Verified / passed |
| `--warn` | `#fbbf24` | Caution |
| `--danger` | `#fb7185` | Blocked / failed |

Do not add new hues. Status colors are the only exception and are used at low frequency.

## Type

- Body: system sans, `16px / 1.65`.
- Measure: `760px` for documents, `1040px` for wide tables and dashboards.
- H1: `clamp(30px, 5vw, 44px)`, weight `650`, tracking `-0.025em`, `text-wrap: balance`.
- Lede: `18px / 1.6`, `--text-2`.
- H2: `23px / 1.3`, weight `620`.
- H3: `16px`, weight `600`.
- Metadata, labels, numbers: mono, `10.5–12px`, uppercase + tracking for labels.
- Numbers in tables and stats: `font-variant-numeric: tabular-nums`.

Never center long prose. Never set body text below `14px`. Never use more than two font families.

## Spacing and shape

- 4px base. Common steps: `8, 12, 14, 18, 24, 30, 48, 72`.
- Section rhythm: `30px` vertical padding plus a `1px` divider.
- Radius: `10px` for cards and containers, `7px` for small controls, `999px` for chips.
- No shadows. Depth comes from value contrast and 1px borders.

## Layout

Use one of five predictable shapes:

1. **Document**: hero, numbered sections, prose, callouts. Best for explanations, plans, specs.
2. **Dashboard**: header, stat row, two-column cards, table. Best for status and metrics.
3. **Comparison**: header, table or two equal columns, recommendation callout. Best for decisions.
4. **Walkthrough**: header, numbered steps, code blocks with copy, details for asides. Best for how-tos and reviews.
5. **Brief**: header, summary cards, one table, next actions. Best for short updates.

Pick one. Do not mix dashboard chrome into a document.

## Components

- **Callout**: one idea, max two sentences. Variants default, warn, ok. Never stack more than two per section.
- **Card grid**: two or three columns. Every card needs a label, title, and one short paragraph. Equal-height content.
- **Stats**: three values maximum per row. Label states the unit or source.
- **Table**: sentence-case cells, uppercase mono headers, right-align numeric columns, no zebra stripes.
- **Code**: always with a language label and copy button. Keep lines under 90 characters; horizontal scroll is acceptable.
- **Steps**: one action per step, imperative title, one line of context.
- **Details**: for optional depth only. Never hide the conclusion.

## Content rules

- Lead with the answer. First section is a summary, not background.
- One H2 per idea. If a section has two topics, split it.
- Prefer concrete nouns and numbers over adjectives.
- No emoji. Inline SVG only, 16px, 1.5px stroke.
- No lorem ipsum, no placeholder marketing copy, no "unlock", "seamless", "revolutionize".
- No hero images, no decorative gradients beyond the single top accent glow in the template.
- Code, IDs, paths, timestamps, and metrics are always mono.

## Motion

Interactive-only. `120ms ease` for color and border changes. No entrance animations, no parallax, no scroll effects. Honor `prefers-reduced-motion`.

## Accessibility

- Body contrast at least 4.5:1. Use `--text` or `--text-2` for prose.
- Visible focus ring on every interactive element.
- Real semantic elements: `section`, `h2`, `table`, `ol`, `details`, `button`.
- Buttons are `type="button"`; copy buttons announce state in text.
- Do not remove the reduced-motion block.

## Print

The template includes a light print stylesheet. Keep it. Documents get printed and PDFed.
