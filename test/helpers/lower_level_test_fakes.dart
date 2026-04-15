import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

class FakeCalculatorNotifier extends CalculatorProvider {
  FakeCalculatorNotifier({CalculatorState? initialState})
    : _initialState = initialState ?? CalculatorState();

  final CalculatorState _initialState;
  int initCalls = 0;
  int submitCalls = 0;
  final List<String> wattUpdates = [];
  final List<MaterialModel> selectedMaterials = [];

  @override
  CalculatorState build() => _initialState;

  @override
  Future<void> init() async {
    initCalls += 1;
  }

  @override
  void submit() {
    submitCalls += 1;
  }

  @override
  void updateWatt(String value) {
    wattUpdates.add(value);
  }

  @override
  void selectMaterial(MaterialModel material) {
    selectedMaterials.add(material);
  }
}

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({GeneralSettingsModel? initialSettings})
    : _settings = initialSettings ?? GeneralSettingsModel.initial();

  GeneralSettingsModel _settings;
  GeneralSettingsModel? lastSavedSettings;

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<GeneralSettingsModel> getSettings() async => _settings;

  @override
  Stream<GeneralSettingsModel> watchSettings() async* {
    yield _settings;
  }

  @override
  Future<void> saveSettings(GeneralSettingsModel settings) async {
    _settings = settings;
    lastSavedSettings = settings;
  }
}

class FakePrintersRepository implements PrintersRepository {
  FakePrintersRepository([Map<String, PrinterModel>? printers])
    : _printers = printers ?? const {};

  final Map<String, PrinterModel> _printers;

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<List<PrinterModel>> getPrinters() async => _printers.values.toList();

  @override
  Stream<List<PrinterModel>> watchPrinters() async* {
    yield _printers.values.toList();
  }

  @override
  Future<PrinterModel?> getPrinterById(String id) async => _printers[id];

  @override
  Future<Object?> savePrinter(PrinterModel printer, {String? id}) async =>
      id ?? printer.id;

  @override
  Future<void> deletePrinter(String id) async {}
}

class FakeMaterialsRepository implements MaterialsRepository {
  FakeMaterialsRepository([Map<String, MaterialModel>? materials])
    : _materials = Map<String, MaterialModel>.from(materials ?? const {});

  final Map<String, MaterialModel> _materials;

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<List<MaterialModel>> getMaterials() async =>
      _materials.values.toList();

  @override
  Stream<List<MaterialModel>> watchMaterials() async* {
    yield _materials.values.toList();
  }

  @override
  Future<MaterialModel?> getMaterialById(String id) async => _materials[id];

  @override
  Future<Object?> saveMaterial(MaterialModel material, {String? id}) async {
    final key = id ?? material.id;
    if (key.isNotEmpty) {
      _materials[key] = material.copyWith(id: key);
    }
    return key;
  }

  @override
  Future<void> deleteMaterial(String id) async {}
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

class FakePaywallPresenter implements PaywallPresenter {
  int calls = 0;
  String? lastOfferingId;

  @override
  Future<void> present(String offeringId) async {
    calls += 1;
    lastOfferingId = offeringId;
  }
}
