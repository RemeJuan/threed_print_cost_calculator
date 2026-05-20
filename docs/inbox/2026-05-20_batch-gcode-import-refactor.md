# Refactor: batch_gcode_import_page.dart

Goal: Reduce `lib/batch_costing/batch_gcode_import_page.dart` from ~854 LOC to ~450 LOC by extracting widgets into dedicated files.

## Task list

- [x] **1. Extract model classes** → `lib/batch_costing/model/batch_import_state.dart`
  - `_BatchSingleImport` → `BatchSingleImport`, `_BatchImportRow` → `BatchImportRow`, `_ImportStatus` → `ImportStatus`
  - Savings: ~54 LOC

- [x] **2. Extract MissingDetailsForm** → `lib/batch_costing/widgets/batch_missing_details_form.dart`
  - `_MissingDetailsForm` → `MissingDetailsForm`, clean `StatelessWidget` (72 LOC)
  - Savings: ~72 LOC

- [x] **3. Extract single import view** → `lib/batch_costing/widgets/batch_single_import_view.dart`
  - `_buildSingleImportView` → `BatchSingleImportView` standalone widget (91 LOC)
  - Savings: ~91 LOC

- [x] **4. Extract file row widget** → `lib/batch_costing/widgets/batch_import_file_row.dart`
  - `_buildFileRow` → `BatchImportFileRow` handling all 4 `ImportStatus` cases (131 LOC)
  - Savings: ~131 LOC

- [x] **5. Extract body/content widget** → `lib/batch_costing/widgets/batch_gcode_import_body.dart`
  - `ConsumerWidget` with all action callbacks + free `showImportDetailsSheet` helper (184 LOC)
  - Savings: ~100 LOC

- [ ] **6. Extract import logic helper** → `lib/batch_costing/providers/batch_gcode_import_handler.dart`
  - **Skipped** — methods too tightly coupled to `setState`/`mounted`/`ref` in state class. Extracting would add complexity without meaningful savings. Remaining state class is ~447 LOC, which is acceptable.

- [x] **7. Strip main file** to shell: lifecycle (`dispose`, `didChangeDependencies`), state fields, `build()`, import handler methods, feature gate
  - Removed old private classes, extracted widget methods, unused imports
  - Remaining: `_rows`/`_singleImport`/`_loading`/`_autoStarted` fields + `dispose` + `didChangeDependencies` + `build` (Scaffold) + 9 action methods

- [x] **8. Verify**
  - `fvm flutter analyze` — clean
  - `fvm flutter test` — 513/513 pass

ClickUp Task: tbd
