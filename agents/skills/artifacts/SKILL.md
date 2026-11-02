---
name: artifacts
description: Build elaborate multi-component HTML artifacts with React, Tailwind, and shadcn/ui, bundle them to a single HTML file, and publish to Postplan. Use when the user asks for an artifact, interactive report, dashboard, plan, explainer, prototype, or says publish/upload/share via Postplan.
---

# Artifacts

Build a rich HTML artifact with the React + Tailwind + shadcn/ui stack, bundle it into one self-contained HTML file, and publish it to Postplan. The visual language is locked to the dark shadcn theme, so output is predictable across artifacts.

Adapted from Anthropic's `web-artifacts-builder` (Apache-2.0, see `LICENSE.txt` and `NOTICE`). The upstream step that shared the bundle in a Claude conversation is replaced with a Postplan upload.

## Stack

React + TypeScript + Vite (single-file build) + Tailwind CSS + shadcn/ui (40+ components).

## Non-negotiables

- Dark theme only. The generated `src/index.css` sets dark tokens on `:root`. Do not add a theme toggle or light mode.
- Use shadcn/ui components before custom markup, and `cn()` from `@/lib/utils` for classes.
- No external scripts, stylesheets, fonts, or API calls. The bundle must render offline.
- No emoji. Icons come from `lucide-react`.
- Keep the bundle under 4 MiB, Postplan's default limit. Remove unused imports and components if it grows.
- Every claim, number, and label comes from the conversation or the repo. No invented data.

## Workflow

### 1. Initialize

```sh
bash <skill-dir>/scripts/init-artifact.sh <project-name>
cd <project-name>
```

This creates a React + TypeScript project with Tailwind, the shadcn theming system, path aliases, and the full shadcn component set. It uses npm, so no global package manager install.

### 2. Develop

Replace `src/App.tsx` with the artifact. Start from [`assets/App.tsx`](assets/App.tsx), which demonstrates the locked layout: header, numbered sections, cards, table, code block, callout, steps, footer.

Follow [`references/design-system.md`](references/design-system.md). It defines tokens, type, spacing, components, content rules, and the anti-slop checklist.

Import components as:

```tsx
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
```

### 3. Bundle

From the project root:

```sh
bash <skill-dir>/scripts/bundle-artifact.sh
```

This builds with Vite, inlines the JavaScript and CSS into one HTML file via `vite-plugin-singlefile`, writes `bundle.html`, and prints the size. The bundle is the artifact.

### 4. Publish

Auto-publish every artifact. Do not ask whether to upload.

```sh
npx postplan check ./bundle.html --json
npx postplan upload ./bundle.html --description "Artifact title" --json
```

- Read `url` from the receipt and return it.
- `--description` is the short label shown in the dashboard and `postplan list`. Use the artifact title, not the filename.
- Re-uploading the same path updates the same draft. Identical content returns the current version, so retries are safe.
- Never pass, print, or store an API key. If auth fails, tell the user to run `npx postplan auth login` in their terminal.
- If the bundle exceeds 4 MiB, trim dependencies and rebuild before uploading.

### 5. Verify

- `npx postplan check` must pass with no errors.
- A single `sandbox-network` warning is expected: the bundled framework references `fetch`, but the artifact makes no network calls. Treat it as informational and do not add network code to silence it.
- Open the bundle or the published URL when the user asks to see it, or when layout risk is real (wide tables, charts, long code).
- Report the local bundle path and the Postplan URL. State any check that was skipped.

## Content model

Every artifact has, in order:

1. Header: small uppercase label, specific H1, one-sentence lede, metadata badges.
2. Numbered sections, one idea each, separated by a border.
3. Footer: generation date and source.

Rules that keep it from reading as slop:

- The first section is the answer, not background.
- Headings are specific: "Upload path and limits", not "Details".
- Prefer a table over three paragraphs of comparison.
- Use one callout per consequence, not one per section.
- No decorative gradients, hero images, or marketing copy.
- Bold sparingly. If everything is emphasized, nothing is.

## Multi-page

Default to one bundled HTML file. Use a folder only when the user explicitly asks for multiple linked pages; the React app is a single entry point, and Postplan folder uploads require an `index.html` plus relative links.

## References

- [`assets/App.tsx`](assets/App.tsx): starter layout. Copy and replace content.
- [`references/design-system.md`](references/design-system.md): the visual and content contract.
- [`scripts/init-artifact.sh`](scripts/init-artifact.sh): project scaffold.
- [`scripts/bundle-artifact.sh`](scripts/bundle-artifact.sh): single-file bundler.
- shadcn/ui components: <https://ui.shadcn.com/docs/components>
