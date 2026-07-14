import 'package:sembast/sembast.dart';

import 'package:threed_print_cost_calculator/shared/constants.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

Future<void> migrateLegacyHistoryRecords(Database db) async {
  final historyStore = StoreRef<Object?, Object?>('history');
  final records = await historyStore.find(db);

  for (final record in records) {
    final value = record.value as Map<String, dynamic>;
    final usages = value['materialUsages'];
    if (usages is List && usages.isNotEmpty) {
      continue;
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
    await historyStore.record(record.key).put(db, migrated);
  }
}
