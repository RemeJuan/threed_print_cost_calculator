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
  - params: [`slicer`, `has_preview`, `parse_status`, `file_size_bucket`, `failure_reason`?]
  - triggered_from: [`lib/gcode_import/gcode_import_page.dart`]
  - feature: G-code import
  - notes: fired on page dispose if import flow opened and not completed; `failure_reason` is `cancelled` when user abandons the flow; only present when a meaningful reason exists

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
  - params: [`slicer`, `has_preview`, `parse_status`, `file_size_bucket`, `failure_reason`]
  - triggered_from: [`lib/gcode_import/gcode_import_controller.dart`]
  - feature: G-code import
  - notes: `parse_status=failed`; `failure_reason` is a `GCodeFailureReason` constant (`file_too_large`, `unsupported_content`, `parse_error`, `read_failed`, or `unknown`); no filenames, raw errors, or stack traces

- `gcode_import_breadcrumb`
  - params: [`stage`, `file_name`?, `original_file_name`?, `mime_type`?, `file_size_bytes`?, `reason`?]
  - triggered_from: [`lib/gcode_import/gcode_import_controller.dart`, `lib/gcode_import/gcode_import_diagnostics.dart`]
  - feature: G-code import
  - notes: best-effort import diagnostics mirrored to Crashlytics logs; stages currently include `import_started`, `file_metadata_resolved`, `file_rejected_size`, `file_rejected_type`, `parse_failed`, `import_succeeded`

- `gcode_preview_viewed`
  - params: [`slicer`, `has_preview`, `parse_status`, `file_size_bucket`]
  - triggered_from: [`lib/gcode_import/gcode_import_page.dart`]
  - feature: G-code import
  - notes: fired before preview dialog opens

- `gcode_apply_to_calculator`
  - params: [`slicer`, `has_preview`, `parse_status`, `file_size_bucket`, `gcode_time_to_value_ms`]
  - triggered_from: [`lib/gcode_import/gcode_import_page.dart`]
  - feature: G-code import
  - notes: helper exists in analytics code, but current page flow does not emit this event; it is stale unless a future intermediate funnel step is wired in

- `gcode_flow_completed`
  - params: [`slicer`, `has_preview`, `parse_status`, `file_size_bucket`, `gcode_time_to_value_ms`]
  - triggered_from: [`lib/gcode_import/gcode_import_page.dart`]
  - feature: G-code import
  - notes: fired only after the calculator apply CTA; clears open-flow timer state immediately, which suppresses later abandon logging for the same session

- `gcode_import_success`
  - params: [`has_print_time`, `has_filament_usage`, `has_preview`]
  - triggered_from: [`lib/gcode_import/gcode_import_page.dart`]
  - feature: G-code import
  - notes: success milestone when parsed values are applied to calculator; does not carry `slicer`, `parse_status`, or `file_size_bucket`, so it cannot stand alone as a funnel context event

### Calculator usage

- `calculation_created`
  - params: [`material_count`, `has_failure_risk`, `has_labour`, `has_pricing`]
  - triggered_from: [`lib/calculator/provider/calculator_notifier.dart`]
  - feature: Calculator usage
  - notes: fired after results recomputed; `has_pricing` acts as a lightweight pricing usage signal without its own dedicated event

- `pricing_settings_changed`
  - params: [`pricing_enabled`, `markup_bucket`, `setup_fee_bucket`, `rounding_mode`]
  - triggered_from: [`lib/settings/work_costs_form.dart`]
  - feature: Pricing / Settings
  - notes: fired when a pricing default changes in settings; uses bucketed values (`markup_bucket`: 0/1_10/11_25/26_50/50_plus, `setup_fee_bucket`: 0/low/medium/high) for low-cardinality analytics

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

### Batch Costing

- `batch_started`
  - params: [`source`]
  - triggered_from: [`lib/batch_costing/batch_costing_page.dart`, `lib/batch_costing/batch_gcode_import_page.dart`]
  - feature: Batch costing
  - notes: fired when a batch session begins; `source` is `manual` (from review page), `gcode_single` (single-file import), or `gcode_multi` (multi-file import)

- `batch_item_added`
  - params: [`source`]
  - triggered_from: [`lib/batch_costing/batch_costing_page.dart`, `lib/batch_costing/batch_gcode_import_page.dart`]
  - feature: Batch costing
  - notes: fired per batch item added; `source` is `manual` (manual entry) or `gcode` (G-code import). No item name, file name, or content logged

- `batch_item_removed`
  - params: [`source`]
  - triggered_from: [`lib/batch_costing/batch_costing_page.dart`, `lib/batch_costing/batch_gcode_import_page.dart`]
  - feature: Batch costing
  - notes: fired when a batch item is removed; `source` is `manual` or `gcode`

- `batch_item_edited`
  - params: [`source`, `changed_quantity`, `changed_weight`, `changed_duration`]
  - triggered_from: [`lib/batch_costing/batch_costing_page.dart`]
  - feature: Batch costing
  - notes: fired when a manual batch item's details are saved; `source` is `manual`; boolean params are `0`/`1` indicating which fields changed. No item name or content logged

