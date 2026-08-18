import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

class FakeCalculatorNotifier extends CalculatorProvider {
  FakeCalculatorNotifier({CalculatorState? initialState})
    : _initialState = initialState ?? CalculatorState();

  final CalculatorState _initialState;
  int initCalls = 0;
  int submitCalls = 0;
  int loadFromHistoryCalls = 0;
  int resetCalls = 0;
  final List<String> wattUpdates = [];
  final List<String> selectedPrinters = [];
  final List<MaterialModel> selectedMaterials = [];
  HistoryEntry? lastLoadedHistory;

  @override
  CalculatorState build() => _initialState;

  @override
  Future<void> init() async => initCalls += 1;

  @override
  void submit({bool trackCompletedCosting = false}) => submitCalls += 1;

  @override
  Future<bool> loadFromHistory(HistoryEntry entry) async {
    loadFromHistoryCalls += 1;
    lastLoadedHistory = entry;
    return true;
  }

  @override
  Future<void> resetToDefaults() async => resetCalls += 1;

  @override
  void updateWatt(String value) => wattUpdates.add(value);

  @override
  Future<void> selectPrinter(String printerId) async =>
      selectedPrinters.add(printerId);

  @override
  Future<void> selectMaterial(MaterialModel material) async =>
      selectedMaterials.add(material);
}

class FakeCalculatorHelpers implements CalculatorHelpers {
  FakeCalculatorHelpers();

  HistoryModel? lastSavedPrint;

  @override
  Ref get ref => throw UnimplementedError();

  @override
  num electricityCost(num watts, num hours, num minutes, num cost) => 0;

  @override
  num filamentCost(num itemWeight, num spoolWeight, num cost) => 0;

  @override
  num multiMaterialFilamentCost(List<MaterialUsageInput> usages) => 0;

  @override
  Future<void> addOrUpdateRecord(String key, String value) async {}

  @override
  Future<void> savePrint(
    HistoryModel value, {
    required String errorMessage,
    required String successMessage,
  }) async {
    lastSavedPrint = value;
  }
}
