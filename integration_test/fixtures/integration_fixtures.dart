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
    originalWeight: 1000,
    remainingWeight: 1000,
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
    return buildHistoryEntry(date: date);
  }

  static PrinterModel buildPrinter({
    required String id,
    required String name,
    required String bedSize,
    required String wattage,
    bool archived = false,
  }) {
    return PrinterModel(
      id: id,
      name: name,
      bedSize: bedSize,
      wattage: wattage,
      archived: archived,
    );
  }

  static MaterialModel buildMaterial({
    required String id,
    required String name,
    required String cost,
    required String color,
    required String weight,
    bool archived = false,
  }) {
    return MaterialModel(
      id: id,
      name: name,
      cost: cost,
      color: color,
      weight: weight,
      archived: archived,
    );
  }

  static GeneralSettingsModel buildSettings({
    String electricityCost = electricityCost,
    String wattage = IntegrationFixtures.wattage,
    String activePrinter = '',
    String selectedMaterial = '',
    String wearAndTear = '',
    String failureRisk = '',
    String labourRate = '',
  }) {
    return GeneralSettingsModel(
      electricityCost: electricityCost,
      wattage: wattage,
      activePrinter: activePrinter,
      selectedMaterial: selectedMaterial,
      wearAndTear: wearAndTear,
      failureRisk: failureRisk,
      labourRate: labourRate,
    );
  }

  static HistoryModel buildHistoryEntry({
    String name = 'Seeded Test Print',
    double totalCost = 30.9,
    double riskCost = 0,
    double filamentCost = 30,
    double electricityCost = 0.9,
    double labourCost = 0,
    DateTime? date,
    String printer = printerAName,
    String material = materialPlaBlackName,
    double weight = 150,
    List<Map<String, Object>>? materialUsages,
    String timeHours = '02:30',
  }) {
    return HistoryModel(
      name: name,
      totalCost: totalCost,
      riskCost: riskCost,
      filamentCost: filamentCost,
      electricityCost: electricityCost,
      labourCost: labourCost,
      date: date ?? DateTime.parse('2024-01-01T12:00:00.000Z'),
      printer: printer,
      material: material,
      weight: weight,
      materialUsages:
          materialUsages ??
          const [
            {
              'materialId': materialPlaBlackId,
              'materialName': materialPlaBlackName,
              'costPerKg': 200.0,
              'weightGrams': 150,
            },
          ],
      timeHours: timeHours,
    );
  }
}
