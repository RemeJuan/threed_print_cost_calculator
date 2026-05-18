import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/shared/utils/debounce_constants.dart';
import 'package:threed_print_cost_calculator/database/repositories/calculator_preferences_repository.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/pricing_calculator.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_history_loader.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_materials_service.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_settings_sync.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/services/settings_service.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';
import 'package:threed_print_cost_calculator/shared/services/app_usage_service.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

final calculatorProvider =
    NotifierProvider<CalculatorProvider, CalculatorState>(
      CalculatorProvider.new,
    );

class CalculatorProvider extends Notifier<CalculatorState> {
  Timer? _submitDebounce;
  StreamSubscription<GeneralSettingsModel>? _settingsSubscription;

  AppLogger get _logger => ref.read(appLoggerProvider);

  @override
  CalculatorState build() {
    // Register a disposal callback so any pending submit timer is cancelled
    // when the notifier is disposed. This prevents timers firing after the
    // provider is torn down and avoids memory/resource leaks.
    ref.onDispose(() {
      _submitDebounce?.cancel();
      _submitDebounce = null;
      _settingsSubscription?.cancel();
      _settingsSubscription = null;
    });

    _settingsSubscription ??= ref
        .read(settingsRepositoryProvider)
        .watchSettings()
        .listen(_syncMarkupFromSettings);

    return CalculatorState();
  }

  void _syncMarkupFromSettings(GeneralSettingsModel settings) {
    if (!state.hasHydratedDefaults) return;

    final settingsMarkupPercent = tryParseLocalizedNum(
      settings.pricingMarkupPercent,
    );
    final settingsSetupFee = tryParseLocalizedNum(settings.pricingSetupFee);
    final settingsRoundingMode = pricingRoundingModeFromStorage(
      settings.pricingRoundingMode,
    );
    var nextState = state;
    var shouldSubmit = false;

    if (state.baselineMarkupPercent != settingsMarkupPercent) {
      nextState = nextState.copyWith(
        baselineMarkupPercent: settingsMarkupPercent,
      );
    }
    if (!state.markupPercentOverridden &&
        state.markupPercent.value != settingsMarkupPercent) {
      nextState = nextState.copyWith(
        markupPercent: NumberInput.dirty(value: settingsMarkupPercent),
      );
      shouldSubmit = true;
    }

    if (!state.markupPercentOverridden) {
      if (state.baselineSetupFee != settingsSetupFee) {
        nextState = nextState.copyWith(baselineSetupFee: settingsSetupFee);
      }
      final setupFeeOverridden =
          state.setupFee.value != state.baselineSetupFee;
      if (!setupFeeOverridden && state.setupFee.value != settingsSetupFee) {
        nextState = nextState.copyWith(
          setupFee: NumberInput.dirty(value: settingsSetupFee),
        );
        shouldSubmit = true;
      }

      if (state.baselineRoundingMode != settingsRoundingMode) {
        nextState = nextState.copyWith(
          baselineRoundingMode: settingsRoundingMode,
        );
      }
      final roundingModeOverridden =
          state.roundingMode != state.baselineRoundingMode;
      if (!roundingModeOverridden &&
          state.roundingMode != settingsRoundingMode) {
        nextState = nextState.copyWith(roundingMode: settingsRoundingMode);
        shouldSubmit = true;
      }
    }

    if (identical(nextState, state)) return;
    state = nextState;
    if (shouldSubmit) submit();
  }

  Future<void> init() async {
    if (state.hasHydratedDefaults) return;

    final settings = await ref.read(settingsServiceProvider).get();
    state = await ref
        .read(calculatorSettingsSyncProvider)
        .load(settings, seedInitialMaterialUsage: true);
  }

  Future<void> resetToDefaults() async {
    _submitDebounce?.cancel();

    final settings = await ref.read(settingsServiceProvider).get();
    state = await ref
        .read(calculatorSettingsSyncProvider)
        .load(settings, seedInitialMaterialUsage: false);
    submit();
  }

