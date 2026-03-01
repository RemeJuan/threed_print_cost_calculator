import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';

final calculatorProvider =
    NotifierProvider<CalculatorProvider, CalculatorState>(
      CalculatorProvider.new,
    );

class CalculatorProvider extends Notifier<CalculatorState> {
  Timer? _submitDebounce;

  // Avoid storing late/nullable fields that may not be initialized when tests
  // override the provider. Use on-demand getters that read the required
  // resources from `ref` so they are always available.
  Database get _database => ref.read(databaseProvider);

  StoreRef get _store => stringMapStoreFactory.store();

  @override
  CalculatorState build() {
    // Register a disposal callback so any pending submit timer is cancelled
    // when the notifier is disposed. This prevents timers firing after the
    // provider is torn down and avoids memory/resource leaks.
    ref.onDispose(() {
      _submitDebounce?.cancel();
      _submitDebounce = null;
    });

    return CalculatorState();
  }

  void init() async {
    // Nothing to initialize here; _database and _store are getters that read
    // from ref on demand.
    final dbHelpers = ref.read(dbHelpersProvider(DBName.settings));
    final settings = await dbHelpers.getSettings();
    final printerKey = settings.activePrinter;

    final spoolWeightVal = await _getValue('spoolWeight');
    final spoolCostVal = await _getValue('spoolCost');

    if (printerKey.isNotEmpty) {
      final printersStore = stringMapStoreFactory.store(DBName.printers.name);

      final data = await printersStore
          .query(finder: Finder(filter: Filter.byKey(printerKey)))
          .getSnapshot(_database);

      if (data != null) {
        final printer = PrinterModel.fromMap(data.value, printerKey);

        updateWatt(printer.wattage.toString());
      } else {
        updateWatt(settings.wattage.toString());
      }
    } else {
      updateWatt(settings.wattage.toString());
    }

    // Load the selected material into the initial materialUsages list.
    final initialUsages = await _loadInitialMaterialUsages(
      settings.selectedMaterial,
    );

    state = CalculatorState(
      watt: NumberInput.dirty(value: state.watt.value),
      kwCost: NumberInput.dirty(
        value: num.tryParse(settings.electricityCost.replaceAll(',', '.')),
      ),
      printWeight: NumberInput.dirty(value: state.printWeight.value),
      hours: NumberInput.dirty(value: state.hours.value),
      minutes: NumberInput.dirty(value: state.minutes.value),
      spoolWeight: NumberInput.dirty(
        value: num.tryParse(spoolWeightVal['value'] as String),
      ),
      spoolCost: NumberInput.dirty(
        value: num.tryParse(spoolCostVal['value'] as String),
      ),
      spoolCostText: spoolCostVal['value'] as String,
      wearAndTear: NumberInput.dirty(
        value: num.tryParse(settings.wearAndTear.replaceAll(',', '.')),
      ),
      failureRisk: NumberInput.dirty(
        value: num.tryParse(settings.failureRisk.replaceAll(',', '.')),
      ),
      labourRate: NumberInput.dirty(
        value: num.tryParse(settings.labourRate.replaceAll(',', '.')),
      ),
      labourTime: NumberInput.dirty(value: state.labourTime.value),
      results: state.results,
      materialUsages: initialUsages,
    );
  }

  /// Loads the initial [MaterialUsage] list from the persisted selected material.
  Future<List<MaterialUsage>> _loadInitialMaterialUsages(
    String selectedMaterialId,
  ) async {
    if (selectedMaterialId.isEmpty) return [];
    final materialsStore = stringMapStoreFactory.store(DBName.materials.name);
    final snapshot = await materialsStore
        .query(finder: Finder(filter: Filter.byKey(selectedMaterialId)))
        .getSnapshot(_database);
    if (snapshot == null) return [];
    final material = MaterialModel.fromMap(snapshot.value, selectedMaterialId);
    return [
      MaterialUsage(
        materialId: material.id,
        materialName: material.name,
        weightGrams: 0,
        spoolWeight: num.tryParse(material.weight) ?? 0,
        spoolCost: num.tryParse(material.cost) ?? 0,
      ),
    ];
  }

