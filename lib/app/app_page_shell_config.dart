import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/app/header_actions.dart';
import 'package:threed_print_cost_calculator/history/history_page.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_page.dart';
import 'package:threed_print_cost_calculator/materials/widgets/materials_page.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/settings/settings_page.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';

enum AppPageTab { calculator, materials, history, settings }

class AppPageShellTab {
  const AppPageShellTab({
    required this.tab,
    required this.page,
    required this.title,
    required this.actions,
    required this.navigationItem,
  });

  final AppPageTab tab;
  final Widget page;
  final String title;
  final List<Widget> actions;
  final BottomNavigationBarItem navigationItem;
}

List<AppPageShellTab> buildAppPageShellTabs({
  required BuildContext context,
  required AppLocalizations l10n,
  required PremiumAccessPolicy policy,
  required Future<void> Function() onHistoryLoaded,
}) {
  final historyMode = policy.historyView().allowed
      ? HistoryPageMode.full
      : HistoryPageMode.teaser;

  return [
    AppPageShellTab(
      tab: AppPageTab.calculator,
      page: const CalculatorPage(),
      title: l10n.calculatorAppBarTitle,
      actions: const [HeaderActions()],
      navigationItem: BottomNavigationBarItem(
        icon: const Icon(
          Icons.calculate,
          key: ValueKey<String>('nav.calculator.button'),
        ),
        label: l10n.calculatorNavLabel,
      ),
    ),
    AppPageShellTab(
      tab: AppPageTab.materials,
      page: const MaterialsPage(),
      title: l10n.materialsAppBarTitle,
      actions: [
        if (policy.csvMaterialImport().allowed)
          IconButton(
            tooltip: l10n.csvImportTitle,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CsvImportPage()),
              );
            },
            icon: const Icon(Icons.file_upload_outlined, color: ICON_MUTED),
          ),
      ],
      navigationItem: BottomNavigationBarItem(
        icon: const Icon(
          Icons.inventory_2_outlined,
          key: ValueKey<String>('nav.materials.button'),
        ),
        label: l10n.materialsNavLabel,
      ),
    ),
    if (policy.shouldShowHistoryTab)
      AppPageShellTab(
        tab: AppPageTab.history,
        page: HistoryPage(mode: historyMode, onHistoryLoaded: onHistoryLoaded),
        title: l10n.historyAppBarTitle,
        actions: const [],
        navigationItem: BottomNavigationBarItem(
          icon: const Icon(
            Icons.history,
            key: ValueKey<String>('nav.history.button'),
          ),
          label: l10n.historyNavLabel,
        ),
      ),
    AppPageShellTab(
      tab: AppPageTab.settings,
      page: const SettingsPage(),
      title: l10n.settingsAppBarTitle,
      actions: const [],
      navigationItem: BottomNavigationBarItem(
        icon: const Icon(
          Icons.settings,
          key: ValueKey<String>('nav.settings.button'),
        ),
        label: l10n.settingsNavLabel,
      ),
    ),
  ];
}
