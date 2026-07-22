import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threed_print_cost_calculator/app/header_actions.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/history/history_page.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_page.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/materials_csv_export_service.dart';
import 'package:threed_print_cost_calculator/materials/widgets/materials_page.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/settings_page.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_file_export.dart';
import 'package:share_plus/share_plus.dart';

enum AppPageTab { calculator, materials, history, settings }

List<AppPageTab> buildAppPageShellTabOrder(
  PremiumAccessPolicy policy,
  InterfaceSettingsModel interfaceSettings,
) {
  return [
    AppPageTab.calculator,
    if (interfaceSettings.showMaterialsTab) AppPageTab.materials,
    if (policy.shouldShowHistoryTab && interfaceSettings.showHistoryTab)
      AppPageTab.history,
    AppPageTab.settings,
  ];
}

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
  required List<AppPageTab> tabOrder,
  required bool showGcodeAction,
  required Future<void> Function() onHistoryLoaded,
}) {
  final historyMode = policy.historyView().allowed
      ? HistoryPageMode.full
      : HistoryPageMode.teaser;

  AppPageShellTab buildTab(AppPageTab tab) {
    switch (tab) {
      case AppPageTab.calculator:
        return AppPageShellTab(
          tab: tab,
          page: const CalculatorPage(),
          title: l10n.calculatorAppBarTitle,
          actions: [HeaderActions(showGcodeAction: showGcodeAction)],
          navigationItem: BottomNavigationBarItem(
            icon: const Icon(
              Icons.calculate,
              key: ValueKey<String>('nav.calculator.button'),
            ),
            label: l10n.calculatorNavLabel,
          ),
        );
      case AppPageTab.materials:
        return AppPageShellTab(
          tab: tab,
          page: const MaterialsPage(),
          title: l10n.materialsAppBarTitle,
          actions: [
            if (policy.stockTracking().allowed) ...[
              IconButton(
                key: const ValueKey<String>('materials.import.button'),
                tooltip: l10n.csvImportTitle,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CsvImportPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.file_upload_outlined, color: ICON_MUTED),
              ),
              IconButton(
                key: const ValueKey<String>('materials.export.button'),
                tooltip: l10n.materialsCsvExportTitle,
                onPressed: () => _exportMaterialsCsv(context, l10n),
                icon: const Icon(
                  Icons.file_download_outlined,
                  color: ICON_MUTED,
                ),
              ),
            ],
          ],
          navigationItem: BottomNavigationBarItem(
            icon: const Icon(
              Icons.inventory_2_outlined,
              key: ValueKey<String>('nav.materials.button'),
            ),
            label: l10n.materialsNavLabel,
          ),
        );
      case AppPageTab.history:
        return AppPageShellTab(
          tab: tab,
          page: HistoryPage(
            mode: historyMode,
            onHistoryLoaded: onHistoryLoaded,
          ),
          title: l10n.historyAppBarTitle,
          actions: const [],
          navigationItem: BottomNavigationBarItem(
            icon: const Icon(
              Icons.history,
              key: ValueKey<String>('nav.history.button'),
            ),
            label: l10n.historyNavLabel,
          ),
        );
      case AppPageTab.settings:
        return AppPageShellTab(
          tab: tab,
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
        );
    }
  }

  return tabOrder.map(buildTab).toList();
}

Future<void> _exportMaterialsCsv(
  BuildContext context,
  AppLocalizations l10n,
) async {
  String? filePath;
  try {
    final container = ProviderScope.containerOf(context, listen: false);
    if (!container.read(premiumAccessPolicyProvider).stockTracking().allowed) {
      BotToast.showText(text: l10n.csvImportAccessError);
      return;
    }
    final csv = await container
        .read(materialsCsvExportServiceProvider)
        .buildCsv();
    filePath = await writeCsvToFile(
      csv,
      fileName: 'materials_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        text: l10n.materialsCsvExportShareText,
      ),
    );
  } catch (_) {
    BotToast.showText(text: l10n.materialsCsvExportError);
  } finally {
    if (filePath != null) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
  }
}
