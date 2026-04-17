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

[2.6.0]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.5.2...2.6.0
[2.7.0]: https://github.com/RemeJuan/threed_print_cost_calculator/compare/2.6.0...2.7.0+6
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
