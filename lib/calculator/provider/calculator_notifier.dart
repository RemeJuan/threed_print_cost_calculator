import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/calculator_preferences_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

final calculatorProvider =
    NotifierProvider<CalculatorProvider, CalculatorState>(
      CalculatorProvider.new,
    );

class CalculatorProvider extends Notifier<CalculatorState> {
  Timer? _submitDebounce;

  AppLogger get _logger => ref.read(appLoggerProvider);

  num _costPerKgFromSpool({required num spoolWeight, required num spoolCost}) {
    return spoolWeight <= 0 ? 0 : (spoolCost / spoolWeight) * 1000;
  }

  List<MaterialUsageInput> _syncedSingleMaterialUsage({
    String? materialId,
    String? materialName,
    num? spoolWeight,
    num? spoolCost,
  }) {
    if (state.materialUsages.length != 1) return state.materialUsages;

    final usage = state.materialUsages.first;
    final nextSpoolWeight = spoolWeight ?? (state.spoolWeight.value ?? 0);
    final nextSpoolCost = spoolCost ?? (state.spoolCost.value ?? 0);

    return [
      usage.copyWith(
        materialId: materialId ?? usage.materialId,
        materialName: materialName ?? usage.materialName,
        costPerKg: _costPerKgFromSpool(
          spoolWeight: nextSpoolWeight,
          spoolCost: nextSpoolCost,
        ),
      ),
    ];
  }

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

  Future<void> init() async {
    final settingsRepository = ref.read(settingsRepositoryProvider);
    final preferencesRepository = ref.read(
      calculatorPreferencesRepositoryProvider,
    );
    final settings = await settingsRepository.getSettings();
    final printerKey = settings.activePrinter;

    final spoolWeightVal = await preferencesRepository.getStringValue(
      'spoolWeight',
    );
    final spoolCostVal = await preferencesRepository.getStringValue(
      'spoolCost',
    );

    if (printerKey.isNotEmpty) {
      final printer = await ref
          .read(printersRepositoryProvider)
          .getPrinterById(printerKey);

      if (printer != null) {
        updateWatt(printer.wattage.toString());
      } else {
        updateWatt(settings.wattage.toString());
      }
    } else {
      updateWatt(settings.wattage.toString());
    }

    state = CalculatorState(
      watt: NumberInput.dirty(value: state.watt.value),
      kwCost: NumberInput.dirty(
        value: tryParseLocalizedNum(settings.electricityCost),
      ),
      printWeight: NumberInput.dirty(value: state.printWeight.value),
      hours: NumberInput.dirty(value: state.hours.value),
      minutes: NumberInput.dirty(value: state.minutes.value),
      spoolWeight: NumberInput.dirty(
        value: tryParseLocalizedNum(spoolWeightVal),
      ),
      spoolCost: NumberInput.dirty(value: tryParseLocalizedNum(spoolCostVal)),
      spoolCostText: spoolCostVal,
      wearAndTear: NumberInput.dirty(
        value: tryParseLocalizedNum(settings.wearAndTear),
      ),
      failureRisk: NumberInput.dirty(
        value: tryParseLocalizedNum(settings.failureRisk),
      ),
      labourRate: NumberInput.dirty(
        value: tryParseLocalizedNum(settings.labourRate),
      ),
      labourTime: NumberInput.dirty(value: state.labourTime.value),
      materialUsages: state.materialUsages,
      results: state.results,
    );

    await _ensureInitialMaterialUsage(settings.selectedMaterial);
  }

  Future<void> _ensureInitialMaterialUsage(String selectedMaterialId) async {
    // Previously this forced a placeholder 'none' material when the list was
    // empty. Change: allow an empty materialUsages list so users can add
    // materials only when needed and are required to provide cost for any
    // material rows they add.
    if (state.materialUsages.isNotEmpty) return;

    if (selectedMaterialId.isEmpty) {
      // Leave materialUsages empty instead of adding a placeholder.
      state = state.copyWith(materialUsages: []);
      return;
    }

    final material = await ref
        .read(materialsRepositoryProvider)
        .getMaterialById(selectedMaterialId);

    if (material == null) {
      // Leave empty if selected material not found
      state = state.copyWith(materialUsages: []);
      return;
    }

    final weight = parseLocalizedNum(material.weight);
    final cost = parseLocalizedNum(material.cost);
    final costPerKg = _costPerKgFromSpool(spoolWeight: weight, spoolCost: cost);

    state = state.copyWith(
      materialUsages: [
        MaterialUsageInput(
          materialId: material.id,
          materialName: material.name,
          costPerKg: costPerKg,
          weightGrams: (state.printWeight.value ?? 0).toInt(),
        ),
      ],
    );
  }

