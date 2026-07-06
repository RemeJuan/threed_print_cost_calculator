import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/backup_restore_section.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/general_settings_form.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_page.dart';
import 'package:threed_print_cost_calculator/settings/printers/add_printer.dart';
import 'package:threed_print_cost_calculator/settings/printers/printers.dart';
import 'package:threed_print_cost_calculator/settings/settings_section.dart';
import 'package:threed_print_cost_calculator/settings/work_costs_form.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final policy = ref.watch(premiumAccessPolicyProvider);
    final printersAsync = ref.watch(printersStreamProvider);
    final interfaceSettings = ref.watch(interfaceSettingsProvider);
    final printerCount = printersAsync.maybeWhen(
      data: (printers) => printers.length,
      orElse: () => null,
    );
    final canAddPrinter =
        printerCount != null && policy.canCreatePrinter(printerCount).allowed;
    final showPrinterLimitMessage =
        printerCount != null && !policy.isPremium && !canAddPrinter;

    final style = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(color: TEXT_PRIMARY);
    return ListView(
      padding: const EdgeInsets.all(kAppSpace16),
      physics: const ClampingScrollPhysics(),
      children: [
        SettingsSection(
          headerKey: const ValueKey<String>('settings.general.section'),
          bodyKey: const ValueKey<String>('settings.general.body'),
          title: Text(l10n.generalHeader, style: style),
          child: const GeneralSettings(),
        ),
        const SizedBox(height: kAppSpace16),
        SettingsSection(
          headerKey: const ValueKey<String>('settings.interface.section'),
          bodyKey: const ValueKey<String>('settings.interface.body'),
          title: Text(l10n.interfaceSettingsHeader, style: style),
          subtitle: Text(
            interfaceSettings.isDefaultView
                ? l10n.interfaceSettingsDefaultView
                : l10n.interfaceSettingsCustomView,
          ),
          action: _action(
            context,
            const InterfaceSettingsPage(),
            const Icon(Icons.tune),
            const ValueKey<String>('settings.interface.button'),
          ),
          childSpacing: false,
          child: const SizedBox.shrink(),
        ),
        if (policy.labourPricing().allowed || policy.riskPricing().allowed) ...[
          const SizedBox(height: kAppSpace16),
          SettingsSection(
            headerKey: const ValueKey<String>('settings.workCost.section'),
            bodyKey: const ValueKey<String>('settings.workCost.body'),
            title: Text(l10n.workCostsLabel, style: style),
            child: const WorkCostsSettings(),
          ),
        ],
        if (policy.printers().allowed) ...[
          const SizedBox(height: kAppSpace16),
          SettingsSection(
            headerKey: const ValueKey<String>('settings.printers.section'),
            bodyKey: const ValueKey<String>('settings.printers.body'),
            title: Text(l10n.printersHeader, style: style),
            action: _action(
              context,
              const AddPrinter(),
              const Icon(Icons.add),
              const ValueKey<String>('settings.printers.add.button'),
              enabled: canAddPrinter,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Printers(),
                if (showPrinterLimitMessage)
                  Padding(
                    padding: const EdgeInsets.only(top: kAppSpace8),
                    child: Text(
                      l10n.printerLimitReachedMessage,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: TEXT_TERTIARY),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: kAppSpace16),
        const BackupRestoreSection(),
        if (!policy.isPremium) ...[
          const SizedBox(height: kAppSpace16),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsPremiumCardTitle,
                  key: const ValueKey<String>('settings.premium.title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: TEXT_PRIMARY,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: kAppSpace8),
                Text(
                  l10n.settingsPremiumCardBody,
                  key: const ValueKey<String>('settings.premium.body'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: TEXT_SECONDARY),
                ),
                const SizedBox(height: kAppSpace12),
                SizedBox(
                  width: double.infinity,
                  child: AppSecondaryButton(
                    key: const ValueKey<String>('settings.premium.button'),
                    onPressed: () {
                      AppAnalytics.safeLog(
                        () => AppAnalytics.premiumFeatureTapped(
                          'settings_premium_card',
                          isPro: policy.isPremium,
                          source: 'settings',
                        ),
                      );
                      ref
                          .read(paywallPresenterProvider)
                          .present(
                            'pro',
                            triggerFeature: 'settings_premium_card',
                            purchaseSource: 'settings',
                            source: 'settings',
                          );
                    },
                    label: l10n.settingsPremiumCardCta,
                    minHeight: 42,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _action(
    BuildContext context,
    Widget widget,
    Widget icon,
    Key key, {
    bool enabled = true,
  }) {
    return IconButton(
      key: key,
      onPressed: !enabled
          ? null
          : () async {
              await showDialog<void>(context: context, builder: (_) => widget);
            },
      icon: icon,
    );
  }
}
