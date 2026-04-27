# Edge cases

## Missing metadata

- File has valid toolpath but no slicer summary comments.
- Strategy: import detected values only, leave missing fields empty, ask user to confirm.

## Partial files

- Upload may be truncated before footer metadata.
- Important for Prusa-style files where summary may be near end.
- Strategy: parse whatever exists, mark result partial, require confirmation.

## Unknown slicer

- No known slicer marker or keys mismatch all known patterns.
- Strategy: run generic fallback patterns (`;TIME:`, `;Filament used:`, thumbnail markers), label slicer unknown, confirm with user.

## Multiple materials

- Cura may emit comma-separated filament values.
- Other slicers may expose totals plus per-extruder data.
- Strategy: prefer total when explicit. If only per-material values exist, sum them and keep note for UI/tests.

## Unit inconsistencies

- Time may be seconds or human-readable text.
- Filament may be mm, m, g, or cm3.
- Strategy: normalize into internal canonical values, preserve source unit during debugging/tests.

## Corrupt or large files

- Embedded thumbnails or large config blocks can bloat file size.
- Corrupt lines may break naive full-file regex parsing.
- Strategy: stream or bounded-scan comments first, cap preview extraction size, fail soft on malformed image blocks.

## Preview image absent or unsupported

- Many files will not include portable thumbnail comments.
- Strategy: preview optional. Never block import on missing preview.

## Broken preview metadata

- Preview metadata present but dimensions too small or decode fails.
- Example: 32x32 thumbnail with invalid payload.
- Strategy: show View only when valid, hide or disable broken preview, fail soft.

## Fallback rule

When parser confidence not high:

1. extract best-effort values
2. show detected source + parsed fields
3. require user confirmation before save/apply
