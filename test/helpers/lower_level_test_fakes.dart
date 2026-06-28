import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_purchase_gateway.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

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
  Future<void> init() async {
    initCalls += 1;
  }

  @override
  void submit({bool trackCompletedCosting = false}) {
    submitCalls += 1;
  }

  @override
  Future<bool> loadFromHistory(HistoryEntry entry) async {
    loadFromHistoryCalls += 1;
    lastLoadedHistory = entry;
    return true;
  }

  @override
  Future<void> resetToDefaults() async {
    resetCalls += 1;
  }

  @override
  void updateWatt(String value) {
    wattUpdates.add(value);
  }

  @override
  Future<void> selectPrinter(String printerId) async {
    selectedPrinters.add(printerId);
  }

  @override
  Future<void> selectMaterial(MaterialModel material) async {
    selectedMaterials.add(material);
  }
}

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({GeneralSettingsModel? initialSettings})
    : _settings = initialSettings ?? GeneralSettingsModel.initial(),
      _controller = StreamController<GeneralSettingsModel>.broadcast();

  GeneralSettingsModel _settings;
  final StreamController<GeneralSettingsModel> _controller;
  GeneralSettingsModel? lastSavedSettings;

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<GeneralSettingsModel> getSettings() async => _settings;

  @override
  Stream<GeneralSettingsModel> watchSettings() async* {
    yield _settings;
    yield* _controller.stream;
  }

  @override
  Future<void> saveSettings(GeneralSettingsModel settings) async {
    _settings = settings;
    lastSavedSettings = settings;
    if (!_controller.isClosed) {
      _controller.add(settings);
    }
  }

  void emit(GeneralSettingsModel settings) {
    _settings = settings;
    if (!_controller.isClosed) {
      _controller.add(settings);
    }
  }

  Future<void> dispose() async {
    await _controller.close();
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

  @override
  Future<int> count() async => _printers.length;
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

  @override
  Future<int> count() async => _materials.length;
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
  String? lastTriggerFeature;
  String? lastPurchaseSource;
  String? lastSource;
  String? lastDefaultEntryPoint;
  int? lastLaunchCount;

  @override
  Future<void> present(
    String offeringId, {
    required String triggerFeature,
    required String purchaseSource,
    String defaultEntryPoint = 'manual',
    String source = 'unknown',
    int? launchCount,
  }) async {
    calls += 1;
    lastOfferingId = offeringId;
    lastTriggerFeature = triggerFeature;
    lastPurchaseSource = purchaseSource;
    lastSource = source;
    lastDefaultEntryPoint = defaultEntryPoint;
    lastLaunchCount = launchCount;
  }
}

class FakePremiumPurchaseGateway implements PremiumPurchaseGateway {
  FakePremiumPurchaseGateway({
    this.currentOffering,
    this.shouldThrowOnPurchase,
    this.shouldThrowOnRestore,
  });

  final Offering? currentOffering;
  final bool? shouldThrowOnPurchase;
  final bool? shouldThrowOnRestore;
  int getCurrentOfferingCalls = 0;
  int getOfferingCalls = 0;
  int purchasePackageCalls = 0;
  int restorePurchasesCalls = 0;
  Package? lastPurchasedPackage;

  @override
  Future<Offering?> getOffering(String offeringId) async {
    getOfferingCalls += 1;
    return currentOffering ??
        Offering(offeringId, offeringId, {}, [
          Package(
            '${offeringId}_monthly',
            PackageType.monthly,
            StoreProduct(
              '${offeringId}_sku',
              offeringId,
              offeringId,
              9.99,
              '\$9.99',
              'USD',
            ),
            PresentedOfferingContext(offeringId, null, null),
          ),
        ]);
  }

  @override
  Future<Offering?> getCurrentOffering() async {
    getCurrentOfferingCalls += 1;
    return currentOffering;
  }

  @override
  Future<void> purchasePackage(Package package) async {
    purchasePackageCalls += 1;
    lastPurchasedPackage = package;
    if (shouldThrowOnPurchase == true) {
      throw Exception('Purchase failed');
    }
  }

  @override
  Future<void> restorePurchases() async {
    restorePurchasesCalls += 1;
    if (shouldThrowOnRestore == true) {
      throw Exception('Restore failed');
    }
  }
}
