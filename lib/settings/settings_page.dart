import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/components/accordion_menu/accordion_menu.dart';
import 'package:threed_print_cost_calculator/shared/components/accordion_menu/model/accordion_item_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/general_settings_form.dart';
import 'package:threed_print_cost_calculator/settings/materials/materials.dart';
import 'package:threed_print_cost_calculator/settings/printers/add_printer.dart';
import 'package:threed_print_cost_calculator/settings/printers/printers.dart';
import 'package:threed_print_cost_calculator/settings/work_costs_form.dart';

import 'materials/material_form.dart';

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
      children: [
        AccordionMenu(
          items: [
            AccordionItem(
              headerKey: const ValueKey<String>('settings.general.section'),
              bodyKey: const ValueKey<String>('settings.general.body'),
              header: Text("General", style: style),
              body: const GeneralSettings(),
              initiallyExpanded: true,
              isLocked: !isPremium,
            ),
            if (isPremium) ...[
              AccordionItem(
                headerKey: const ValueKey<String>('settings.printers.section'),
                bodyKey: const ValueKey<String>('settings.printers.body'),
                header: Text(l10n.printersHeader, style: style),
                body: const Printers(),
                action: _action(
                  context,
                  const AddPrinter(),
                  const Icon(Icons.add),
                  const ValueKey<String>('settings.printers.add.button'),
                ),
              ),
              AccordionItem(
                headerKey: const ValueKey<String>('settings.materials.section'),
                bodyKey: const ValueKey<String>('settings.materials.body'),
                header: Text(l10n.materialsHeader, style: style),
                body: const Materials(),
                action: _action(
                  context,
                  const MaterialForm(),
                  const Icon(Icons.add),
                  const ValueKey<String>('settings.materials.add.button'),
                ),
              ),
              AccordionItem(
                headerKey: const ValueKey<String>('settings.workCost.section'),
                bodyKey: const ValueKey<String>('settings.workCost.body'),
                header: Text(l10n.workCostsLabel, style: style),
                body: const WorkCostsSettings(),
              ),
            ],
          ],
        ),
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
