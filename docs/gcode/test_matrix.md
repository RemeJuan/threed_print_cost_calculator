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
| Decorated Kiri:Moto metadata | inline in `gcode_import_parser_test.dart`; optional local full-file case in `gcode_import_kiri_moto_test.dart` | unknown | dashed `filament used: … mm` and `print time: …s` | unavailable | extracts metadata while slicer remains unknown; local private fixture is optional and must never be committed |
| Unknown command-bearing file without metadata | inline in `gcode_import_kiri_moto_test.dart` | unknown | null duration and filament | unavailable | import succeeds with missing-metadata warnings |
| Command-free or non-G-code content without metadata | inline in `gcode_import_kiri_moto_test.dart` | unknown | none | unavailable | rejected; slicer banner or text alone is not validity evidence |

The optional full-file test reads the root-level private `Documento_da_parte_di_Leonardo_B1681905261655622098.tmp` only when present and skips otherwise. Treat it as a possible email attachment; do not infer it was the original picked filename or add, copy, log, or transmit the private fixture.
