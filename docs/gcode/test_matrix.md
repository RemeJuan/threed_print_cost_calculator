# G-code parser test matrix

Populated using real beta test files.

| Case | Fixture | Expected slicer | Extracted values | Preview availability | Correctness notes |
|---|---|---|---|---|---|
| PrusaSlicer documented headers | `test/fixtures/gcode/prusa_slicer_basic.gcode` | PrusaSlicer | `estimated printing time (normal mode)`, `filament used [mm]`, `filament used [g]`, `layer_height`, `thumbnail_QOI begin` | available | valid embedded thumbnail |
| OrcaSlicer Cura-compatible metadata | `test/fixtures/gcode/orca_slicer_basic.gcode` | OrcaSlicer | `TIME`, multi-value `Filament used`, `Layer height` | unavailable | no thumbnail in fixture |
| Bambu Studio totals | `test/fixtures/gcode/bambu_studio_basic.gcode` | Bambu Studio | `total estimated time`, `total filament length [mm]`, `total filament weight [g]`, `layer_height` | unavailable | no thumbnail in fixture |
| Cura seconds + metres | `test/fixtures/gcode/cura_basic.gcode` | Cura | `TIME`, metre-based `Filament used`, `Layer height` | unavailable | preview uncommon |
| Unknown slicer partial import | `test/fixtures/gcode/unknown_basic.gcode` | unknown | duration + filament weight without supported slicer marker | unavailable | unknown slicer, partial metadata |
| Missing metadata fallback | `test/fixtures/gcode/missing_metadata.gcode` | unknown | no supported metadata | unavailable | unknown slicer, missing duration, missing filament |
| Unsafe preview metadata | `test/fixtures/gcode/unsafe_preview.gcode` | unknown | preview header only | available | preview rejected as unsafe |
