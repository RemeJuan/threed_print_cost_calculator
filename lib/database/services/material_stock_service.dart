import 'dart:math' as math;

import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

final materialStockServiceProvider = Provider<MaterialStockService>(
  MaterialStockService.new,
);

class MaterialStockService {
  MaterialStockService(this.ref);

  final Ref ref;

  Database get _db => ref.read(databaseProvider);

  StoreRef<String, Map<String, dynamic>> get _store =>
      stringMapStoreFactory.store('materials');

  Future<void> deductForSavedHistory(HistoryModel history) async {
    final totalsByMaterialId = <String, int>{};

    for (final usageMap in history.materialUsages) {
      final usage = MaterialUsageInput.fromMap(usageMap);
      final materialId = usage.materialId.trim();

      if (materialId.isEmpty || usage.weightGrams <= 0) {
        continue;
      }

      totalsByMaterialId.update(
        materialId,
        (current) => current + usage.weightGrams,
        ifAbsent: () => usage.weightGrams,
      );
    }

    if (totalsByMaterialId.isEmpty) return;

    await _db.transaction((txn) async {
      for (final entry in totalsByMaterialId.entries) {
        final snapshot = await _store.record(entry.key).getSnapshot(txn);
        if (snapshot == null) {
          continue;
        }

        final material = MaterialModel.fromMap(snapshot.value, snapshot.key);
        if (!material.autoDeductEnabled) {
          continue;
        }

        await _store
            .record(entry.key)
            .put(
              txn,
              material
                  .copyWith(
                    remainingWeight: math
                        .max(0, material.remainingWeight - entry.value)
                        .toDouble(),
                  )
                  .toMap(),
            );
      }
    });
  }
}
