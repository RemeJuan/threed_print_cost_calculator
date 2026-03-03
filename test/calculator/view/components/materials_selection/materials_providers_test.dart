import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_providers.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

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

        // Listen for the first data emission using container.listen on the
        // StreamProvider's AsyncValue and complete a completer when data arrives.
        final completer = Completer<List<MaterialModel>>();
        final sub = container.listen<AsyncValue<List<MaterialModel>>>(
          materialsListProvider,
          (previous, next) {
            next.when(
              data: (list) {
                if (!completer.isCompleted) completer.complete(list);
              },
              loading: () {},
              error: (_, __) {},
            );
          },
          fireImmediately: true,
        );

        final materials = await completer.future;
        sub.close();

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
