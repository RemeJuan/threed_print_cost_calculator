import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/database/repositories/calculator_preferences_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void main() {
  late Database db;
  late ProviderContainer container;

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase(
      'typed_repo_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    'materials repository returns typed models and skips malformed rows',
    () async {
      final materialsStore = stringMapStoreFactory.store('materials');
      await materialsStore.record('valid').put(db, {
        'name': 'PLA',
        'cost': '25',
        'color': 'Black',
        'weight': '1000',
      });
      await StoreRef<String, Object?>(
        'materials',
      ).record('broken').put(db, 'bad');

      final materials = await container
          .read(materialsRepositoryProvider)
          .getMaterials();

      expect(materials, hasLength(1));
      expect(materials.single.id, 'valid');
      expect(materials.single.name, 'PLA');
    },
  );

  test(
    'settings repository returns safe defaults for malformed records',
    () async {
      await StoreRef<String, Object?>.main().record('settings').put(db, 'bad');

      final settings = await container
          .read(settingsRepositoryProvider)
          .getSettings();

      expect(settings.electricityCost, '');
      expect(settings.activePrinter, '');
    },
  );

  test(
    'history repository returns typed entries and drops malformed rows',
    () async {
      final historyStore = stringMapStoreFactory.store('history');
      await historyStore.record('ok').put(db, {
        'name': 'Benchy',
        'totalCost': 1.2,
        'riskCost': 0,
        'filamentCost': 0.5,
        'electricityCost': 0.2,
        'labourCost': 0,
        'date': DateTime.utc(2024, 1, 1).toIso8601String(),
        'printer': 'Prusa',
        'material': 'PLA',
        'weight': 15,
        'timeHours': '01:00',
      });
      await historyStore.record('bad').put(db, {
        'name': 'Broken',
        'date': 'not-a-date',
      });

      final entries = await container
          .read(historyRepositoryProvider)
          .getAllHistory();

      expect(entries, hasLength(1));
      expect(entries.single.key, 'ok');
      expect(entries.single.model.name, 'Benchy');
    },
  );

  test(
    'calculator preferences repository handles malformed values safely',
    () async {
      await StoreRef<String, Object?>.main().record('spoolCost').put(db, 'bad');

      final value = await container
          .read(calculatorPreferencesRepositoryProvider)
          .getStringValue('spoolCost');

      expect(value, '');
    },
  );
}
