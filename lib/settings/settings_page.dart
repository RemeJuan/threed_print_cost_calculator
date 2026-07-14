import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/backup_restore_section.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/general_settings_form.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_page.dart';
import 'package:threed_print_cost_calculator/settings/components/settings_premium_card.dart';
import 'package:threed_print_cost_calculator/settings/components/settings_printers_section.dart';
import 'package:threed_print_cost_calculator/settings/settings_section.dart';
import 'package:threed_print_cost_calculator/settings/work_costs_form.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final policy = ref.watch(premiumAccessPolicyProvider);
    final interfaceSettings = ref.watch(interfaceSettingsProvider);

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
          SettingsPrintersSection(policy: policy, titleStyle: style),
        ],
        const SizedBox(height: kAppSpace16),
        const BackupRestoreSection(),
        if (!policy.isPremium) ...[
          const SizedBox(height: kAppSpace16),
          SettingsPremiumCard(policy: policy),
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
          : () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => widget));
            },
      icon: icon,
    );
  }
}
