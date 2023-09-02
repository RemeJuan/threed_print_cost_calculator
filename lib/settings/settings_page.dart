import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/l10n/l10n.dart';
import 'package:threed_print_cost_calculator/settings/material_form.dart';
import 'package:threed_print_cost_calculator/settings/materials.dart';

import 'general_settings_form.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final dbHelpers = DataBaseHelpers(DBName.settings);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const GeneralSettings(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Materials'),
            IconButton(
              onPressed: () async {
                await showDialog<void>(
                  context: context,
                  builder: (_) => const MaterialForm(),
                );
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(
          height: 100,
          child: Materials(),
        ),
      ],
    );
  }
}