  void updateWatt(String value) {
    state = state.copyWith(
      watt: NumberInput.dirty(value: parseLocalizedNum(value)),
    );
  }

  void updateKwCost(String value) {
    state = state.copyWith(
      kwCost: NumberInput.dirty(value: parseLocalizedNum(value)),
    );
  }

  void updatePrintWeight(String value) {
    final parsed = parseLocalizedInt(value);
    final usages = [...state.materialUsages];
    if (usages.length == 1) {
      usages[0] = usages[0].copyWith(weightGrams: parsed);
    }

    state = state.copyWith(
      printWeight: NumberInput.dirty(value: parsed),
      materialUsages: usages,
    );
  }

  void addMaterialUsage(MaterialUsageInput usage) {
    // Allow adding any usage; prevent exact duplicate material IDs.
    final id = usage.materialId.trim();
    if (id.isNotEmpty) {
      final exists = state.materialUsages.any(
        (u) => u.materialId.trim().isNotEmpty && u.materialId.trim() == id,
      );
      if (exists) return; // ignore duplicate add
    }

    state = state.copyWith(materialUsages: [...state.materialUsages, usage]);
  }

  void removeMaterialUsageAt(int index) {
    // Defensive: ensure index is valid
    if (index < 0 || index >= state.materialUsages.length) return;

    final usages = [...state.materialUsages]..removeAt(index);

    // Do not re-add placeholders; allow the list to be empty.

    // Always update state: update materialUsages and printWeight (sum of weights or 0)
    final totalWeight = usages.fold<int>(
      0,
      (sum, item) => sum + item.weightGrams,
    );

    state = state.copyWith(
      materialUsages: usages,
      printWeight: NumberInput.dirty(value: totalWeight),
    );
  }

  void updateMaterialUsageWeight(int index, int grams) {
    // Validate index
    if (index < 0 || index >= state.materialUsages.length) return;

    // Ensure non-negative grams
    final safeGrams = grams < 0 ? 0 : grams;

    final usages = [...state.materialUsages];
    usages[index] = usages[index].copyWith(weightGrams: safeGrams);
    final totalWeight = usages.fold<int>(
      0,
      (sum, item) => sum + item.weightGrams,
    );

    state = state.copyWith(
      materialUsages: usages,
      printWeight: NumberInput.dirty(value: totalWeight),
    );
  }

  List<MaterialUsageInput> _normalizedMaterialUsagesForSingleTotalWeight(
    List<MaterialUsageInput> usages,
    int totalWeight,
  ) {
    if (usages.isEmpty) return usages;

    return List<MaterialUsageInput>.generate(usages.length, (index) {
      return usages[index].copyWith(weightGrams: index == 0 ? totalWeight : 0);
    });
  }

  // New helper: update an entire material usage at an index
  void updateMaterialUsage(int index, MaterialUsageInput usage) {
    if (index < 0 || index >= state.materialUsages.length) return;

    final usages = [...state.materialUsages];
    usages[index] = usage;

    final totalWeight = usages.fold<int>(
      0,
      (sum, item) => sum + item.weightGrams,
    );

    state = state.copyWith(
      materialUsages: usages,
      printWeight: NumberInput.dirty(value: totalWeight),
    );
  }