  void updateWatt(String value) {
    state = state.copyWith(
      watt: NumberInput.dirty(
        value: num.tryParse(value.replaceAll(',', '.')) ?? 0,
      ),
    );
  }

  void updateKwCost(String value) {
    state = state.copyWith(
      kwCost: NumberInput.dirty(
        value: num.tryParse(value.replaceAll(',', '.')) ?? 0,
      ),
    );
  }

  void updatePrintWeight(String value) {
    state = state.copyWith(
      printWeight: NumberInput.dirty(value: num.tryParse(value) ?? 0),
    );
  }

  void updateHours(num value) {
    state = state.copyWith(hours: NumberInput.dirty(value: value));
  }

  void updateMinutes(num value) {
    state = state.copyWith(minutes: NumberInput.dirty(value: value));
  }

  void updateSpoolWeight(num value) {
    ref
        .read(calculatorHelpersProvider)
        .addOrUpdateRecord('spoolWeight', value.toString());
    state = state.copyWith(spoolWeight: NumberInput.dirty(value: value));
  }

  void updateSpoolCost(String value) {
    ref
        .read(calculatorHelpersProvider)
        .addOrUpdateRecord('spoolCost', value.toString());
    state = state.copyWith(
      spoolCost: NumberInput.dirty(value: num.tryParse(value) ?? 0),
      spoolCostText: value,
    );
  }

  Future<void> updateWearAndTear(num value) async {
    final dbHelpers = ref.read(dbHelpersProvider(DBName.settings));

    try {
      final settings = await dbHelpers.getSettings();
      final updated = settings.copyWith(wearAndTear: value.toString());
      await dbHelpers.putRecord(updated.toMap());

      // Only update local state after successful DB write
      state = state.copyWith(wearAndTear: NumberInput.dirty(value: value));
    } catch (e, st) {
      // Log and rethrow so callers can handle or await the failure
      // Using print for logging to avoid adding new logging dependencies
      if (kDebugMode) print('Error updating wearAndTear: $e\n$st');
      rethrow;
    }
  }

  Future<void> updateFailureRisk(num value) async {
    final dbHelpers = ref.read(dbHelpersProvider(DBName.settings));

    try {
      final settings = await dbHelpers.getSettings();
      final updated = settings.copyWith(failureRisk: value.toStringAsFixed(2));
      await dbHelpers.putRecord(updated.toMap());

      // Only update local state after successful DB write
      state = state.copyWith(failureRisk: NumberInput.dirty(value: value));
    } catch (e, st) {
      if (kDebugMode) print('Error updating failureRisk: $e\n$st');
      rethrow;
    }
  }

  Future<void> updateLabourRate(num value) async {
    final dbHelpers = ref.read(dbHelpersProvider(DBName.settings));

    try {
      final settings = await dbHelpers.getSettings();
      final updated = settings.copyWith(labourRate: value.toString());
      await dbHelpers.putRecord(updated.toMap());

      // Only update local state after successful DB write
      state = state.copyWith(labourRate: NumberInput.dirty(value: value));
    } catch (e, st) {
      if (kDebugMode) print('Error updating labourRate: $e\n$st');
      rethrow;
    }
  }

  // Local-only setters for calculator UI (do not persist to DB)
  void setWearAndTear(num value) {
    state = state.copyWith(wearAndTear: NumberInput.dirty(value: value));
  }

  void setFailureRisk(num value) {
    state = state.copyWith(failureRisk: NumberInput.dirty(value: value));
  }

  void setLabourRate(num value) {
    state = state.copyWith(labourRate: NumberInput.dirty(value: value));
  }

  void updateLabourTime(num value) {
    ref
        .read(calculatorHelpersProvider)
        .addOrUpdateRecord('labourTime', value.toString());
    state = state.copyWith(labourTime: NumberInput.dirty(value: value));
  }

  void updateResults(CalculationResult results) {
    state = state.copyWith(results: results);
  }

  // ── Multi-material methods ───────────────────────────────────────────────

