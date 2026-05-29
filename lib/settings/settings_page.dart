import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/general_settings_form.dart';
import 'package:threed_print_cost_calculator/settings/printers/add_printer.dart';
import 'package:threed_print_cost_calculator/settings/printers/printers.dart';
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
            ),
            child: const Printers(),
          ),
        ],
      ],
    );
  }

  Widget _action(BuildContext context, Widget widget, Widget icon, Key key) {
    return IconButton(
      key: key,
      onPressed: () async {
        await showDialog<void>(context: context, builder: (_) => widget);
      },
      icon: icon,
    );
  }
}
