# Project Overview

`threed_print_cost_calculator` is a Flutter app for 3D print cost estimation.

## Core stack

- Flutter + Riverpod + HookConsumerWidget
- Sembast for local persistence
- SharedPreferences for app flags and onboarding state
- Firebase App Check, Crashlytics, Analytics
- RevenueCat for premium gating
- Localized strings live in `lib/l10n/intl_*.arb`

## Main entrypoints

- `lib/main.dart` initializes Firebase, App Check, RevenueCat, SharedPreferences, and the Sembast DB.
- `lib/bootstrap.dart` installs Flutter error handling and the Bloc observer.
- `lib/app/app.dart` is the root app widget.
- `lib/app/app_page.dart` is the main shell with tabs.

## Key feature areas

- `lib/calculator/` cost calculation flow and save form
- `lib/history/` saved print history, search, export, and upsell behavior
- `lib/settings/` general settings, printers, materials, and work costs
- `lib/database/` repositories, storage, and startup migrations
- `lib/purchases/` premium state and purchase gateway
- `lib/shared/` providers, analytics helpers, and common utilities
