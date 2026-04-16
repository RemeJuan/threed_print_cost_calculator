# Feature Boundaries

## App shell

- `AppPage` owns the bottom navigation and page controller.
- Tabs are calculator, history, and settings.
- History visibility is provider-driven: free users can see a teaser state, premium users get the full history UI.
- The help icon opens `SupportDialog`.

## Calculator

- `CalculatorPage` renders the main form and result summary.
- Premium users can see printer selection and save flow.
- Materials, time, rates, and adjustments are split into their own widgets.
- History load state shows `HistoryLoadWarningBanner`.

## History

- `HistoryPage` supports full mode and teaser mode.
- Full mode uses `historyPagedProvider` for paging, filtering, and infinite scroll.
- Export uses `csvUtilsProvider` and supports all / last 7 days / last 30 days.
- Upsell behavior is tied to `shouldShowProPromotionProvider` and `paywallPresenterProvider`.

## Settings

- `SettingsPage` always shows general settings.
- Premium unlocks printers, materials, and work cost sections.
- Add/edit dialogs are in separate widget files.

## Persistence

- Local DB access comes through `databaseProvider`.
- Shared preferences come through `sharedPreferencesProvider`.
- Test code overrides both providers with in-memory instances.
