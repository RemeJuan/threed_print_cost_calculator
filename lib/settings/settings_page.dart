import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/app/components/accordion_menu/accordion_menu.dart';
import 'package:threed_print_cost_calculator/app/components/accordion_menu/model/accordion_item_model.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/general_settings_form.dart';
import 'package:threed_print_cost_calculator/settings/materials/materials.dart';
import 'package:threed_print_cost_calculator/settings/printers/add_printer.dart';
import 'package:threed_print_cost_calculator/settings/printers/printers.dart';
import 'package:threed_print_cost_calculator/settings/work_costs_form.dart';

import 'materials/material_form.dart';

class SettingsPage extends HookWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final premium = useState<bool>(false);

    useEffect(() {
      Purchases.addCustomerInfoUpdateListener((info) {
        premium.value = info.entitlements.active.isNotEmpty;
      });
      return null;
    }, []);

    final style = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(color: Colors.white);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AccordionMenu(
          items: [
            AccordionItem(
              header: Text("General", style: style),
              body: const GeneralSettings(),
              initiallyExpanded: true,
              isLocked: !premium.value,
            ),
            if (premium.value)
              AccordionItem(
                header: Text(l10n.printersHeader, style: style),
                body: const Printers(),
                action: _action(
                  context,
                  const AddPrinter(),
                  const Icon(Icons.add),
                ),
              ),
            if (premium.value)
              AccordionItem(
                header: Text(l10n.materialsHeader, style: style),
                body: const Materials(),
                action: _action(
                  context,
                  const MaterialForm(),
                  const Icon(Icons.add),
                ),
              ),
            AccordionItem(
              header: Text(l10n.workCostsLabel, style: style),
              body: const WorkCostsSettings(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _action(BuildContext context, Widget widget, Widget icon) {
    return IconButton(
      onPressed: () async {
        await showDialog<void>(context: context, builder: (_) => widget);
      },
      icon: icon,
    );
  }
}
