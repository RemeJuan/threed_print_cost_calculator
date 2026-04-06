![Calorie Diff Icons](android/app/src/main/play_store_feature.jpg "Calorie Diff")
# Threed Print Cost Calculator

[![Codemagic build status](https://api.codemagic.io/apps/61bf59755d15f5a8273ab9f8/61bf59755d15f5a8273ab9f7/status_badge.svg)](https://codemagic.io/apps/61bf59755d15f5a8273ab9f8/61bf59755d15f5a8273ab9f7/latest_build)
<br/>

[AppStore](https://apps.apple.com/us/app/3d-printer-cost-calculator/id6444106268) | [PlayStore](https://play.google.com/store/apps/details?id=com.threed_print_calculator) | [Website](https://print.remej.dev)

A small app to help you calculate the cost of printing your 3D models.

While there are many others out there, I saw none that were simple 
for a quick personal check, and allowed you to enter the actual wattage
of your printer, which is an essential value in an accurate calculation.

## Firebase Analytics DebugView

This app logs only feature-level events through `AppAnalytics` (see `lib/core/analytics/app_analytics.dart`) and does not send user identifiers, print names, file names, or cost/job payloads.

During development you can enable Firebase Analytics DebugView:

```bash
adb shell setprop debug.firebase.analytics.app <package_name>
```

Note: events can appear quickly in DebugView, but standard Firebase Analytics dashboards may take several hours to update.

## Coverage

Run filtered coverage with:

```bash
./scripts/coverage.sh
```

This runs `fvm flutter test --coverage` and removes generated files plus bootstrap-only files from `coverage/lcov.info` before printing the final summary.
