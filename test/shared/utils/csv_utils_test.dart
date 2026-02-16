import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void main() {
  group('csv_utils.generateCsv', () {
    test('generates header and properly quoted row for a single item', () {
      final item = HistoryModel(
        name: 'Test Print',
        totalCost: 7.14,
        riskCost: 0.12,
        filamentCost: 2.34,
        electricityCost: 1.23,
        labourCost: 3.45,
        date: DateTime.parse('2022-01-02T03:04:05Z'),
        printer: 'My,Printer',
        material: 'PLA "Red"',
        weight: 12.5,
        timeHours: '01:30',
      );

      final csv = generateCsv([item]);

      final lines = csv.split('\n').where((s) => s.isNotEmpty).toList();

      expect(lines.length, 2);

      expect(
        lines[0],
        'Date,Printer,Material,Weight (g),Time,Electricity,Filament,Labour,Risk,Total',
      );

      // Note: date is output with toIso8601String, which includes milliseconds and Z
      final expectedDate = '2022-01-02T03:04:05.000Z';
      final expectedRow =
          '"$expectedDate","My,Printer","PLA ""Red""","12.5","01:30","1.23","2.34","3.45","0.12","7.14"';

      expect(lines[1], expectedRow);
    });

    test('handles empty list', () {
      final csv = generateCsv([]);
      final lines = csv.split('\n').where((s) => s.isNotEmpty).toList();
      expect(lines.length, 1);
      expect(
        lines[0],
        'Date,Printer,Material,Weight (g),Time,Electricity,Filament,Labour,Risk,Total',
      );
    });
  });

  group('CsvUtils.queryHistory', () {
    late Database db;
    late ProviderContainer container;
    late CsvUtils csvUtils;
    final store = stringMapStoreFactory.store('history');

    setUp(() async {
      db = await databaseFactoryMemory.openDatabase('test.db');
      // Ensure a clean history store for each test run
      await store.delete(db);
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      csvUtils = container.read(csvUtilsProvider);
    });

    tearDown(() async {
      await db.close();
      container.dispose();
    });

    test(
      'returns all records sorted by date descending for ExportRange.all',
      () async {
        final base = DateTime.parse('2023-02-15T12:00:00Z');
        final itemNew = HistoryModel(
          name: 'New',
          totalCost: 1,
          riskCost: 0,
          filamentCost: 0,
          electricityCost: 0,
          labourCost: 0,
          date: base,
          printer: 'P1',
          material: 'M1',
          weight: 1,
          timeHours: '00:10',
        );
        final item5 = itemNew.copyWith(date: base.subtract(Duration(days: 5)));
        final item10 = itemNew.copyWith(
          date: base.subtract(Duration(days: 10)),
        );

        // Ensure date stored as ISO8601 string to match CsvUtils expectations
        await store.add(db, {
          ...itemNew.toMap(),
          'date': itemNew.date.toIso8601String(),
        });
        await store.add(db, {
          ...item5.toMap(),
          'date': item5.date.toIso8601String(),
        });
        await store.add(db, {
          ...item10.toMap(),
          'date': item10.date.toIso8601String(),
        });

        final results = await csvUtils.queryHistory(ExportRange.all, now: base);

        expect(results.length, 3);
        // newest first
        expect(
          results[0].date.toIso8601String(),
          itemNew.date.toIso8601String(),
        );
        expect(results[1].date.toIso8601String(), item5.date.toIso8601String());
        expect(
          results[2].date.toIso8601String(),
          item10.date.toIso8601String(),
        );
      },
    );

    test(
      'returns only records within last 7 days for ExportRange.last7Days',
      () async {
        final base = DateTime.parse('2023-02-15T12:00:00Z');
        final itemNew = HistoryModel(
          name: 'New',
          totalCost: 1,
          riskCost: 0,
          filamentCost: 0,
          electricityCost: 0,
          labourCost: 0,
          date: base,
          printer: 'P1',
          material: 'M1',
          weight: 1,
          timeHours: '00:10',
        );
        final item5 = itemNew.copyWith(date: base.subtract(Duration(days: 5)));
        final item10 = itemNew.copyWith(
          date: base.subtract(Duration(days: 10)),
        );

        await store.add(db, {
          ...itemNew.toMap(),
          'date': itemNew.date.toIso8601String(),
        });
        await store.add(db, {
          ...item5.toMap(),
          'date': item5.date.toIso8601String(),
        });
        await store.add(db, {
          ...item10.toMap(),
          'date': item10.date.toIso8601String(),
        });

        final results = await csvUtils.queryHistory(
          ExportRange.last7Days,
          now: base,
        );

        expect(results.length, 2);
        expect(
          results[0].date.toIso8601String(),
          itemNew.date.toIso8601String(),
        );
        expect(results[1].date.toIso8601String(), item5.date.toIso8601String());
      },
    );

    test(
      'returns records within last 30 days for ExportRange.last30Days',
      () async {
        final base = DateTime.parse('2023-02-15T12:00:00Z');
        final itemNew = HistoryModel(
          name: 'New',
          totalCost: 1,
          riskCost: 0,
          filamentCost: 0,
          electricityCost: 0,
          labourCost: 0,
          date: base,
          printer: 'P1',
          material: 'M1',
          weight: 1,
          timeHours: '00:10',
        );
        final item5 = itemNew.copyWith(date: base.subtract(Duration(days: 5)));
        final item40 = itemNew.copyWith(
          date: base.subtract(Duration(days: 40)),
        );

        await store.add(db, {
          ...itemNew.toMap(),
          'date': itemNew.date.toIso8601String(),
        });
        await store.add(db, {
          ...item5.toMap(),
          'date': item5.date.toIso8601String(),
        });
        await store.add(db, {
          ...item40.toMap(),
          'date': item40.date.toIso8601String(),
        });

        final results = await csvUtils.queryHistory(
          ExportRange.last30Days,
          now: base,
        );

        expect(results.length, 2);
        expect(
          results.any(
            (r) => r.date.toIso8601String() == item40.date.toIso8601String(),
          ),
          isFalse,
        );
      },
    );
  });
}
