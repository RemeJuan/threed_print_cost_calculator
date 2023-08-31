import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/settings/material_form.dart';
import 'package:threed_print_cost_calculator/settings/materials.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