  Future<bool> loadFromHistory(HistoryEntry entry) async {
    _submitDebounce?.cancel();

    if (entry.model.materialUsages.isEmpty) {
      _logger.warn(
        AppLogCategory.provider,
        'Skipping empty history entry load',
        context: {'historyKey': entry.key},
      );
      return false;
    }

    final settingsService = ref.read(settingsServiceProvider);

    try {
      final settings = await settingsService.get();
      final result = await ref
          .read(calculatorHistoryLoaderProvider)
          .load(entry: entry, currentState: state, settings: settings);
      if (result == null) {
        _logger.warn(
          AppLogCategory.provider,
          'Skipping corrupted history entry load',
          context: {
            'historyKey': entry.key,
            'timeHours': entry.model.timeHours,
          },
        );
        return false;
      }

      await settingsService.update(
        (current) => current.copyWith(
          activePrinter: result.activePrinterId,
          selectedMaterial: result.selectedMaterialId ?? '',
        ),
      );

      state = result.state;
      return true;
    } catch (error, stackTrace) {
      _logger.warn(
        AppLogCategory.provider,
        'Failed to load history entry into calculator',
        context: {'historyKey': entry.key},
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void dismissHistoryLoadReplacementWarning() {
    if (!state.showHistoryLoadReplacementWarning) return;
    state = state.copyWith(showHistoryLoadReplacementWarning: false);
  }

  void updateWatt(String value) {
    state = state.copyWith(
      watt: NumberInput.dirty(value: parseLocalizedNum(value)),
    );
  }

  Future<void> selectPrinter(String printerId) async {
    await ref
        .read(settingsServiceProvider)
        .update((settings) => settings.copyWith(activePrinter: printerId));

    final printer = await ref
        .read(printersRepositoryProvider)
        .getPrinterById(printerId);

    state = state.copyWith(
      activePrinterId: printerId,
      watt: NumberInput.dirty(
        value: tryParseLocalizedNum(printer?.wattage) ?? state.watt.value,
      ),
    );
    submit();
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
    final usages = ref
        .read(calculatorMaterialsServiceProvider)
        .addUsage(state.materialUsages, usage);
    state = state.copyWith(
      materialUsages: usages,
      selectedMaterialId: _selectedMaterialIdFor(usages),
    );
  }

  void removeMaterialUsageAt(int index) {
    final result = ref
        .read(calculatorMaterialsServiceProvider)
        .removeUsageAt(state.materialUsages, index);

    state = state.copyWith(
      materialUsages: result.usages,
      printWeight: NumberInput.dirty(value: result.totalWeight),
      selectedMaterialId: _selectedMaterialIdFor(result.usages),
    );
  }

  void updateMaterialUsageWeight(int index, int grams) {
    final result = ref
        .read(calculatorMaterialsServiceProvider)
        .updateUsageWeight(state.materialUsages, index, grams);

    state = state.copyWith(
      materialUsages: result.usages,
      printWeight: NumberInput.dirty(value: result.totalWeight),
      selectedMaterialId: _selectedMaterialIdFor(result.usages),
    );
  }

  void updateMaterialUsage(int index, MaterialUsageInput usage) {
    final result = ref
        .read(calculatorMaterialsServiceProvider)
        .updateUsage(state.materialUsages, index, usage);

    state = state.copyWith(
      materialUsages: result.usages,
      printWeight: NumberInput.dirty(value: result.totalWeight),
      selectedMaterialId: _selectedMaterialIdFor(result.usages),
    );
  }

  void applySingleTotalWeightToFirstRow() {
    if (state.materialUsages.isEmpty) return;

    final total = (state.printWeight.value ?? 0).toInt();
    final normalizedUsages = ref
        .read(calculatorMaterialsServiceProvider)
        .normalizedMaterialUsagesForSingleTotalWeight(
          state.materialUsages,
          total,
        );

    state = state.copyWith(
      materialUsages: normalizedUsages,
      printWeight: NumberInput.dirty(value: total),
      selectedMaterialId: _selectedMaterialIdFor(normalizedUsages),
    );
  }

  void updateHours(num value) {
    state = state.copyWith(hours: NumberInput.dirty(value: value));
  }

  void updateMinutes(num value) {
    state = state.copyWith(minutes: NumberInput.dirty(value: value));
  }

  void applyImportedValues({
    Duration? estimatedDuration,
    double? filamentWeightGrams,
  }) {
    var nextState = state;

    if (estimatedDuration != null) {
      final roundedMinutes = (estimatedDuration.inSeconds / 60).round();
      nextState = nextState.copyWith(
        hours: NumberInput.dirty(value: roundedMinutes ~/ 60),
        minutes: NumberInput.dirty(value: roundedMinutes % 60),
      );
    }

    if (filamentWeightGrams != null) {
      final totalWeight = filamentWeightGrams < 0
          ? 0
          : filamentWeightGrams.round();
      final normalizedUsages = ref
          .read(calculatorMaterialsServiceProvider)
          .normalizedMaterialUsagesForSingleTotalWeight(
            nextState.materialUsages,
            totalWeight,
          );

      nextState = nextState.copyWith(
        printWeight: NumberInput.dirty(value: totalWeight),
        materialUsages: normalizedUsages,
        selectedMaterialId: _selectedMaterialIdFor(normalizedUsages),
      );
    }

    state = nextState.copyWith(importedFromGcode: true);
    unawaited(ref.read(appUsageServiceProvider).markGcodeImportUsed());
    submit();
  }

  void updateSpoolWeight(num value) {
    ref
        .read(calculatorPreferencesRepositoryProvider)
        .saveStringValue('spoolWeight', value.toString());
    state = state.copyWith(
      spoolWeight: NumberInput.dirty(value: value),
      materialUsages: ref
          .read(calculatorMaterialsServiceProvider)
          .syncedSingleMaterialUsage(state: state, spoolWeight: value),
    );
  }

  void updateSpoolCost(String value) {
    final parsedCost = parseLocalizedNumOrFallback(value);
    ref
        .read(calculatorPreferencesRepositoryProvider)
        .saveStringValue('spoolCost', value);
    final syncedUsages = ref
        .read(calculatorMaterialsServiceProvider)
        .syncedSingleMaterialUsage(state: state, spoolCost: parsedCost);

    state = state.copyWith(
      spoolCost: NumberInput.dirty(value: parsedCost),
      spoolCostText: value,
      materialUsages: syncedUsages,
      selectedMaterialId: _selectedMaterialIdFor(syncedUsages),
    );
  }

  Future<void> selectMaterial(MaterialModel material) async {
    final spoolWeight = parseLocalizedNumOrFallback(material.weight);
    final spoolCost = parseLocalizedNumOrFallback(material.cost);

    await ref
        .read(settingsServiceProvider)
        .update((settings) => settings.copyWith(selectedMaterial: material.id));
    AppAnalytics.safeLog(
      () => AppAnalytics.materialSelectedInCalculator(
        hasTracking: material.autoDeductEnabled,
        materialType: material.materialType,
        brand: material.brand,
      ),
    );

    ref
        .read(calculatorPreferencesRepositoryProvider)
        .saveStringValue('spoolWeight', material.weight);
    ref
        .read(calculatorPreferencesRepositoryProvider)
        .saveStringValue('spoolCost', material.cost);

    final syncedUsages = ref
        .read(calculatorMaterialsServiceProvider)
        .syncedSingleMaterialUsage(
          state: state,
          materialId: material.id,
          materialName: material.name,
          spoolWeight: spoolWeight,
          spoolCost: spoolCost,
        );

    state = state.copyWith(
      selectedMaterialId: material.id,
      spoolWeight: NumberInput.dirty(value: spoolWeight),
      spoolCost: NumberInput.dirty(value: spoolCost),
      spoolCostText: material.cost,
      materialUsages: syncedUsages,
    );

    submit();
  }

  Future<void> updateWearAndTear(num value) async {
    try {
      await ref
          .read(settingsServiceProvider)
          .update(
            (settings) => settings.copyWith(wearAndTear: value.toString()),
          );
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
    try {
      await ref
          .read(settingsServiceProvider)
          .update(
            (settings) =>
                settings.copyWith(failureRisk: value.toStringAsFixed(2)),
          );
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
    try {
      await ref
          .read(settingsServiceProvider)
          .update(
            (settings) => settings.copyWith(labourRate: value.toString()),
          );
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

  void setAdditionalCostAmount(num value) {
    state = state.copyWith(
      additionalCostAmount: NumberInput.dirty(value: value),
    );
  }

  void setAdditionalCostNote(String? value) {
    final normalized = value?.trim();
    state = state.copyWith(
      additionalCostNote: normalized == null || normalized.isEmpty
          ? null
          : normalized,
    );
  }

  void setMarkupPercent(num value) {
    state = state.copyWith(
      markupPercent: NumberInput.dirty(value: value),
      markupPercentOverridden: true,
    );
  }

  void setSetupFee(num value) {
    state = state.copyWith(setupFee: NumberInput.dirty(value: value));
  }

  void setRoundingMode(PricingRoundingMode value) {
    state = state.copyWith(roundingMode: value);
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

  void updatePricing(PricingResult pricing) {
    state = state.copyWith(pricing: pricing);
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
    final markupPercent = _effectiveMarkupPercent();
    final setupFee = state.setupFee.value ?? 0;
    final additionalCost = state.additionalCostAmount.value ?? 0;

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

    final basePrintCost = electricityCost + filamentCost + labourCost;
    final frCost = basePrintCost * fr / 100;
    final totalCost = basePrintCost + frCost + wt + additionalCost;

    final results = CalculationResult(
      electricity: electricityCost,
      filament: filamentCost,
      risk: num.parse(frCost.toStringAsFixed(2)),
      labour: labourCost,
      total: num.parse(totalCost.toStringAsFixed(2)),
    );

    final pricing = PricingCalculator.calculate(
      baseCost: results.total,
      markupPercent: markupPercent,
      setupFee: setupFee,
      roundingMode: state.roundingMode,
    );

    updateResults(results);
    unawaited(ref.read(appUsageServiceProvider).recordCalculation());
    updatePricing(pricing);

    AppAnalytics.safeLog(
      () => AppAnalytics.calculationCreated(
        materialCount: state.materialUsages.length,
        hasFailureRisk: fr > 0,
        hasLabour: labourCost > 0,
        hasPricing: pricing.isEnabled,
      ),
    );

    if (pricing.roundingMode != PricingRoundingMode.none) {
      AppAnalytics.safeLog(
        () => AppAnalytics.pricingRoundingUsed(
          roundingMode: pricing.roundingMode.storageValue,
        ),
      );
    }

    if (state.materialUsages.length > 1) {
      AppAnalytics.safeLog(
        () => AppAnalytics.multiMaterialUsed(state.materialUsages.length),
      );
    }
  }

  /// Remove deleted material usages and clear stale selected-material defaults.
  Future<void> clearUsagesForDeletedMaterial(String materialId) async {
    _submitDebounce?.cancel();
    _submitDebounce = null;
    final usages = state.materialUsages;
    final filtered = usages.where((u) => u.materialId != materialId).toList();
    final removedUsage = filtered.length != usages.length;
    final settingsService = ref.read(settingsServiceProvider);
    final settings = await settingsService.get();
    final deletedWasSelected = settings.selectedMaterial == materialId;
    if (!removedUsage && !deletedWasSelected) return;

    final totalWeight = filtered.fold<int>(
      0,
      (sum, usage) => sum + usage.weightGrams,
    );

    var nextState = state;

    if (removedUsage) {
      nextState = nextState.copyWith(
        materialUsages: filtered,
        printWeight: NumberInput.dirty(value: totalWeight),
      );
    }

    if (deletedWasSelected) {
      await settingsService.update(
        (current) => current.selectedMaterial == materialId
            ? current.copyWith(selectedMaterial: '')
            : current,
      );

      final preferencesRepository = ref.read(
        calculatorPreferencesRepositoryProvider,
      );
      await preferencesRepository.saveStringValue('spoolWeight', '');
      await preferencesRepository.saveStringValue('spoolCost', '');

      nextState = nextState.copyWith(
        spoolWeight: const NumberInput.pure(),
        spoolCost: const NumberInput.pure(),
        spoolCostText: '',
      );
    }

    state = nextState;
    submit();
  }

  /// Schedule a debounced submit to avoid running heavy calculations on every keystroke.
  ///
  /// Cancels any previously scheduled submit and schedules a new one after [delay].
  void submitDebounced({Duration delay = debounce250ms}) {
    _submitDebounce?.cancel();
    _submitDebounce = Timer(delay, submit);
  }

  String _selectedMaterialIdFor(List<MaterialUsageInput> usages) {
    for (final usage in usages) {
      final materialId = usage.materialId.trim();
      if (materialId.isNotEmpty) return materialId;
    }
    return '';
  }

  num _effectiveMarkupPercent() {
    if (state.markupPercentOverridden) {
      return state.markupPercent.value ?? 0;
    }

    return state.baselineMarkupPercent ?? state.markupPercent.value ?? 0;
  }
}
