---
name: figma
description: "Use for any Figma work: implementing a Figma design as code, writing or updating screens in Figma, design systems, tokens, components, FigJam diagrams, Figma specs, and creating new Figma files. Trigger when the task involves a Figma URL or node ID, 'implement this Figma design', 'build this screen in Figma', design system, tokens, FigJam, diagram, spec, or a new Figma file. Routes to the matching playbook plus shared quality, alignment-audit, and council rules."
---

# Figma

One entry point for Figma work. Read the matching guide before the first Figma tool call, then load only the references that guide points to.

## Route

| Task | Read |
|---|---|
| Implement a Figma design as code | `references/design-to-code/GUIDE.md` |
| Create or update screens in Figma | `references/generate-design/GUIDE.md` |
| Build tokens, components, variants, or theming | `references/generate-library/GUIDE.md` |
| Create a new Design, FigJam, or Slides file | `references/create-new-file/GUIDE.md` |
| Architecture or flow diagrams in FigJam | `references/generate-diagram/GUIDE.md` |
| Hybrid FigJam editing with `use_figma` | `references/use-figjam/GUIDE.md` |
| Read, create, or edit Figma specs | `references/spec/GUIDE.md` |
| Plugin API rules for `use_figma` | `references/use/GUIDE.md` |

**Mandatory:** read `references/use/GUIDE.md` before any `use_figma` call. Load the task guide first, then the API guide.

## Shared rules

- Use the project's design system: tokens, components, text styles, effect styles. No hardcoded colors, spacing, or type.
- Keep the deliverable editable. Never replace components or text with a flattened screenshot.
- Do not invent dependencies, content, or architecture. Omit and disclose when information is missing.
- Load references on demand. Read only the section needed for the current step.
- `references/use/references/plugin-api-standalone.d.ts` is about 403KB. Never read it wholesale; grep the symbol or type you need.
- Before delivery, run the pixel-level audit in `references/alignment-audit.md`. Fix deviations before asking for review.
- For high-stakes work, run the council with the rendered image, the coordinate export, and the OCD alignment prompt from `references/alignment-audit.md`.
- Stop after the skill's generation budget. Report what was not verified.

## Reference layout

Every playbook keeps its own `references/` directory, so its internal links still resolve. The shared audit lives at `references/alignment-audit.md`. The old design-to-code playbook lives at `references/design-to-code/GUIDE.md`.
