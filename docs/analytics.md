## Overview

- Analytics backend: Firebase Analytics via `firebase_analytics` (`pubspec.yaml`)
- App wrapper: `lib/core/analytics/app_analytics.dart`
- Service abstraction: `lib/core/analytics/analytics_service.dart`
- Firebase bridge: `lib/core/analytics/firebase_analytics_service.dart`
- Initialization:
  - Firebase bootstrapped in `lib/main.dart`
  - `AppAnalytics.service` defaults to `FirebaseAnalyticsService()` in `lib/core/analytics/app_analytics.dart`
  - `AppAnalytics.logger` injected from `lib/app/app.dart`
- Send path: app code calls `AppAnalytics.*` helpers or `AppAnalytics.log(...)`; only `FirebaseAnalyticsService.logEvent(...)` calls `FirebaseAnalytics.instance.logEvent(...)` directly
- Approach: minimal, feature-level tracking only. Params sanitized to strings/numbers before send. Tests replace analytics with no-op implementations.

## Tools used

- Firebase Analytics for event delivery
- RevenueCat for purchases/paywall presentation, with limited local analytics callbacks around purchase success

## Event catalogue

### What's New

- `whats_new_shown`
  - params: [`wn_id`, `locale`, `is_premium`]
  - triggered_from: [`lib/shared/components/whats_new_sheet.dart`]
  - feature: What's New
  - notes: fired in sheet `initState`; `is_premium` encoded `0/1`

- `whats_new_dismissed`
  - params: [`wn_id`, `locale`, `is_premium`]
  - triggered_from: [`lib/shared/components/whats_new_sheet.dart`]
  - feature: What's New
  - notes: fired after dismiss callback, before sheet close

- `whats_new_unlock_pro_tapped`
  - params: [`wn_id`, `locale`, `source`]
  - triggered_from: [`lib/shared/components/whats_new_sheet.dart`]
  - feature: What's New
  - notes: `source=whats_new`; fires before paywall presentation and before the What’s New sheet is dismissed; paywall path also logs `premium_feature_tapped` with `feature=whats_new`

### G-code import

- `gcode_import_opened`
  - params: [`slicer`, `has_preview`, `parse_status`, `file_size_bucket`]
  - triggered_from: [`lib/gcode_import/gcode_import_page.dart`]
  - feature: G-code import
  - notes: only for premium users; starts funnel session context

- `gcode_import_started`
  - params: [`slicer`, `has_preview`, `parse_status`, `file_size_bucket`, `source`]
  - triggered_from: [`lib/gcode_import/gcode_import_page.dart`]
  - feature: G-code import
  - notes: entry attribution for calculator/header; emitted on import flow open

- `gcode_import_abandoned`
  - params: [`slicer`, `has_preview`, `parse_status`, `file_size_bucket`]
  - triggered_from: [`lib/gcode_import/gcode_import_page.dart`]
  - feature: G-code import
  - notes: fired on page dispose if import flow opened and not completed

- `gcode_file_selected`
  - params: [`file_type`]
  - triggered_from: [`lib/gcode_import/gcode_import_controller.dart`]
  - feature: G-code import
  - notes: low-cardinality file extension only; no filename/path/content logged

- `gcode_parse_success`
  - params: [`slicer`, `has_preview`, `parse_status`, `file_size_bucket`]
  - triggered_from: [`lib/gcode_import/gcode_import_controller.dart`]
  - feature: G-code import
  - notes: `parse_status=success`

- `gcode_parse_partial`
  - params: [`slicer`, `has_preview`, `parse_status`, `file_size_bucket`]
  - triggered_from: [`lib/gcode_import/gcode_import_controller.dart`]
  - feature: G-code import
  - notes: `parse_status=partial`

- `gcode_parse_failed`
  - params: [`slicer`, `has_preview`, `parse_status`, `file_size_bucket`]
  - triggered_from: [`lib/gcode_import/gcode_import_controller.dart`]
  - feature: G-code import
  - notes: used for unsupported extension, unsupported file contents, and read failure; `parse_status=failed`

