# G-code import overview

## What G-code is

G-code is line-oriented machine instruction output from slicers. It often includes slicer-specific comment metadata before or after movement commands.

## Why parse it

Goal: prefill calculator inputs from exported print files instead of asking user to retype them.

Fields in scope:

- print time
- filament usage: length and/or weight
- layer height when available
- slicer identification
- preview image when embedded

Feature scope:

- import local G-code files
- extract metadata only
- show embedded preview as static thumbnail on demand

## Product constraints

- Offline-first: parse locally, no network dependency
- Deterministic: same file must produce same extracted values every time
- Metadata-first: prefer slicer comments over heuristic model analysis
- Preview is thumbnail-only; no toolpath rendering
- Parsing issues are handled silently; missing values are shown at field level
- The UI prioritises clarity over completeness. Missing data is shown inline rather than via global alerts.

## Non-goals

- No G-code rendering
- No G-code editing
- No printer simulation
- No geometry reconstruction
- No G-code storage; import is ephemeral and only derived values persist
- No inline preview; preview opens from the on-demand View action

## Parse strategy

1. Detect slicer from known comment markers.
2. Extract known metadata keys for that slicer.
3. Normalize units into app-friendly values.
4. Fall back to partial import plus user confirmation when metadata missing or ambiguous.

## Doc map

- [PrusaSlicer parser notes](./parsers/prusaslicer.md)
- [OrcaSlicer parser notes](./parsers/orcaslicer.md)
- [Bambu Studio parser notes](./parsers/bambu.md)
- [Cura parser notes](./parsers/cura.md)
- [Preview handling](./preview.md)
- [Edge cases](./edge_cases.md)
- [Test matrix](./test_matrix.md)
