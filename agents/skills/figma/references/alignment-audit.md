# Pixel-level alignment audit

Vision models cannot measure pixels. Use Figma node coordinates as the source of truth, compute the deviations, then give both the image and the numeric report to the council.

## When

Run this before any council review and before delivery on a reference-grade board.

## Collect

Run a read-only `use_figma` call on the board frame and return the nodes:

```js
const frame = await figma.getNodeByIdAsync('<frame-id>');
if (!frame) throw new Error('frame not found');
return frame.children.map(n => ({
  id: n.id,
  type: n.type,
  name: n.name,
  text: n.type === 'TEXT' ? n.characters : undefined,
  fontSize: n.type === 'TEXT' ? n.fontSize : undefined,
  x: +n.x.toFixed(2),
  y: +n.y.toFixed(2),
  w: +n.width.toFixed(2),
  h: +n.height.toFixed(2)
}));
```

Group the rows and stacks from the coordinates. Do not estimate from the image.

## Full export for the council

The council must receive a machine-readable export, not only the image. Export every descendant with absolute bounds so grouped nodes can still be compared:

```js
const frame = await figma.getNodeByIdAsync('<frame-id>');
if (!frame) throw new Error('frame not found');
const nodes = frame.findAll(n => n.type !== 'PAGE' && n.type !== 'GROUP');
return {
  frame: { id: frame.id, name: frame.name, w: frame.width, h: frame.height },
  nodes: nodes.map((n, i) => {
    const b = n.absoluteBoundingBox;
    return {
      id: n.id,
      type: n.type,
      name: n.name,
      parent: n.parent ? n.parent.id : null,
      z: i,
      text: n.type === 'TEXT' ? n.characters : undefined,
      fontSize: n.type === 'TEXT' ? n.fontSize : undefined,
      fontName: n.type === 'TEXT' ? n.fontName : undefined,
      lineHeight: n.type === 'TEXT' ? n.lineHeight : undefined,
      letterSpacing: n.type === 'TEXT' ? n.letterSpacing : undefined,
      align: n.type === 'TEXT' ? n.textAlignHorizontal : undefined,
      x: b ? +b.x.toFixed(2) : null,
      y: b ? +b.y.toFixed(2) : null,
      w: b ? +b.width.toFixed(2) : null,
      h: b ? +b.height.toFixed(2) : null,
      relative: { x: +n.x.toFixed(2), y: +n.y.toFixed(2), w: +n.width.toFixed(2), h: +n.height.toFixed(2) },
      cornerRadius: n.cornerRadius === undefined ? null : n.cornerRadius,
      dashPattern: n.dashPattern || null,
      strokeWeight: n.strokeWeight === undefined ? null : n.strokeWeight,
      rotation: n.rotation === undefined ? null : n.rotation
    };
  })
};
```

Save it as `alignment-export.json` beside the screenshot. Include that path in the council brief. The council must use `nodes[].x/y/w/h` for every measurement and cite node IDs; the image is only for visual artifacts such as hierarchy and legibility.

`use_figma` returns at most 48KB. If the full export exceeds that, drop `name`, `parent`, `z`, `relative`, font details, and style fields; keep `id`, `type`, `text`, `fontSize`, `align`, and absolute `x/y/w/h`. That compact export is enough for measurement. If it still exceeds the limit, split the export by band or right-column container.

Scope derived checks to containers. For a band, filter cards to the band's x-range; do not include the right column:

```js
const cards = nodes.filter(n => n.type === 'RECTANGLE' && n.w >= 160 && n.w <= 360 && n.h >= 40 && n.h <= 110);
const bandCards = cards.filter(c => c.x >= band.x && c.x + c.w <= band.x + band.w);
```

## Checks

- **Shared edges:** title, subtitle, group labels, and card columns share one left edge. 0px tolerance.
- **Card rows:** identical widths and gutters in a row; equal left and right margins. 0px tolerance.
- **Band anatomy:** header height, header-to-card gap, and bottom padding are the same in every band. 0-1px tolerance.
- **Right-column stack:** same left and right edges; gaps equal to the band gap. 0-1px tolerance.
- **Text:** title and subtitle insets are identical per card; text box center matches the card center within 1px.
- **Icons:** badge inset from the card edge is identical on every card. 0px.
- **Arrows:** every endpoint is inside the intended node bounds; no shaft crosses a label, a band edge, or another node. 0px.
- **Grid:** every spacing value sits on the board's base grid, usually 4px; 2px is acceptable for a dense board. Flag values that break the chosen grid.
- **Canvas margins:** left equals right; top equals bottom within 1px.

## Council brief

Include:

- the rendered image and its exact dimensions
- the path to `alignment-export.json`
- the coordinate report
- the failed checks with measured deltas

Use this prompt:

> You are an alignment auditor with clinical OCD. A 1px deviation is a defect. You have the rendered image, a coordinate export, and a derived report. Read `alignment-export.json` and use its absolute `x/y/w/h` values for every measurement; never estimate pixels from the image. Cite node IDs for every claim. If a measurement is missing from the export, say so instead of inventing it. List every deviation as: element A vs element B, property, measured value, expected value. Reject any layout where shared edges differ, card widths or gutters vary, band padding varies, labels cross shafts or boundaries, or spacing is not on the 4px grid. Score /10. Do not give generic design advice.

## Fix order

1. Shared edges and card grid
2. Band anatomy
3. Right-column rhythm
4. Text and icon insets
5. Arrows and labels
6. Outer margins