- `gcode_preview_viewed`
  - params: [`slicer`, `has_preview`, `parse_status`, `file_size_bucket`]
  - triggered_from: [`lib/gcode_import/gcode_import_page.dart`]
  - feature: G-code import
  - notes: fired before preview dialog opens

- `gcode_apply_to_calculator`
  - params: [`slicer`, `has_preview`, `parse_status`, `file_size_bucket`, `gcode_time_to_value_ms`]
  - triggered_from: [`lib/gcode_import/gcode_import_page.dart`]
  - feature: G-code import
  - notes: helper exists in analytics code, but current page flow does not emit this event

- `gcode_flow_completed`
  - params: [`slicer`, `has_preview`, `parse_status`, `file_size_bucket`, `gcode_time_to_value_ms`]
  - triggered_from: [`lib/gcode_import/gcode_import_page.dart`]
  - feature: G-code import
  - notes: fired after values applied; clears open-flow timer state

- `gcode_import_success`
  - params: [`has_print_time`, `has_filament_usage`, `has_preview`]
  - triggered_from: [`lib/gcode_import/gcode_import_page.dart`]
  - feature: G-code import
  - notes: success milestone when parsed values are applied to calculator

### Calculator usage

- `calculation_created`
  - params: [`material_count`, `has_failure_risk`, `has_labour`, `has_pricing`]
  - triggered_from: [`lib/calculator/provider/calculator_notifier.dart`]
  - feature: Calculator usage
  - notes: fired after results recomputed

- `pricing_settings_changed`
  - params: [`pricing_enabled`, `markup_percent`, `setup_fee`, `rounding_mode`]
  - triggered_from: [`lib/settings/work_costs_form.dart`]
  - feature: Pricing / Settings
  - notes: fired when a pricing default changes in settings

- `pricing_override_used`
  - params: [`field`, `has_overrides`]
  - triggered_from: [`lib/calculator/view/components/job_pricing_overrides_section.dart`]
  - feature: Pricing / Calculator
  - notes: fired when a job-level override field is changed

- `pricing_rounding_used`
  - params: [`rounding_mode`]
  - triggered_from: [`lib/calculator/provider/calculator_notifier.dart`]
  - feature: Pricing / Calculator
  - notes: fired when rounding is active during calculation

- `pricing_saved`
  - params: [`has_pricing`, `used_overrides`, `rounding_mode`]
  - triggered_from: [`lib/calculator/view/save_form.dart`]
  - feature: Pricing / History
  - notes: fired when a job is saved with pricing snapshot data

- `multi_material_used`
  - params: [`material_count`]
  - triggered_from: [`lib/calculator/provider/calculator_notifier.dart`]
  - feature: Calculator usage
  - notes: only when more than one material usage exists

### History

- `history_overflow_opened`
  - params: []
  - triggered_from: [`lib/history/history_page.dart`]
  - feature: History
  - notes: one-time signal after first overflow menu open preference write

- `history_overflow_hint_shown`
  - params: []
  - triggered_from: [`lib/history/history_page.dart`]
  - feature: History
  - notes: one-time signal when overflow hint first displayed

- `export_used`
  - params: [`type`]
  - triggered_from: [`lib/history/history_page.dart`, `lib/history/components/history_item_actions.dart`]
  - feature: History
  - notes: `type=history` for range export, `type=job` for single record export

### Premium / RevenueCat

- `premium_feature_tapped`
  - params: [`feature`, `is_pro`, `source`]
  - triggered_from: [`lib/calculator/view/calculator_page.dart`, `lib/history/history_page.dart`, `lib/app/header_actions.dart`, `lib/settings/settings_page.dart`, `lib/shared/components/whats_new_sheet.dart`]
  - feature: Premium / RevenueCat
  - notes: current values: `multi_printer`, `history`, `pro`, `settings`, `whats_new`; `is_pro` reflects user state at tap time; `source` is only present on some call sites

- `paywall_viewed`
  - params: [`feature`, `entry_point`, `source`, `launch_count`]
  - triggered_from: [`lib/purchases/paywall_presenter.dart`, `lib/calculator/view/subscriptions.dart`]
  - feature: Premium / RevenueCat
  - notes: `AppAnalytics.paywallShown(...)` aliases to this same event name; `source` explains trigger path (`whats_new`, `premium_feature`, `header`, `history_teaser_primary`, `history_teaser_secondary`, `unknown`); `launch_count` comes from local run counter when available

