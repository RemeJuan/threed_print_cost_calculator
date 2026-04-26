# G-code parser test matrix

| Case | Fixture | Expected slicer | Metadata covered | Warnings |
|---|---|---|---|---|
| PrusaSlicer documented headers | `test/fixtures/gcode/prusa_slicer_basic.gcode` | PrusaSlicer | `estimated printing time (normal mode)`, `filament used [mm]`, `filament used [g]`, `layer_height`, `thumbnail_QOI begin` | none |
| OrcaSlicer Cura-compatible metadata | `test/fixtures/gcode/orca_slicer_basic.gcode` | OrcaSlicer | `TIME`, multi-value `Filament used`, `Layer height` | missing filament weight |
| Bambu Studio totals | `test/fixtures/gcode/bambu_studio_basic.gcode` | Bambu Studio | `total estimated time`, `total filament length [mm]`, `total filament weight [g]`, `layer_height` | none |
| Cura seconds + metres | `test/fixtures/gcode/cura_basic.gcode` | Cura | `TIME`, metre-based `Filament used`, `Layer height` | missing filament weight |
| Unknown slicer partial import | `test/fixtures/gcode/unknown_basic.gcode` | unknown | duration + filament weight without supported slicer marker | unknown slicer, partial metadata |
| Missing metadata fallback | `test/fixtures/gcode/missing_metadata.gcode` | unknown | no supported metadata | unknown slicer, missing duration, missing filament |