- `batch_gcode_import_completed`
  - params: [`total_count`, `ready_count`, `needs_details_count`, `failed_count`, `duplicate_skipped_count`]
  - triggered_from: [`lib/batch_costing/batch_gcode_import_page.dart`]
  - feature: Batch costing
  - notes: fired after all G-code files are processed in multi-file import mode. `duplicate_skipped_count` is `0` in current instrumentation (dedup handled in the picker)

- `batch_assignment_completed`
  - params: [`type`, `mode`, `has_split_allocations`]
  - triggered_from: [`lib/batch_costing/batch_printer_assignment_page.dart`, `lib/batch_costing/batch_material_assignment_page.dart`]
  - feature: Batch costing
  - notes: fired on continue from printer or material assignment step; `type` is `printer` or `material`; `mode` is `batch` or `split`; `has_split_allocations` is `1` when mode is `split` and any item has allocations spanning multiple targets

- `batch_pricing_completed`
  - params: [`has_risk`, `has_markup`, `has_labour`, `has_additional_cost`, `risk_scope`, `markup_scope`, `labour_scope`, `additional_cost_scope`]
  - triggered_from: [`lib/batch_costing/batch_pricing_scope_page.dart`]
  - feature: Batch costing
  - notes: fired on continue from pricing scope step; boolean params indicate non-zero values; scope params are `item` or `batch`

- `batch_summary_viewed`
  - params: [`total_items`, `total_quantity`, `has_split_printers`, `has_split_materials`]
  - triggered_from: [`lib/batch_costing/batch_summary_page.dart`]
  - feature: Batch costing
  - notes: fired once on summary page mount via postFrameCallback; `has_split_printers`/`has_split_materials` are `0`/`1`

- `batch_quote_saved`
  - params: [`outcome`]
  - triggered_from: [`lib/batch_costing/batch_summary_page.dart`]
  - feature: Batch costing
  - notes: fired after save attempt; `outcome` is `success` or `failure`

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
  - triggered_from: [`lib/calculator/view/calculator_page.dart`, `lib/history/history_page.dart`, `lib/app/header_actions.dart`, `lib/shared/components/whats_new_sheet.dart`]
  - feature: Premium / RevenueCat
  - notes: current values: `multi_printer`, `history`, `pro`, `whats_new`; `is_pro` reflects user state at tap time

- `paywall_viewed`
  - params: [`feature`, `entry_point`, `source`, `launch_count`]
  - triggered_from: [`lib/purchases/paywall_screen.dart`]
  - feature: Premium / RevenueCat
  - notes: `AppAnalytics.paywallShown(...)` is a pure alias; the custom `PaywallScreen` logs this in `initState` with metadata passed from the presenter (`source`, `triggerFeature`, `entryPoint`, `launchCount`); `source` carries trigger path (`whats_new`, `premium_feature`, `header`, `history`, `settings`, etc.)

- `purchase_completed`
  - params: [`source`, `entry_point`]
  - triggered_from: [`lib/purchases/paywall_screen.dart`]
  - feature: Premium / RevenueCat
  - notes: only local success tracked; emitted by custom paywall after successful package purchase; sources currently `custom_paywall_preview` (admin preview) or `custom_paywall` (production flow)

- `paywall_present_error`
  - params: [`error`, `stack`]
  - triggered_from: [`lib/purchases/paywall_presenter.dart`]
  - feature: Premium / RevenueCat
  - notes: local error logging when custom paywall presentation throws (e.g. navigator unavailable)

- `restore_completed`
  - params: [`source`, `entry_point`]
  - triggered_from: [`lib/purchases/paywall_screen.dart`]
  - feature: Premium / RevenueCat
  - notes: logged after successful restore from the custom paywall; `source` identifies trigger path (`custom_paywall_preview` for admin, `custom_paywall` for production); `entry_point` indicates entry surface

### Materials

- `materials_view_opened`
  - params: []
  - triggered_from: [`lib/app/app_page.dart`]
  - feature: Materials
  - notes: fired once per tab open via post-frame callback when Materials tab becomes the active rendered tab

- `material_created`
  - params: [`has_tracking`, `material_type`?, `brand`?]
  - triggered_from: [`lib/settings/providers/materials_notifier.dart`]
  - feature: Materials
  - notes: fired after successful save when `dbRef == null` (new material); `has_tracking` encoded `0/1`; `material_type` and `brand` omitted when empty

- `material_edited`
  - params: [`has_tracking`, `material_type`?, `brand`?]
  - triggered_from: [`lib/settings/providers/materials_notifier.dart`]
  - feature: Materials
  - notes: fired after successful save when `dbRef != null` (existing material); params same as `material_created`

- `csv_import_started`
  - params: []
  - triggered_from: [`lib/materials/csv_import/csv_import_page.dart`]
  - feature: Materials
  - notes: fired after successful file read, before CSV parse

- `csv_import_completed`
  - params: [`rows_success`, `rows_failed`]
  - triggered_from: [`lib/materials/csv_import/csv_import_page.dart`]
  - feature: Materials
  - notes: fired after import save loop completes or when all rows invalid; `rows_success` = 0 when every row has errors

