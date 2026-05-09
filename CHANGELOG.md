## [2.9.4] - 2026-05-09
### Added
- Added duplicate and delete actions for saved materials, with confirmation and success feedback when removing a material.

### Fixed
- Fixed an app startup issue that could cause the app to hang while showing the What's New sheet.
- Fixed some Android release installs failing to start when required Flutter native libraries were missing.
- Improved G-code import stability when very large files are selected without direct file access.

## [2.9.3] - 2026-05-05
### Changed
- Improved Android G-code import to read selected files more reliably, including picks exposed as generic file types.
- Added a localized error message when an import file exceeds the supported size limit.

### Fixed
- Fixed Android G-code imports from failing or crashing when large files were selected.
- Fixed valid G-code files selected as `.bin` or generic downloads on Android from being rejected when the file contents are valid.

## [2.9.2] - 2026-05-05
### Added
- Added support for `.gco` and `.nc` file extensions in G-code import.
- Added content validation to reject files that don't contain valid G-code data.
- Added a 50 MB file size limit for G-code imports with clear error feedback.

### Changed
- Improved G-code preview display — low-resolution thumbnails now show a tappable preview that opens full-screen.
- Preview area now shows a placeholder icon when no preview image is available.
- Refined file picker to accept a broader set of G-code-related file types on mobile platforms.

## [2.9.1] - 2026-05-04
### Added
- Added a roadmap link in Help & Support so users can quickly view what’s coming next.
- Added Instagram and Mastodon links to the Help & Support footer.

### Changed
- Refreshed the Settings screen with clearer card-based sections for easier scanning.

### Fixed
- Fixed the new material form so it no longer reuses values from the last material you edited.

## [2.9.0] - 2026-05-02
### Added
- New Help page with FAQs, support links, and app information.
- Pro Materials tab with search, filters, stock tracking, color indicators, and bulk CSV import.

### Changed
- Improved material tracking with richer data and automatic stock deduction after saves.
- Updated navigation by moving support into the new Help page.
- Refined “What’s New” experience for clearer announcements.

### Fixed
- Improved material form search and typeahead behavior.
- Clarified stock handling and filtering labels.

## [2.8.2] - 2026-05-01
### Fixed
- Corrected risk calculation logic to apply risk percentage only to base print costs, producing more accurate pricing.
- Fixed settings page from sometimes producing duplicate updates.

## [2.8.0] - 2026-04-28
### Added
- Added G-code file import functionality for premium users. Users can import .gcode files from their device to automatically populate printer settings, material selection, and print dimensions.
- Added "What's New" feature showing app announcements on startup with a modal sheet display.

## [2.7.0] - 2026-04-17
### Added
- Added validation feedback for material and printer settings forms.

### Changed
- Refined history item layout and delete action styling.
- Improved page swipe and navigation sync.

### Fixed
- Fixed legacy history loads from clearing filament cost.

## [2.6.0] - 2026-04-12
### Added
- Added a free-user history teaser with an export preview instead of direct access.
- Added remaining material stock display in the calculator and automatic stock deduction after saves.
- Added locked premium indicators in calculator results for Pro-only features.

### Changed
- Added an option to hide Pro promotions in Settings.
- Improved numeric input handling across calculator and settings forms.

## [2.5.2] - 2026-04-02
### Fixed
- Fixed calculator totals not recalculating when switching from a priced material to a zero-cost material.
- Synced selected material values with spool weight/cost and single-material usage state to prevent stale filament totals.

### Added
- Added regression coverage for material-selection recalculation paths, including non-zero → zero and zero → non-zero transitions.

## [2.5.1] - 2026-03-31
### Added
- Added structured application logging and wired logger initialization into app startup.
- Added logging coverage for calculator, billing/paywall, history UI loading, settings persistence, and database migration/error flows.

### Changed
- Refactored calculator/materials/settings/printers/save/history flows to use repository-backed providers and typed history entries.

### Fixed
- Awaited asynchronous calculator initialization before submit to avoid startup race conditions.
- Removed outdated performance recommendations documentation.

## [2.5.0] - 2026-03-03
### Added
- Multi-material support for premium users, including picker and list components.

### Changed
- Improved multi-material state handling and normalized weight/cost input processing.
- Updated localization strings for material-related labels across multiple languages.

### Fixed
- Standardized default unassigned material naming and usage behavior.

## [2.4.1] - 2026-02-28
### Changed
- Upgraded purchases_flutter and purchases_ui_flutter to 9.12.3

## [2.2.14] - 2025-11-25
### Changed
- Version bump for release

## \[1.0.13\] - 2023-02-28
### Changed
- updated adverts to use banner

## \[1.0.10\] - 2023-02-28
### Changed
- core and package updates
- update target gradle version
- manifest file updates

## [1.2.0+1] - 2023-08-12
### Added
- added support dialog

## [1.2.0] - 2023-08-11
### Added
- added save pring feature for premium users

## [1.1.0] - 2023-08-09
### Added
- additional fields for premium users

## [1.0.14] - 2023-08-09
### Fixed
- package management

## [1.0.9] - 2022-11-05
### Fixed
- ensure keyboard collapses when tapping outside input field

## [1.0.8] - 2022-10-09
### Fixed
- upgrading or core frameworks and implementation of additional security

## [1.0.7] - 2022-09-01
### Changed
- fixed deprecated bloc method

## 1.0.6 - 2022-09-01
### Changed
- upgraded flutter to V3.3.0

## 1.0.5+1 - 2022-08-30
### Fixed
- fixed upgrade dialog not displaying

## 1.0.5 - 2022-08-29
### Fixed
- under the hood cleanup

## 1.0.4 - 2022-08-29
### Added
- Minor visual updates

## 1.0.3 - 2022-08-29
### Added
- Added in-app update checker

[2.9.4]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.9.3...2.9.4
[2.9.3]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.9.2...2.9.3
[2.9.2]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.9.1...2.9.2
[2.9.1]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.9.0...2.9.1
[2.9.0]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.8.2...2.9.0
[2.8.2]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.8.0+1...2.8.2
[2.8.0]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.7.0+6...2.8.0
[2.7.0]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.6.0...2.7.0+6
[2.6.0]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.5.2...2.6.0
[2.5.2]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.5.1...2.5.2
[2.5.1]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.5.0...2.5.1
[2.5.0]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.4.0...2.5.0
[2.4.1]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.4.0...2.4.1
[2.2.14]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.2.13...2.2.14
[1.2.0+1]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/1.2.0...1.2.0+1
[1.2.0]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/1.0.14...1.1.0
[1.0.14]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/1.0.9...1.0.14
[1.0.9]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/1.0.8...1.0.9
[1.0.8]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/1.0.7...1.0.8
[1.0.7]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/1.0.6...1.0.7
