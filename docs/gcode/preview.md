# Preview handling

## Extraction

- Parser scans comment blocks for thumbnail markers.
- Stores preview metadata: format, width, height, safety flag.
- Stores image bytes only when embedded data decodes cleanly.

## UI behavior

- Summary shows a `Preview` field.
- Valid preview shows `View`.
- Preview may not be available depending on slicer.
- UI shows `Not available` when missing.
- `View` opens a modal with the thumbnail image.
- Broken image decode fails inside the modal, not the import flow.

## Slicer support

- Bambu / Orca: thumbnails common in lineage exports.
- PrusaSlicer: thumbnails common; may be small.
- Cura: preview rare; usually absent unless post-processed.

## Known limits

- No inline preview.
- No toolpath rendering.
- Small thumbnails are common.
- Cura preview is usually missing.

## Future ideas

- Optional generated preview for unsupported files.
- Keep this experimental; do not change current import behavior.
