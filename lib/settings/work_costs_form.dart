import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

class WorkCostsSettings extends HookConsumerWidget {
  const WorkCostsSettings({super.key});

  @override
  Widget build(context, ref) {
    final l10n = S.of(context);
    final db = ref.read(databaseProvider);
    final store = stringMapStoreFactory.store();
    final calculatorHelpers = ref.read(calculatorHelpersProvider);

    return StreamBuilder(
      stream: store.records(['wearAndTear', 'failureRisk', 'labourRate']).onSnapshots(db),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data ?? [];
        final wearAndTear = data.firstWhere(
          (s) => s.key == 'wearAndTear',
          orElse: () => RecordSnapshot(store.record('wearAndTear'), null),
        ).value as Map<String, dynamic>?;
        final failureRisk = data.firstWhere(
          (s) => s.key == 'failureRisk',
          orElse: () => RecordSnapshot(store.record('failureRisk'), null),
        ).value as Map<String, dynamic>?;
        final labourRate = data.firstWhere(
          (s) => s.key == 'labourRate',
          orElse: () => RecordSnapshot(store.record('labourRate'), null),
        ).value as Map<String, dynamic>?;

        return Container(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              TextFormField(
                initialValue: (wearAndTear?['value'] ?? '').toString(),
                onChanged: (value) async {
                  await calculatorHelpers.addOrUpdateRecord('wearAndTear', value);
                },
                decoration: InputDecoration(
                  labelText: l10n.wearAndTearLabel,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: (failureRisk?['value'] ?? '').toString(),
                onChanged: (value) async {
                  await calculatorHelpers.addOrUpdateRecord('failureRisk', value);
                },
                decoration: InputDecoration(
                  labelText: l10n.failureRiskLabel,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: (labourRate?['value'] ?? '').toString(),
                onChanged: (value) async {
                  await calculatorHelpers.addOrUpdateRecord('labourRate', value);
                },
                decoration: InputDecoration(
                  labelText: l10n.labourRateLabel,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        );
      },
    );
  }
}