- `material_selected_in_calculator`
  - params: [`has_tracking`, `material_type`?, `brand`?]
  - triggered_from: [`lib/calculator/provider/calculator_notifier.dart`]
  - feature: Materials
  - notes: fired from `selectMaterial()` in calculator; signals a saved material was chosen for use in a calculation

### Settings

- `interface_visibility_changed`
  - params: [`setting`, `visible`]
  - triggered_from: [`lib/settings/interface_settings/interface_settings_page.dart`]
  - feature: Settings
  - notes: fired only after the interface setting persistence succeeds; `setting` uses stable snake_case IDs (`printer_select`, `batch_button`, `history_tab`, `materials_tab`, `gcode_action`, `advanced_breakdown`, `labour_fields`, `failure_risk`, `wear_and_tear`, `markup`, `currency`); `visible` is `0`/`1`

- `printer_profile_created`
  - params: []
  - triggered_from: [`lib/settings/providers/printers_notifier.dart`]
  - feature: Settings
  - notes: fired after successful save; same event used for create and edit submits

### Update checker

- `update_prompt_shown`
  - params: [`current_version`, `store_version`, `platform`, `source`]
  - triggered_from: [`lib/app/app_page.dart`]
  - feature: Update checker
  - notes: non-blocking app-shell banner/card shown when update is available and cooldown permits; `store_version` falls back to `unknown`

- `update_prompt_tapped`
  - params: [`current_version`, `store_version`, `platform`, `source`]
  - triggered_from: [`lib/app/app_page.dart`]
  - feature: Update checker
  - notes: fired when user opens store from app-owned prompt

- `update_prompt_dismissed`
  - params: [`current_version`, `store_version`, `platform`, `source`]
  - triggered_from: [`lib/app/app_page.dart`]
  - feature: Update checker
  - notes: fires when user dismisses prompt and cooldown is persisted locally

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
- import diagnostics: yes — `gcode_import_breadcrumb` plus mirrored Crashlytics breadcrumb logs
- estimate applied: no — helper exists but current import flow does not emit `gcode_apply_to_calculator`
- calculator success: yes — `gcode_import_success`
- flow completed: yes — `gcode_flow_completed`
- upgrade entry: partial — G-code open/start attribution exists, but the current UI does not route free users into G-code import; header access is premium-only
- preview viewed: yes — `gcode_preview_viewed`
- abandon: yes — `gcode_import_abandoned`

Notes:

- `gcode_import_success` and `gcode_flow_completed` are emitted from the same apply CTA handler, after parse/preview has already succeeded.
- `gcode_import_abandoned` is dispose-driven and only fires if the flow timer is still open; it should not follow a completed apply path.
- Android and iOS share the same analytics sequence after file selection; only the picker metadata source differs.

### Materials

- tab opened: yes — `materials_view_opened`
- material created: yes — `material_created` (with `has_tracking`, type, brand)
- material edited: yes — `material_edited` (with `has_tracking`, type, brand)
- saved material selected in calculator: yes — `material_selected_in_calculator`
- CSV import started: yes — `csv_import_started`
- CSV import completed: yes — `csv_import_completed` (success/fail counts)

### Upgrade / monetisation

- upgrade CTA taps: yes — `premium_feature_tapped`, `whats_new_unlock_pro_tapped`
- paywall shown/viewed: yes — `paywall_viewed` (also called through `paywallShown` alias)
- purchase started: no dedicated event found
- purchase success: yes — `purchase_completed`
- purchase failure/cancel: no dedicated event found
- restore started: no dedicated event found
- restore success: partial — `restore_completed` logged on success (custom paywall)
- restore failure: no dedicated event — custom paywall surfaces error via SnackBar and app logger, but no analytics event for failures
- paywall entry attribution: yes — all paths pass `source`
- settings compact card CTA: `premium_feature_tapped` with `source=settings`, `trigger=settings_premium_card`
- help/support premium FAQ CTA: `premium_feature_tapped` with `source=faq`, `trigger=faq_premium_card`

## Known gaps

- No dedicated onboarding / first-run / app-launch event. `run_count` stored locally only.
- No dedicated purchase-started event.
- No dedicated purchase-cancelled or purchase-failed event. RevenueCat errors only logged locally.
- _(fixed)_ `restore_completed` event added for restore success from custom paywall; restore failure still lacks a dedicated analytics event.
- _(fixed)_ `gcode_parse_failed` now includes `failure_reason` to distinguish size rejection, unsupported content, parse errors, and read failures.
- _(fixed)_ History upsell `premium_feature_tapped` now includes `source: history_upsell`.
- Paywall routing is centralized in `lib/purchases/paywall_presenter.dart`, which pushes `PaywallScreen` through `appNavigatorKey`.
- `paywall_shown` is not a distinct event from `paywall_viewed`; it is an alias in `AppAnalytics`.
- `showSubscriptionsSheet` also logs `paywall_viewed`, so it can double-log if wrapped by presenter-driven flow.
- History flow lacks load/delete analytics:
  - no history entry loaded event
  - no history delete success/failure event
  - no history page load success/failure event
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
