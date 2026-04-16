# Project Overview

`threed_print_cost_calculator` is a Flutter app for 3D print cost estimation.

## Core stack

- Flutter + Dart `>=3.10.0`
- Riverpod + flutter_hooks for state and UI wiring
- Sembast for local persistence
- SharedPreferences for lightweight app state
- Firebase Analytics, App Check, Crashlytics
- RevenueCat for premium gating
- Localized strings in `lib/l10n/intl_*.arb`

## Main entrypoints

- `lib/main.dart` initializes Firebase, App Check, Crashlytics, RevenueCat, Localizely, SharedPreferences, Sembast, then startup migrations.
- `lib/bootstrap.dart` installs global Flutter error handling.
- `lib/app/app.dart` is the root app widget.
- `lib/app/app_page.dart` owns the main tab shell.

## Major areas

- `lib/calculator/` calculation flow, save form, premium printer/material UI
- `lib/history/` saved history, search, export, premium teaser/full flows
- `lib/settings/` general settings, printers, materials, work costs
- `lib/database/` repositories, storage, startup migrations
- `lib/purchases/` premium state and purchase gateway
- `lib/shared/` providers, analytics, utilities

## App shape

- Calculator, history, and settings are the main tabs.
- `HistoryPage` is premium-only in the full UI; free users get teaser behavior through `AppPage`.
