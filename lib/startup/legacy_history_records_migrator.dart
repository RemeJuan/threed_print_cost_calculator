import 'package:sembast/sembast.dart';

import 'package:threed_print_cost_calculator/shared/constants.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

const legacyHistoryMigrationBatchSize = 32;

Future<void> _yieldToEventLoop() => Future<void>.delayed(Duration.zero);

Future<void> migrateLegacyHistoryRecords(Database db) async {
  final historyStore = StoreRef<Object?, Object?>('history');
  final records = await historyStore.find(db);

  var index = 0;
  for (final record in records) {
    if (index > 0 && index % legacyHistoryMigrationBatchSize == 0) {
      await _yieldToEventLoop();
    }
    index++;

    await db.transaction((txn) async {
      final current = await historyStore.record(record.key).get(txn);
      if (current is! Map) {
        return;
      }

      final value = Map<String, dynamic>.from(current);
      final usages = value['materialUsages'];
      if (usages is List && usages.isNotEmpty) {
        return;
      }

      final rawWeight = value['weight'];
      final parsedWeight = rawWeight is num
          ? rawWeight.toInt()
          : parseLocalizedInt(rawWeight);

      final migrated = {
        ...value,
        'materialUsages': [
          {
            'materialId': value['materialId']?.toString() ?? '',
            'materialName': value['material']?.toString() ?? kUnassignedLabel,
            'costPerKg': 0,
            'weightGrams': parsedWeight,
          },
        ],
      };
      await historyStore.record(record.key).put(txn, migrated);
    });
  }
}
