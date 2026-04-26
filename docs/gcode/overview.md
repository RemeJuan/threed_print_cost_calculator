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

## Product constraints

- Offline-first: parse locally, no network dependency
- Deterministic: same file must produce same extracted values every time
- Metadata-first: prefer slicer comments over heuristic model analysis

## Non-goals

- No G-code rendering
- No G-code editing
- No printer simulation
- No geometry reconstruction

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
- [Edge cases](./edge_cases.md)
- [Test matrix](./test_matrix.md)
