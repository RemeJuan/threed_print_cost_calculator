import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

abstract final class IntegrationFixtures {
  static const electricityCost = '3.00';
  static const wattage = '120';
  static const printerAId = 'test-printer-a';
  static const printerAName = 'Test Printer A';
  static const materialPlaBlackId = 'pla-test-black';
  static const materialPlaBlackName = 'PLA Test Black';

  static const printerA = PrinterModel(
    id: printerAId,
    name: printerAName,
    bedSize: '220x220x250',
    wattage: wattage,
    archived: false,
  );

  static const materialPlaBlack = MaterialModel(
    id: materialPlaBlackId,
    name: materialPlaBlackName,
    cost: '200.00',
    color: 'Black',
    weight: '1000',
    archived: false,
  );

  static const settings = GeneralSettingsModel(
    electricityCost: electricityCost,
    wattage: wattage,
    activePrinter: printerAId,
    selectedMaterial: materialPlaBlackId,
    wearAndTear: '',
    failureRisk: '',
    labourRate: '',
  );

  static HistoryModel historyEntry({DateTime? date}) {
    return HistoryModel(
      name: 'Seeded Test Print',
      totalCost: 30.9,
      riskCost: 0,
      filamentCost: 30,
      electricityCost: 0.9,
      labourCost: 0,
      date: date ?? DateTime.parse('2024-01-01T12:00:00.000Z'),
      printer: printerAName,
      material: materialPlaBlackName,
      weight: 150,
      materialUsages: const [
        {
          'materialId': materialPlaBlackId,
          'materialName': materialPlaBlackName,
          'costPerKg': 200.0,
          'weightGrams': 150,
        },
      ],
      timeHours: '02:30',
    );
  }
}
