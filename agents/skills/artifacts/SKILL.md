---
name: artifacts
description: Build and publish beautiful single-file HTML artifacts (plans, explainers, reports, dashboards, comparisons, walkthroughs). Use when the user asks for an artifact, shareable page, visual plan, draft, report, dashboard, or says publish/upload/share via Postplan. Copies a fixed T3-dark template, then uploads to Postplan automatically.
---

# Artifacts

Produce a polished, self-contained HTML artifact and publish it to Postplan. The artifact is a document first and a web page second: readable, scannable, and predictable, not a landing page.

The look is fixed. [`assets/template.html`](assets/template.html) is the only starting point, and [`references/design-system.md`](references/design-system.md) is the contract. Do not redesign per artifact. Predictability is the feature.

## Non-negotiables

- One `.html` file. No build step, no framework, no CDN, no external fonts, images, scripts, or APIs. It must render from `file://`.
- Copy `assets/template.html`. Keep its tokens, type scale, spacing, components, and print styles. Replace content, not the system.
- No emoji. Inline SVG only.
- No hero images, illustration, decorative gradient sections, glassmorphism, or animation beyond 120ms interaction transitions.
- Every claim, number, and label comes from the conversation or the repo. No invented data, no lorem ipsum.
- Keep it under 4 MiB. Postplan's default limit is 4 MiB (16 MiB with a flag). Folder uploads allow 50 pages.

## Workflow

1. **Pick one shape** from `references/design-system.md`: document, dashboard, comparison, walkthrough, or brief. If the request mixes shapes, pick the dominant one and move the rest into a table or `details` block.
2. **Copy the template** to the output path, then replace the title, eyebrow, lede, meta chips, and sections. Delete unused sections; do not leave placeholders.
3. **Write for scanning.** Answer first. One H2 per idea. Short paragraphs. Concrete numbers. Put optional depth in `details`.
4. **Validate.** Run the check command below. Fix every reported issue.
5. **Publish.** Run the upload command below. Return the printed URL.
6. **Report.** Give the local path and the Postplan URL. State anything that was not verified.

Output path: `./artifacts/<kebab-topic>.html` by default. Use a folder only when the artifact genuinely needs multiple linked pages: `./artifacts/<kebab-topic>/index.html`, with relative links such as `href="details.html"`.

## Publishing

Postplan is the transport. Auth is stored once by the CLI in `~/.postplan`.

```sh
npx postplan check ./artifacts/topic.html --json
npx postplan upload ./artifacts/topic.html --description "Short label" --json
```

Folder:

```sh
npx postplan check ./artifacts/topic --json
npx postplan upload ./artifacts/topic --description "Short label" --json
```

Rules:

- **Auto-publish every artifact.** The user asked for this. Do not ask whether to upload.
- `--description` is the short human label shown in the dashboard and `postplan list`. Use the artifact title, not the filename.
- `--json` prints a receipt. Read `url` from it and put that URL in the reply.
- Re-uploading the same path updates the same draft. Identical content returns the current version, so retries are safe.
- Use `--slug` only when the user asks for a custom URL. `--draft` moves an existing draft to a slug.
- Never pass, print, or store an API key. If auth fails, stop and tell the user to run `npx postplan auth login` (or `npx postplan auth set` themselves) in their terminal.
- If the check fails offline, the CLI says so; fix markup issues it reports before uploading anyway.

## Content model

Every artifact has, in order:

1. Top bar: brand mark, artifact label, generated date.
2. Hero: eyebrow (genre), H1 (specific claim, not "Overview"), lede (what and why, two sentences max), meta chips (scope, status, verification).
3. Numbered sections, each with one idea.
4. Footer: generation date, source, skill name.

Rules that keep it from reading like slop:

- The first section is the answer, not background. A reader who stops there still knows the conclusion and next action.
- Headings are specific: "Upload path and limits", not "Details".
- No sentence that could appear in any document. Cut "In today's fast-paced world", "It's important to note", "Let's dive in".
- Prefer a table over three paragraphs of comparison.
- Prefer a callout for one consequence, not for every section.
- Bold sparingly. If everything is emphasized, nothing is.
- Numbers get units and sources.

## Verification

- `npx postplan check <path> --json` must pass before upload.
- Open the file locally when the user asks to see it, or when layout risk is real (wide tables, long code, many cards). Do not block delivery on a browser check.
- Confirm the uploaded URL loads and the artifact title appears.
- Say explicitly if a visual check was skipped.

## References

- [`assets/template.html`](assets/template.html): canonical artifact. Copy this.
- [`references/design-system.md`](references/design-system.md): tokens, type, spacing, components, content rules, accessibility.
