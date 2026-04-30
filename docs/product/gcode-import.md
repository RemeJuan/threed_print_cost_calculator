# G-code import (in-progress)

Decision doc: [2026-04-gcode-import](../decisions/2026-04-gcode-import.md)

## Context
- G-code import was previously rejected and later revived with phased scope.

## Decisions
- Implement in phases.
- Initial phase limited to upload + preview.

## Tradeoffs
- Limited format/support in early milestone.
- Faster delivery and earlier feedback loop.

## Rejected Ideas
- Full parser in first release.
- Deep slicer integrations upfront.

## Implementation Notes
- Candidate library noted: `gcode_view`.
- TODO: verify in code whether this library is still the active choice.

## Analytics
- Funnel now tracked as `gcode_import_opened` -> `gcode_import_started` -> `gcode_file_selected` -> `gcode_import_success` / `gcode_import_abandoned`.
- Start attribution uses `source` values: `calculator`, `header`, `whats_new`.
- File select logs only the extension as `file_type`; no filename, path, or G-code content is logged.
- Success logs low-cardinality flags for print time, filament usage, preview, and Pro state.

## Known Issues
- Feature is incomplete and not yet end-to-end.
- TODO: verify in code current parser/preview limitations by format and size.

## TODOs
- Build upload flow.
- Add preview UI.
- Validate file formats.
- Run beta testing.
