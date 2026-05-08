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
- File validation now accepts `.gcode`, `.gco`, and `.nc` when the payload looks text-like.
- Android now uses a SAF picker bridge instead of `file_selector` byte payload transfer. The platform layer returns URI metadata plus a cache path, and Dart reads the file from disk.
- Android `.bin` and other unknown/octet-stream picks are sniffed from the first 64 KiB for common G-code markers before rejection.
- Imports reject clearly binary payloads before parsing and reject files above the 50 MiB guard before parse work starts.
- Validation/error copy now uses the selected display filename rather than cached path aliases.
- Preview summary stays non-blocking for low-resolution thumbnails; thumbnails under 128 px render inline with nearest-neighbour scaling and show `Preview · {W}×{H}`.
- Missing previews now use `No preview` copy in the summary.

## Analytics
- Funnel now tracked as `gcode_import_opened` -> `gcode_import_started` -> `gcode_file_selected` -> `gcode_parse_*` -> `gcode_preview_viewed` (optional) -> `gcode_import_success` -> `gcode_flow_completed`; `gcode_import_abandoned` only fires on dispose if the flow was not completed.
- Start attribution currently uses `source` from the live header caller; the reusable button defaults to `calculator`.
- File select logs only the extension as `file_type`; no filename, path, or G-code content is logged.
- Success logs low-cardinality flags for print time, filament usage, and preview.
- `gcode_apply_to_calculator` exists as a helper but is not currently emitted by the page flow.

## Instrumentation Notes
- `gcode_import_success` does not include `slicer`, `parse_status`, or `file_size_bucket`, so it cannot be used alone to segment funnel context.
- `gcode_flow_completed` clears the open-flow timer immediately, so abandon logging should never follow a completed apply path.
- Android and iOS share the same downstream analytics once a file is picked; only the file picker metadata source differs.

## Known Issues
- Feature is still partial for parser coverage and preview handling across slicers.
- Android picker support still depends on content sniffing heuristics for `.bin` and other unknown/octet-stream files, so unusual G-code exports without common markers may still be rejected.
- TODO: verify current parser/preview limitations by slicer, preview encoding, and large-file edge cases.

## TODOs
- Expand parser edge-case coverage.
- Run beta testing.
