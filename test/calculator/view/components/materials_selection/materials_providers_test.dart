import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_providers.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void main() {
  group('materials providers', () {
    test(
      'materialsListProvider loads materials and materialsByIdProvider maps them',
      () async {
        // Create in-memory Sembast DB and add material records
        final db = await databaseFactoryMemory.openDatabase(
          'test_materials.db',
        );
        final store = stringMapStoreFactory.store(DBName.materials.name);

        await store.add(db, {
          'name': 'PLA White',
          'cost': '20',
          'color': '#FFFFFF',
          'weight': '1000',
        });

        await store.add(db, {
          'name': 'ABS Black',
          'cost': '25',
          'color': '#000000',
          'weight': '1000',
        });

        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );

        addTearDown(() async {
          container.dispose();
          await db.close();
        });

        final materials = await container.read(materialsListProvider.future);
        expect(materials, isNotEmpty);
        expect(materials.length, equals(2));

        final map = container.read(materialsByIdProvider);
        expect(map.length, equals(2));

        for (final m in materials) {
          expect(map.containsKey(m.id), isTrue);
          expect(map[m.id]!.name, equals(m.name));
        }
      },
    );
  });
}
