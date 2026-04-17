import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/test_tools/seed_loader.dart';
import 'package:threed_print_cost_calculator/shared/test_tools/test_data_service.dart';

class _FakeSeedLoader extends SeedLoader {
  _FakeSeedLoader(this.bundle) : super(bundle: null);

  final SeedDataBundle bundle;

  @override
  Future<SeedDataBundle> load() async => bundle;
}

SeedDataBundle _bundle() {
  return const SeedDataBundle(
    generalSettings: {
      'electricityCost': '0.18',
      'wattage': '120',
      'activePrinter': 'prusa_mk4',
      'selectedMaterial': 'pla_white',
      'wearAndTear': '1.25',
      'failureRisk': '4.5',
      'labourRate': '18',
    },
    sharedPreferences: {
      'hideProPromotions': false,
      'run_count': 0,
      'paywall': false,
    },
    printers: [
      {
        'id': 'prusa_mk4',
        'name': 'Prusa MK4',
        'bedSize': '250 x 210 x 220',
        'wattage': '120',
      },
      {
        'id': 'bambu_a1_mini',
        'name': 'Bambu A1 Mini',
        'bedSize': '180 x 180 x 180',
        'wattage': '60',
      },
      {
        'id': 'voron_v0',
        'name': 'Voron V0.2',
        'bedSize': '120 x 120 x 120',
        'wattage': '80',
      },
    ],
    materials: [
      {
        'id': 'pla_white',
        'name': 'PLA White',
        'cost': '24.90',
        'color': 'White',
        'weight': '1000',
        'autoDeductEnabled': true,
        'originalWeight': 1000,
        'remainingWeight': 640,
      },
      {
        'id': 'petg_black',
        'name': 'PETG Black',
        'cost': '29.50',
        'color': 'Black',
        'weight': '1000',
        'autoDeductEnabled': false,
        'originalWeight': 1000,
        'remainingWeight': 1000,
      },
      {
        'id': 'abs_red',
        'name': 'ABS Red',
        'cost': '31.20',
        'color': 'Red',
        'weight': '750',
        'autoDeductEnabled': true,
        'originalWeight': 750,
        'remainingWeight': 520,
      },
    ],
    history: [
      {
        'id': 'history_calibration_cube',
        'name': 'Calibration Cube',
        'totalCost': 1.85,
        'riskCost': 0.09,
        'filamentCost': 1.25,
        'electricityCost': 0.07,
        'labourCost': 0.44,
        'date': '2026-04-04T10:15:00.000Z',
        'printer': 'Prusa MK4',
        'material': 'PLA White',
        'weight': 18,
        'materialUsages': [
          {
            'materialId': 'pla_white',
            'materialName': 'PLA White',
            'costPerKg': 24.9,
            'weightGrams': 18,
          },
        ],
        'timeHours': '00:24',
      },
      {
        'id': 'history_tool_holder',
        'name': 'Tool Holder',
        'totalCost': 5.72,
        'riskCost': 0.29,
        'filamentCost': 3.84,
        'electricityCost': 0.18,
        'labourCost': 1.41,
        'date': '2026-04-10T14:30:00.000Z',
        'printer': 'Bambu A1 Mini',
        'material': 'PETG Black',
        'weight': 74,
        'materialUsages': [
          {
            'materialId': 'petg_black',
            'materialName': 'PETG Black',
            'costPerKg': 29.5,
            'weightGrams': 74,
          },
        ],
        'timeHours': '01:40',
      },
      {
        'id': 'history_multicolor_spool',
        'name': 'Multicolor Spool Mount',
        'totalCost': 9.46,
        'riskCost': 0.42,
        'filamentCost': 6.71,
        'electricityCost': 0.22,
        'labourCost': 2.11,
        'date': '2026-04-14T09:05:00.000Z',
        'printer': 'Voron V0.2',
        'material': 'PLA White + ABS Red',
        'weight': 132,
        'materialUsages': [
          {
            'materialId': 'pla_white',
            'materialName': 'PLA White',
            'costPerKg': 24.9,
            'weightGrams': 92,
          },
          {
            'materialId': 'abs_red',
            'materialName': 'ABS Red',
            'costPerKg': 31.2,
            'weightGrams': 40,
          },
        ],
        'timeHours': '02:15',
      },
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Database db;
  late SharedPreferences prefs;
  late ProviderContainer container;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase(
      'test_data_service_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        seedLoaderProvider.overrideWithValue(_FakeSeedLoader(_bundle())),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await prefs.clear();
  });

  test('seed writes deterministic demo data', () async {
    final service = container.read(testDataServiceProvider);

    final result = await service.seed();

    expect(result.success, isTrue);
    expect(
      await stringMapStoreFactory.store(DBName.printers.name).count(db),
      3,
    );
    expect(
      await stringMapStoreFactory.store(DBName.materials.name).count(db),
      3,
    );
    expect(await stringMapStoreFactory.store(DBName.history.name).count(db), 3);
    expect(
      await StoreRef<String, Object?>.main()
          .record(DBName.settings.name)
          .exists(db),
      isTrue,
    );
    expect(prefs.getBool(testPremiumOverridePreferenceKey), isNull);
  });

  test('re-running seed replaces existing data', () async {
    final service = container.read(testDataServiceProvider);

    await service.seed();
    final firstCounts = await Future.wait<int>([
      stringMapStoreFactory.store(DBName.printers.name).count(db),
      stringMapStoreFactory.store(DBName.materials.name).count(db),
      stringMapStoreFactory.store(DBName.history.name).count(db),
    ]);

    await service.seed();
    final secondCounts = await Future.wait<int>([
      stringMapStoreFactory.store(DBName.printers.name).count(db),
      stringMapStoreFactory.store(DBName.materials.name).count(db),
      stringMapStoreFactory.store(DBName.history.name).count(db),
    ]);

    expect(secondCounts, firstCounts);
  });

  test('purge clears app data and prefs', () async {
    final service = container.read(testDataServiceProvider);

    await service.seed();
    final result = await service.purge();

    expect(result.success, isTrue);
    expect(
      await stringMapStoreFactory.store(DBName.printers.name).count(db),
      0,
    );
    expect(
      await stringMapStoreFactory.store(DBName.materials.name).count(db),
      0,
    );
    expect(await stringMapStoreFactory.store(DBName.history.name).count(db), 0);
    expect(await stringMapStoreFactory.store('printer_index').count(db), 0);
    expect(
      await stringMapStoreFactory.store('history_search_index').count(db),
      0,
    );
    expect(prefs.getKeys(), isEmpty);
  });

  test('enablePremiumAndSeed adds premium override only after seed', () async {
    final service = container.read(testDataServiceProvider);

    final result = await service.enablePremiumAndSeed();

    expect(result.success, isTrue);
    expect(prefs.getBool(testPremiumOverridePreferenceKey), isTrue);
    expect(
      await stringMapStoreFactory.store(DBName.printers.name).count(db),
      3,
    );
  });
}
