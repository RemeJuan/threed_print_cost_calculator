import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/general_settings_form.dart';
import 'package:threed_print_cost_calculator/settings/printers/add_printer.dart';
import 'package:threed_print_cost_calculator/settings/printers/printers.dart';
import 'package:threed_print_cost_calculator/settings/settings_section.dart';
import 'package:threed_print_cost_calculator/settings/work_costs_form.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.watch(isPremiumProvider);

    final style = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(color: Colors.white);
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      children: [
        SettingsSection(
          headerKey: const ValueKey<String>('settings.general.section'),
          bodyKey: const ValueKey<String>('settings.general.body'),
          title: Text(l10n.generalHeader, style: style),
          child: const GeneralSettings(),
        ),
        if (isPremium) ...[
          const SizedBox(height: 16),
          SettingsSection(
            headerKey: const ValueKey<String>('settings.workCost.section'),
            bodyKey: const ValueKey<String>('settings.workCost.body'),
            title: Text(l10n.workCostsLabel, style: style),
            child: const WorkCostsSettings(),
          ),
          const SizedBox(height: 16),
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