  /// Adds a new [MaterialUsage] entry from a [MaterialModel].
  /// Weight defaults to 0 so the user can set it explicitly.
  void addMaterial(MaterialModel material) {
    final usage = MaterialUsage(
      materialId: material.id,
      materialName: material.name,
      weightGrams: 0,
      spoolWeight: num.tryParse(material.weight) ?? 0,
      spoolCost: num.tryParse(material.cost) ?? 0,
    );
    state = state.copyWith(
      materialUsages: [...state.materialUsages, usage],
    );
    submitDebounced();
  }

  /// Updates the [weightGrams] of the material usage at [index].
  void updateMaterialWeight(int index, int grams) {
    final updated = List<MaterialUsage>.from(state.materialUsages);
    if (index < 0 || index >= updated.length) return;
    updated[index] = updated[index].copyWith(weightGrams: grams);
    state = state.copyWith(materialUsages: updated);
  }

  /// Removes the material usage at [index].
  /// No-op if there is only one material (must have at least one).
  void removeMaterial(int index) {
    if (state.materialUsages.length <= 1) return;
    final updated = List<MaterialUsage>.from(state.materialUsages)
      ..removeAt(index);
    state = state.copyWith(materialUsages: updated);
    submitDebounced();
  }

  /// Replaces the entire material usages list (used for picker-based replacement).
  void setMaterialUsages(List<MaterialUsage> usages) {
    state = state.copyWith(materialUsages: usages);
    submitDebounced();
  }

  void submit() {
    num electricityCost = 0;
    num filamentCost = 0;
    num labourCost = 0;

    final w = state.watt.value ?? 0;

    final kw = state.kwCost.value ?? 0;
    final pw = state.printWeight.value ?? 0;
    final sw = state.spoolWeight.value ?? 0;
    final sc = state.spoolCost.value ?? 0;
    final h = state.hours.value ?? 0;
    final m = state.minutes.value ?? 0;

    final wt = state.wearAndTear.value ?? 0;
    final lr = state.labourRate.value ?? 0;
    final lt = state.labourTime.value ?? 0;
    final fr = state.failureRisk.value ?? 0;

    if (w > -1 && (h > -1 || m > -1) && kw > -1) {
      electricityCost = ref
          .read(calculatorHelpersProvider)
          .electricityCost(w, h, m, kw);
    }

    final helpers = ref.read(calculatorHelpersProvider);

    if (state.materialUsages.isNotEmpty) {
      // Multi-material path: compute costs per usage, store back into state.
      final costed = helpers.computeUsageCosts(state.materialUsages);
      filamentCost = costed.fold<num>(0, (sum, u) => sum + u.filamentCost);
      // Store computed costs back so history/save can access them.
      state = state.copyWith(materialUsages: costed);
    } else if (pw > -1 && sw > -1 && sc > -1) {
      // Legacy single-material fallback.
      filamentCost = helpers.filamentCost(pw, sw, sc);
    }

    if (lt > -1 && lr > -1) {
      labourCost = CalculatorHelpers.labourCost(lr, lt);
    }

    final totalCost = electricityCost + filamentCost + wt + labourCost;
    final frCost = fr / 100 * totalCost;

    final results = CalculationResult(
      electricity: electricityCost,
      filament: filamentCost,
      risk: num.parse(frCost.toStringAsFixed(2)),
      labour: labourCost,
      total: num.parse(totalCost.toStringAsFixed(2)),
    );

    updateResults(results);
  }

  /// Schedule a debounced submit to avoid running heavy calculations on every keystroke.
  ///
  /// Cancels any previously scheduled submit and schedules a new one after [delay].
  void submitDebounced({Duration delay = const Duration(milliseconds: 250)}) {
    _submitDebounce?.cancel();
    _submitDebounce = Timer(delay, submit);
  }

  Future<Map<String, Object?>> _getValue(String key) async {
    if (await _store.record(key).exists(_database)) {
      return await _store.record(key).get(_database) as Map<String, Object?>;
    }

    return {'value': ''};
  }
}
