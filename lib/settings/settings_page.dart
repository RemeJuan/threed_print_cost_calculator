import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/settings/general_settings_form.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        GeneralSettings(),
        SizedBox(height: 16),
        // Materials(),
      ],
    );
  }
}
