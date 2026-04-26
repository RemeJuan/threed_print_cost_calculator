# G-code test matrix

Use this table to seed parser fixtures and unit tests. Replace placeholder file names with real samples when added.

| slicer | file name | expected time | expected filament | preview available | notes |
|---|---|---:|---|---|---|
| PrusaSlicer | `TODO_prusaslicer_sample.gcode` | `47m 27s` | `2243.91 mm` / `6.47 g` | yes | Footer metadata. Thumbnail block present. |
| OrcaSlicer | `TODO_orcaslicer_sample.gcode` | `23m 46s` | `1182.01 mm` / `3.53 g` | no | Legacy Bambu-style comments. |
| Bambu Studio | `TODO_bambu_sample.gcode` | `6m 39s` | `35.16 mm` / `0.11 g` | no | Header block totals. |
| Cura | `TODO_cura_sample.gcode` | `626 s` | `0.111376 m` | no | `;TIME:` header. |

## Additional cases to add

| slicer | file name | expected time | expected filament | preview available | notes |
|---|---|---:|---|---|---|
| OrcaSlicer | `TODO_orcaslicer_cura_header_sample.gcode` | `3708.97 s` | `6.21 m` | no | Newer Cura-compatible header mode. |
| Cura | `TODO_cura_multimaterial_sample.gcode` | `TODO` | `0.02 m + 0.05 m` | no | Verify sum behavior. |
| Unknown | `TODO_unknown_partial_sample.gcode` | `TODO` | `TODO` | no | Fallback + confirmation path. |

## Assertions worth keeping stable

- Slicer detection result
- Raw extracted keys used
- Normalized time value
- Normalized filament value and unit conversion
- Missing-field behavior
- Preview extraction success/failure without blocking import
