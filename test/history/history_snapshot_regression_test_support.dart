import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';

const historyCsvHeader =
    'Date,Printer,Material,Materials,Weight (g),Time,Electricity,Filament,Labour,Risk,Total,Pricing Markup %,Pricing Markup,Pricing Setup Fee,Pricing Rounding,Pricing Subtotal,Pricing Rounding Adjustment,Final Price';

Future<Database> openHistorySnapshotDatabase() async {
  return databaseFactoryMemory.openDatabase(
    'history_snapshot_${DateTime.now().microsecondsSinceEpoch}.db',
  );
}

HistoryModel singleMaterialModel() => HistoryModel(
  name: 'Single snapshot',
  totalCost: 14.11,
  riskCost: 1.41,
  filamentCost: 8.19,
  electricityCost: 1.23,
  labourCost: 3.28,
  date: DateTime.parse('2024-01-02T03:04:05.000Z'),
  printer: 'Prusa MK4',
  material: 'PLA Black',
  weight: 123,
  materialUsages: const [
    {
      'materialId': 'pla-black',
      'materialName': 'PLA Black',
      'costPerKg': 66.58536585365853,
      'weightGrams': 123,
    },
  ],
  timeHours: '01:45',
  pricingMarkupPercent: 25.0,
  pricingMarkupAmount: 2.5,
  pricingSetupFee: 1.25,
  pricingRoundingMode: '.99',
  pricingSubtotalBeforeRounding: 13.75,
  pricingRoundingAdjustment: 0.25,
  finalPrice: 14.0,
  pricingUsedOverrides: true,
);

HistoryModel multiMaterialModel() => HistoryModel(
  name: 'Multi snapshot',
  totalCost: 21.17,
  riskCost: 2.12,
  filamentCost: 12.47,
  electricityCost: 1.85,
  labourCost: 4.73,
  date: DateTime.parse('2024-01-03T04:05:06.000Z'),
  printer: 'Bambu Lab A1',
  material: 'PLA Black +1',
  weight: 155,
  materialUsages: const [
    {
      'materialId': 'pla-black',
      'materialName': 'PLA Black',
      'costPerKg': 60,
      'weightGrams': 100,
    },
    {
      'materialId': 'pla-white',
      'materialName': 'PLA White',
      'costPerKg': 117.63636363636364,
      'weightGrams': 55,
    },
  ],
  timeHours: '02:10',
);

Future<Map<String, dynamic>> rawHistoryRecord(
  StoreRef<Object?, Map<String, dynamic>> historyStore,
  Database db,
  Object? key,
) async => (await historyStore.record(key).get(db))!;

void expectSnapshotValues(HistoryModel actual, HistoryModel expected) {
  expect(actual.totalCost, expected.totalCost);
  expect(actual.electricityCost, expected.electricityCost);
  expect(actual.filamentCost, expected.filamentCost);
  expect(actual.labourCost, expected.labourCost);
  expect(actual.riskCost, expected.riskCost);
  expect(actual.weight, expected.weight);
  expect(actual.timeHours, expected.timeHours);
  expect(actual.materialUsages, expected.materialUsages);
}

String expectedCsvRow(HistoryModel item) {
  final materials = item.materialUsages
      .map((usage) => '${usage['materialName']}:${usage['weightGrams']}g')
      .join('; ');
  return '"${item.date.toIso8601String()}",'
      '"${item.printer}",'
      '"${item.material}",'
      '"$materials",'
      '"${item.weight.toDouble()}",'
      '"${item.timeHours}",'
      '"${item.electricityCost}",'
      '"${item.filamentCost}",'
      '"${item.labourCost}",'
      '"${item.riskCost}",'
      '"${item.totalCost}",'
      '"${item.pricingMarkupPercent ?? ''}",'
      '"${item.pricingMarkupAmount ?? ''}",'
      '"${item.pricingSetupFee ?? ''}",'
      '"${item.pricingRoundingMode ?? ''}",'
      '"${item.pricingSubtotalBeforeRounding ?? ''}",'
      '"${item.pricingRoundingAdjustment ?? ''}",'
      '"${item.finalPrice ?? ''}"';
}

Future<String> csvForStoredHistory(CsvUtils csvUtils) async {
  final items = await csvUtils.queryHistory(ExportRange.all);
  return csvUtils.generateCsvForItems(items, historyCsvHeader);
}
