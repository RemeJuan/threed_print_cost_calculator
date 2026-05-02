# Header bar actions

This document is the source of truth. Any deviation in the app is a bug and must be corrected to match this mapping. Only one icon is allowed per side unless explicitly stated.

This documents which header bar actions are visible on which screens, if a screen is not listed assume either no icon or back icon only.

## Header Actions
This documents what component the actions link to and which icon is on use

### Help 
Path: `/lib/app/help_support/help_support_page.dart`
Icon: `Icons.help_outline`

### GCode Import
Path: `/lib/gcode_import/gcode_import_page.dart`
Icon: `Icons.upload_file_outlined`

### CSV Import
Path: `/lib/materials/csv_import/csv_import_page.dart`
Icon: `Icons.file_upload_outlined`

## Purchase
Triggers:
```dart
    AppAnalytics.safeLog(
        () => AppAnalytics.premiumFeatureTapped(
            'pro',
            isPro: isPremium,
            source: 'header',
        ),
    );
    await ref
        .read(paywallPresenterProvider)
        .present(
            'pro',
            triggerFeature: 'pro',
            purchaseSource: 'header',
            source: 'header',
        );
```
Icon: `Icons.shopping_cart`

## Calculator Page
`lib/calculator/view/calculator_page.dart`

Left: @Help
Right: 
- Premium @GCode Import
- Free @Purchase

## Materials Page
`lib/materials/widgets/materials_page.dart`

Left: @Help
Right: @CSV Import

## History Page
`/lib/history/history_page.dart`

Left: @Help
Right: None at present

## Settings Page
`lib/settings/settings_page.dart`

Left: @Help
Right: None
