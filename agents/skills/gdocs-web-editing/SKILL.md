---
name: gdocs-web-editing
description: Edits a Google Doc through the browser UI when no Docs connector or API is available. Covers reading a doc for verification, finding and positioning in the canvas editor, replacing text and images, tab and session handling, safety limits, and the post-edit checklist. Use when asked to change text or images in a docs.google.com document without a connector.
---

# Editing Google Docs in the browser

## When to use

Use this when a Google Doc has to change and the docs connector is unavailable, so
the only path is the editor UI at `docs.google.com/document/d/<id>/edit`.

Not for creating documents through the docs connector. If a connector is
available, use it.

The editor renders pages to canvas, so normal DOM text extraction finds nothing.
Every read, position, and verification step below exists because of that.

## Read before edit

- Open `https://docs.google.com/document/d/<id>/mobilebasic`. It renders text,
  headings, image order, natural image dimensions, and full image `src` values.
  Treat it as the source of truth for before and after checks.
- Extract the block sequence from that page: heading level and text, paragraph
  order, and each image with its position and `src`.
- Download each stored image from its `lh7-rt` URL and verify type, byte count,
  and pixel dimensions with `file` and `identify`. For GIFs, check frame count and
  duration with `ffprobe`.
- Skip screenshots. Frames often fail to render. Prefer the mobilebasic HTML and
  DOM reads.

## Finding and positioning

All text fields in the editor take this pattern. The native setter bypasses the
editor's value tracker, so the dispatched event is not ignored:

```js
const setValue = Object.getOwnPropertyDescriptor(
  HTMLInputElement.prototype, "value",
).set;
const type = (el, text) => {
  setValue.call(el, text);
  el.dispatchEvent(new Event("input", { bubbles: true }));
};
```

Find bar (Ctrl+F):

- Clear and fill the input with `type(input, "text")`.
- Send one real keystroke after that. The "1 of 1" counter appears only after real
  input, so the counter is the confirmation that search ran.
- The matched text is not exposed through `window.getSelection`. Do not try to
  read the match location that way.

Coordinates:

- Read page geometry from the canvas page element rects.
- Coordinates do not survive scrolling. PageDown moves the viewport anchor.
- Never assume an image or paragraph sits at a coordinate from an earlier step.
  Re-measure immediately before every click.

## Replace text

1. Press Ctrl+H to open Find and Replace.
2. Fill the Find and Replace fields with `type(field, text)`.
3. Click Replace or Replace all. In a 1280x800 viewport the buttons sit near
   (504, 562) and (596, 562). At other viewport sizes, locate them again.
   A programmatic `.click()` on the Material button works.

Rules that prevent damage:

- Use full, unique sentences as find strings. Short strings match inside other
  words and inside headings.
- For citation renumbering, process numbers in ascending order when shifting the
  whole list down by one. Otherwise use enough surrounding context to make each
  match unique. Skipping this cascades replacements into text already changed.
- Replace cannot create paragraph breaks. A real newline is stripped, and a
  literal `\n` is inserted as two characters. Plan edits to fit existing
  paragraphs, then search for literal escape artifacts and remove them.
- Re-read the paragraph after each replacement. Do not batch a long replace list
  and verify only at the end.

## Replace images

1. Find the paragraph that precedes the target image, using the find bar, then
   right-click it.
2. Check the context menu for "Replace image". If it is absent, the click landed
   on text or the wrong block. Re-measure and retry.
3. Choose Replace image, then By URL.
4. Fill the URL field with `type(field, url)`. Its placeholder is
   "Paste URL of image...". Press Enter.
5. Click REPLACE in the preview dialog.
6. Verify on mobilebasic that the image `src` changed, then download it and confirm
   bytes, type, and dimensions. A new `src` alone is not proof that the intended
   asset landed.

## Tabs and sessions

- Preview tabs can change owner between sessions. Open a fresh tab per task and
  act immediately instead of reusing a tab from earlier.
- Keep exactly one tab performing writes. Read from other tabs if needed, but
  never let two editor tabs write.
- When a screenshot is blank, read the DOM or mobilebasic. Do not retry the
  screenshot loop.

## Safety rules

- Never send Ctrl+A in the document and never make a document-wide selection. A
  previous subagent erased a document this way.
- Do not let a subagent edit the document. Give subagents a read-only or
  asset-generation brief, or keep all edits in the main thread.
- Keep content edits serial. Do not run a style pass and a content pass in
  parallel, even on separate ranges.
- Make one edit, then verify. Stop and report if the doc content does not match
  what was read before the edit.

## Verification checklist

Run this after every edit against a fresh mobilebasic read:

- Heading count and order match the intent.
- Image count, order, dimensions, and media type match the intent.
- Reference list numbering is contiguous and every in-text citation number
  matches an entry.
- No literal `\n`, no doubled spaces at glue points where a replaced phrase meets
  surrounding text.
- No stale terms. If a term changed in prose, check captions, figures, and
  headings too.
- Downloaded images match the intended asset by bytes and dimensions.

## Proposal voice

Applies when the document is a design proposal.

- Descriptive present tense. State what the design does.
- No "must", "should", "do not", or imperative steps. State decisions instead of
  requirements.
- No semicolons and no em dashes. Use periods.
- Plain words over jargon.
- Verify every technical claim against a source before keeping it. Drop claims
  that cannot be sourced.
