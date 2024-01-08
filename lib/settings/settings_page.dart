import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/settings/general_settings_form.dart';
import 'package:threed_print_cost_calculator/settings/materials/materials.dart';
import 'package:threed_print_cost_calculator/settings/printers/printers.dart';

class SettingsPage extends HookWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final premium = useState<bool>(false);
    useEffect(
      () {
        Purchases.addCustomerInfoUpdateListener((info) {
          premium.value = info.entitlements.active.isNotEmpty;
        });
        return null;
      },
      [],
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const GeneralSettings(),
        const SizedBox(height: 16),
        if (premium.value) const Printers(),
        if (premium.value) const Materials(),
        // Materials(),
      ],
    );
  }
}