  void applySingleTotalWeightToFirstRow() {
    if (state.materialUsages.isEmpty) return;

    final total = (state.printWeight.value ?? 0).toInt();
    final normalizedUsages = _normalizedMaterialUsagesForSingleTotalWeight(
      state.materialUsages,
      total,
    );

    state = state.copyWith(
      materialUsages: normalizedUsages,
      printWeight: NumberInput.dirty(value: total),
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
        .read(calculatorPreferencesRepositoryProvider)
        .saveStringValue('spoolWeight', value.toString());
    state = state.copyWith(
      spoolWeight: NumberInput.dirty(value: value),
      materialUsages: _syncedSingleMaterialUsage(spoolWeight: value),
    );
  }

  void updateSpoolCost(String value) {
    final parsedCost = parseLocalizedNum(value);
    ref
        .read(calculatorPreferencesRepositoryProvider)
        .saveStringValue('spoolCost', value);
    state = state.copyWith(
      spoolCost: NumberInput.dirty(value: parsedCost),
      spoolCostText: value,
      materialUsages: _syncedSingleMaterialUsage(spoolCost: parsedCost),
    );
  }

  void selectMaterial(MaterialModel material) {
    final spoolWeight = parseLocalizedNum(material.weight);
    final spoolCost = parseLocalizedNum(material.cost);

    ref
        .read(calculatorPreferencesRepositoryProvider)
        .saveStringValue('spoolWeight', material.weight);
    ref
        .read(calculatorPreferencesRepositoryProvider)
        .saveStringValue('spoolCost', material.cost);

    state = state.copyWith(
      spoolWeight: NumberInput.dirty(value: spoolWeight),
      spoolCost: NumberInput.dirty(value: spoolCost),
      spoolCostText: material.cost,
      materialUsages: _syncedSingleMaterialUsage(
        materialId: material.id,
        materialName: material.name,
        spoolWeight: spoolWeight,
        spoolCost: spoolCost,
      ),
    );

    submit();
  }

  Future<void> updateWearAndTear(num value) async {
    final settingsRepository = ref.read(settingsRepositoryProvider);

    try {
      final settings = await settingsRepository.getSettings();
      final updated = settings.copyWith(wearAndTear: value.toString());
      await settingsRepository.saveSettings(updated);

      // Only update local state after successful DB write
      state = state.copyWith(wearAndTear: NumberInput.dirty(value: value));
    } catch (e, st) {
      _logger.error(
        AppLogCategory.provider,
        'Failed to persist wear and tear setting',
        context: {'setting': 'wearAndTear'},
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> updateFailureRisk(num value) async {
    final settingsRepository = ref.read(settingsRepositoryProvider);

    try {
      final settings = await settingsRepository.getSettings();
      final updated = settings.copyWith(failureRisk: value.toStringAsFixed(2));
      await settingsRepository.saveSettings(updated);

      // Only update local state after successful DB write
      state = state.copyWith(failureRisk: NumberInput.dirty(value: value));
    } catch (e, st) {
      _logger.error(
        AppLogCategory.provider,
        'Failed to persist failure risk setting',
        context: {'setting': 'failureRisk'},
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> updateLabourRate(num value) async {
    final settingsRepository = ref.read(settingsRepositoryProvider);

    try {
      final settings = await settingsRepository.getSettings();
      final updated = settings.copyWith(labourRate: value.toString());
      await settingsRepository.saveSettings(updated);

      // Only update local state after successful DB write
      state = state.copyWith(labourRate: NumberInput.dirty(value: value));
    } catch (e, st) {
      _logger.error(
        AppLogCategory.provider,
        'Failed to persist labour rate setting',
        context: {'setting': 'labourRate'},
        error: e,
        stackTrace: st,
      );
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
        .read(calculatorPreferencesRepositoryProvider)
        .saveStringValue('labourTime', value.toString());
    state = state.copyWith(labourTime: NumberInput.dirty(value: value));
  }

  void updateResults(CalculationResult results) {
    state = state.copyWith(results: results);
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

    if (state.materialUsages.isNotEmpty &&
        state.materialUsages.any(
          (u) => u.weightGrams > 0 && u.materialId.trim().isNotEmpty,
        )) {
      filamentCost = ref
          .read(calculatorHelpersProvider)
          .multiMaterialFilamentCost(state.materialUsages);
    } else if (pw > -1 && sw > -1 && sc > -1) {
      filamentCost = ref
          .read(calculatorHelpersProvider)
          .filamentCost(pw, sw, sc);
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

    AppAnalytics.safeLog(
      () => AppAnalytics.calculationCreated(
        materialCount: state.materialUsages.length,
        hasFailureRisk: fr > 0,
        hasLabour: labourCost > 0,
      ),
    );

    if (state.materialUsages.length > 1) {
      AppAnalytics.safeLog(
        () => AppAnalytics.multiMaterialUsed(state.materialUsages.length),
      );
    }
  }

  /// Schedule a debounced submit to avoid running heavy calculations on every keystroke.
  ///
  /// Cancels any previously scheduled submit and schedules a new one after [delay].
  void submitDebounced({Duration delay = const Duration(milliseconds: 250)}) {
    _submitDebounce?.cancel();
    _submitDebounce = Timer(delay, submit);
  }
}
