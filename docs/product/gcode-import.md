# G-code import (in-progress)

Decision doc: [2026-04-gcode-import](../decisions/2026-04-gcode-import.md)

## Context
- G-code import was previously rejected and later revived with phased scope.

## Decisions
- Implement in phases.
- Initial phase started with upload + preview, then expanded into calculator application and feedback capture.

## Tradeoffs
- Limited format/support in early milestone.
- Faster delivery and earlier feedback loop.

## Rejected Ideas
- Full parser in first release.
- Deep slicer integrations upfront.

## Implementation Notes
- Candidate library noted: `gcode_view`.
- TODO: verify in code whether this library is still the active choice.
- Current app shell routes the import page from the header for premium users.
- The reusable import button defaults to `calculator`, but is not wired into the current app shell.

## Analytics
- Funnel now tracked as `gcode_import_opened` -> `gcode_import_started` -> `gcode_file_selected` -> `gcode_parse_*` -> `gcode_preview_viewed` -> `gcode_import_success` -> `gcode_flow_completed` / `gcode_import_abandoned`.
- Start attribution currently uses `source` from the live header caller; the reusable button defaults to `calculator`.
- File select logs only the extension as `file_type`; no filename, path, or G-code content is logged.
- Success logs low-cardinality flags for print time, filament usage, and preview.
- `gcode_apply_to_calculator` exists as a helper but is not currently emitted by the page flow.

## Known Issues
- Feature is still partial for parser coverage and preview handling across slicers.
- TODO: verify current parser/preview limitations by format and size.

## TODOs
- Validate file formats.
- Expand parser edge-case coverage.
- Run beta testing.