- `purchase_completed`
  - params: [`source`, `entry_point`]
  - triggered_from: [`lib/purchases/paywall_presenter.dart`, `lib/calculator/view/subscriptions.dart`]
  - feature: Premium / RevenueCat
  - notes: only local success tracked; sources currently `calculator`, `header`, `history`, `history_teaser_primary`, `history_teaser_secondary`, `whats_new`

- `paywall_present_error`
  - params: [`error`, `stack`]
  - triggered_from: [`lib/purchases/paywall_presenter.dart`]
  - feature: Premium / RevenueCat
  - notes: local error logging when RevenueCat paywall presentation throws

### Settings

- `printer_profile_created`
  - params: []
  - triggered_from: [`lib/settings/providers/printers_notifier.dart`]
  - feature: Settings
  - notes: fired after successful save; same event used for create and edit submits

- `material_created`
  - params: []
  - triggered_from: [`lib/settings/providers/materials_notifier.dart`]
  - feature: Settings
  - notes: fired after successful save; same event used for create and edit submits

### Onboarding / first run

- No dedicated analytics events found
  - params: []
  - triggered_from: []
  - feature: Onboarding / first run
  - notes: `run_count` increments in `lib/app/app_page.dart`, but no analytics event emitted

## Flow coverage

### What's New

- shown: yes — `whats_new_shown`
- dismissed: yes — `whats_new_dismissed`
- CTA tapped: partial — unlock/pro CTA tracked as `whats_new_unlock_pro_tapped`; no separate event for primary “got it” tap beyond dismiss
- upgrade tapped: yes — `whats_new_unlock_pro_tapped`

### G-code import

- entry point: yes — `gcode_import_opened` plus attributable `gcode_import_started`
- file select: yes — `gcode_file_selected`
- parse success/fail: yes — `gcode_parse_success`, `gcode_parse_partial`, `gcode_parse_failed`
- estimate applied: no — helper exists but current import flow does not emit `gcode_apply_to_calculator`
- calculator success: yes — `gcode_import_success`
- flow completed: yes — `gcode_flow_completed`
- upgrade entry: partial — G-code open/start attribution exists, but the current UI does not route free users into G-code import; header access is premium-only
- preview viewed: yes — `gcode_preview_viewed`
- abandon: yes — `gcode_import_abandoned`

### Upgrade / monetisation

- upgrade CTA taps: yes — `premium_feature_tapped`, `whats_new_unlock_pro_tapped`
- paywall shown/viewed: yes — `paywall_viewed` (also called through `paywallShown` alias)
- purchase started: no dedicated event found
- purchase success: yes — `purchase_completed`
- purchase failure/cancel: no dedicated event found
- restore started/success/failure: no dedicated event found

## Known gaps

- No dedicated onboarding / first-run / app-launch event. `run_count` stored locally only.
- No dedicated purchase-started event.
- No dedicated purchase-cancelled or purchase-failed event. RevenueCat errors only logged locally.
- No dedicated restore-purchases analytics.
- `gcode_parse_failed` exists, but missing failure reason/context param distinguishing unsupported type vs unsupported contents vs read failure.
- Paywall routing is centralized in `lib/purchases/paywall_presenter.dart`; `subscriptions.dart` is the sheet implementation, not the only paywall entry.
- History flow lacks load/delete analytics:
  - no history entry loaded event
  - no history delete success/failure event
  - no history page load success/failure event
- Settings save events exist, but missing create-vs-edit context.
- `purchase_completed` missing product/offering/package context.
- Calculator flow has success-style usage events only; no invalid/failed submit event.

## Privacy constraints

- No PII in analytics
- No filenames
- No raw G-code content
- No user-defined labels such as printer names or material names
- No full cost/job payloads
- Feature interaction only

Evidence:

- `README.md`: app logs feature-level events through `AppAnalytics`
- `privacy_policy.md`: explicitly excludes print names, file names, and full cost/job payloads from analytics params
