import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/services/settings_service.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';
import 'package:threed_print_cost_calculator/shared/utils/numeric_input_formatters.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

class WorkCostsSettings extends HookConsumerWidget {
  const WorkCostsSettings({super.key});

  @override
  Widget build(context, ref) {
    final l10n = AppLocalizations.of(context)!;

    // Controller for wearAndTear so the field reflects external updates
    final wearController = useTextEditingController();

    final settingsRepository = ref.read(settingsRepositoryProvider);
    final settingsService = ref.read(settingsServiceProvider);
    final logger = ref.read(appLoggerProvider);
    final currencyAsync = ref.watch(settingsStreamProvider);
    final currencySettings = currencyAsync is AsyncData<GeneralSettingsModel>
        ? currencyAsync.value
        : GeneralSettingsModel.initial();

    // Hooks for other fields/debounces: keep at top-level to preserve hook order
    final failureController = useTextEditingController();
    final failureFocus = useFocusNode();
    final labourController = useTextEditingController();
    final labourFocus = useFocusNode();
    final markupController = useTextEditingController();
    final markupFocus = useFocusNode();
    final setupFeeController = useTextEditingController();
    final setupFeeFocus = useFocusNode();
    final currencySymbolController = useTextEditingController();
    final currencySymbolFocus = useFocusNode();

    final failureDebounce = useRef<Timer?>(null);
    final labourDebounce = useRef<Timer?>(null);
    final wearDebounce = useRef<Timer?>(null);
    final markupDebounce = useRef<Timer?>(null);
    final setupFeeDebounce = useRef<Timer?>(null);
    final currencySymbolDebounce = useRef<Timer?>(null);

    // Cancel any pending timers when widget unmounts
    useEffect(() {
      return () {
        failureDebounce.value?.cancel();
        labourDebounce.value?.cancel();
        wearDebounce.value?.cancel();
        markupDebounce.value?.cancel();
        setupFeeDebounce.value?.cancel();
        currencySymbolDebounce.value?.cancel();
      };
    }, []);

    void logPricingSettingsChange({
      required num markupPercent,
      required num setupFee,
      required String roundingMode,
    }) {
      AppAnalytics.safeLog(
        () => AppAnalytics.pricingSettingsChanged(
          markupPercent: markupPercent,
          setupFee: setupFee,
          roundingMode: roundingMode,
        ),
      );
    }

    // persist functions: fire-and-forget debounced schedulers
    void persistFailure(String value) {
      failureDebounce.value?.cancel();
      failureDebounce.value = Timer(
        const Duration(milliseconds: 400),
        () async {
          final parsed = tryParseLocalizedNum(value);
          if (parsed == null) return;
          try {
            await settingsService.update(
              (settings) => settings.copyWith(failureRisk: parsed.toString()),
            );
          } catch (e, st) {
            logger.error(
              AppLogCategory.ui,
              'Failed to persist failure risk',
              context: {'setting': 'failureRisk'},
              error: e,
              stackTrace: st,
            );
          }
        },
      );
    }

    void persistLabour(String value) {
      labourDebounce.value?.cancel();
      labourDebounce.value = Timer(const Duration(milliseconds: 400), () async {
        final parsed = tryParseLocalizedNum(value);
        if (parsed == null) return;
        try {
          await settingsService.update(
            (settings) => settings.copyWith(labourRate: parsed.toString()),
          );
        } catch (e, st) {
          logger.error(
            AppLogCategory.ui,
            'Failed to persist labour rate',
            context: {'setting': 'labourRate'},
            error: e,
            stackTrace: st,
          );
        }
      });
    }

    void persistWear(String value) {
      wearDebounce.value?.cancel();
      wearDebounce.value = Timer(const Duration(milliseconds: 400), () async {
        final parsed = tryParseLocalizedNum(value);
        if (parsed == null) return;
        try {
          await settingsService.update(
            (settings) => settings.copyWith(wearAndTear: parsed.toString()),
          );
        } catch (e, st) {
          logger.error(
            AppLogCategory.ui,
            'Failed to persist wear and tear',
            context: {'setting': 'wearAndTear'},
            error: e,
            stackTrace: st,
          );
        }
      });
    }

    void persistMarkup(String value) {
      markupDebounce.value?.cancel();
      markupDebounce.value = Timer(const Duration(milliseconds: 400), () async {
        final parsed = tryParseLocalizedNum(value);
        if (parsed == null) return;
        try {
          await settingsService.update(
            (settings) =>
                settings.copyWith(pricingMarkupPercent: parsed.toString()),
          );
          logPricingSettingsChange(
            markupPercent: parsed,
            setupFee: tryParseLocalizedNum(setupFeeController.text) ?? 0,
            roundingMode: pricingRoundingModeFromStorage(
              (await settingsRepository.getSettings()).pricingRoundingMode,
            ).storageValue,
          );
        } catch (e, st) {
          logger.error(
            AppLogCategory.ui,
            'Failed to persist pricing markup percent',
            context: {'setting': 'pricingMarkupPercent'},
            error: e,
            stackTrace: st,
          );
        }
      });
    }

    void persistSetupFee(String value) {
      setupFeeDebounce.value?.cancel();
      setupFeeDebounce.value = Timer(
        const Duration(milliseconds: 400),
        () async {
          final parsed = tryParseLocalizedNum(value);
          if (parsed == null) return;
          try {
            await settingsService.update(
              (settings) =>
                  settings.copyWith(pricingSetupFee: parsed.toString()),
            );
            logPricingSettingsChange(
              markupPercent: tryParseLocalizedNum(markupController.text) ?? 0,
              setupFee: parsed,
              roundingMode: pricingRoundingModeFromStorage(
                (await settingsRepository.getSettings()).pricingRoundingMode,
              ).storageValue,
            );
          } catch (e, st) {
            logger.error(
              AppLogCategory.ui,
              'Failed to persist pricing setup fee',
              context: {'setting': 'pricingSetupFee'},
              error: e,
              stackTrace: st,
            );
          }
        },
      );
    }

    void persistCurrencySymbol(String value) {
      currencySymbolDebounce.value?.cancel();
      currencySymbolDebounce.value = Timer(
        const Duration(milliseconds: 400),
        () async {
          try {
            await settingsService.update(
              (settings) => settings.copyWith(currencySymbol: value),
            );
          } catch (e, st) {
            logger.error(
              AppLogCategory.ui,
              'Failed to persist currency symbol',
              context: {'setting': 'currencySymbol'},
              error: e,
              stackTrace: st,
            );
          }
        },
      );
    }

    return StreamBuilder(
      stream: settingsRepository.watchSettings(),
      builder: (context, snapshot) {
        late GeneralSettingsModel data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else {
          if (snapshot.hasData) {
            data = snapshot.data!;
          } else {
            data = GeneralSettingsModel.initial();
          }

          // Keep controller in sync with the latest data; avoid overwriting while typing
          final wearText = data.wearAndTear.toString();
          if (wearController.text != wearText) {
            wearController.text = wearText;
          }

          // Update failure and labour controllers when not focused
          if (!failureFocus.hasFocus) {
            failureController.text = data.failureRisk.toString();
          }
          if (!labourFocus.hasFocus) {
            labourController.text = data.labourRate.toString();
          }
          if (!markupFocus.hasFocus) {
            markupController.text = data.pricingMarkupPercent.toString();
          }
          if (!setupFeeFocus.hasFocus) {
            setupFeeController.text = data.pricingSetupFee.toString();
          }
          if (!currencySymbolFocus.hasFocus) {
            currencySymbolController.text = data.currencySymbol.toString();
          }

          final currentRoundingMode = pricingRoundingModeFromStorage(
            data.pricingRoundingMode,
          );

          return Container(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FocusSafeTextField(
                        key: const ValueKey<String>(
                          'settings.workCost.wearAndTear.input',
                        ),
                        controller: wearController,
                        externalText: wearText,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: localizedDecimalInputFormatters,
                        inputNormalizer: normalizeLeadingZeroNumericInput,
                        validator: (value) {
                          if (normalizeLocalizedNumber(value).isEmpty) {
                            return l10n.enterNumber;
                          }
                          if (tryParseLocalizedNum(value) == null) {
                            return l10n.invalidNumber;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          persistWear(value);
                        },
                        decoration: InputDecoration(
                          labelText: l10n.wearAndTearLabel,
                          prefixText: currencySettings.currencySymbol.isNotEmpty &&
                                  currencySettings.currencyPosition == 'before'
                              ? currencySettings.currencySymbol +
                                  (currencySettings.currencySpacing ? ' ' : '')
                              : null,
                          suffixText: currencySettings.currencyPosition == 'after' &&
                                  currencySettings.currencySymbol.isNotEmpty
                              ? (currencySettings.currencySpacing
                                  ? ' ${currencySettings.currencySymbol}'
                                  : currencySettings.currencySymbol)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FocusSafeTextField(
                        key: const ValueKey<String>(
                          'settings.workCost.failureRisk.input',
                        ),
                        controller: failureController,
                        externalText: data.failureRisk.toString(),
                        focusNode: failureFocus,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: localizedDecimalInputFormatters,
                        inputNormalizer: normalizeLeadingZeroNumericInput,
                        validator: (value) {
                          if (normalizeLocalizedNumber(value).isEmpty) {
                            return l10n.enterNumber;
                          }
                          if (tryParseLocalizedNum(value) == null) {
                            return l10n.invalidNumber;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          persistFailure(value);
                        },
                        decoration: InputDecoration(
                          labelText: l10n.failureRiskLabel,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FocusSafeTextField(
                        key: const ValueKey<String>(
                          'settings.workCost.labourRate.input',
                        ),
                        controller: labourController,
                        externalText: data.labourRate.toString(),
                        focusNode: labourFocus,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: localizedDecimalInputFormatters,
                        inputNormalizer: normalizeLeadingZeroNumericInput,
                        validator: (value) {
                          if (normalizeLocalizedNumber(value).isEmpty) {
                            return l10n.enterNumber;
                          }
                          if (tryParseLocalizedNum(value) == null) {
                            return l10n.invalidNumber;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          persistLabour(value);
                        },
                        decoration: InputDecoration(
                          labelText: l10n.labourRateLabel,
                          prefixText: currencySettings.currencySymbol.isNotEmpty &&
                                  currencySettings.currencyPosition == 'before'
                              ? currencySettings.currencySymbol +
                                  (currencySettings.currencySpacing ? ' ' : '')
                              : null,
                          suffixText: currencySettings.currencyPosition == 'after' &&
                                  currencySettings.currencySymbol.isNotEmpty
                              ? (currencySettings.currencySpacing
                                  ? ' ${currencySettings.currencySymbol}'
                                  : currencySettings.currencySymbol)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FocusSafeTextField(
                        key: const ValueKey<String>(
                          'settings.workCost.pricingMarkup.input',
                        ),
                        controller: markupController,
                        externalText: data.pricingMarkupPercent.toString(),
                        focusNode: markupFocus,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: localizedDecimalInputFormatters,
                        inputNormalizer: normalizeLeadingZeroNumericInput,
                        validator: (value) {
                          if (normalizeLocalizedNumber(value).isEmpty) {
                            return l10n.enterNumber;
                          }
                          if (tryParseLocalizedNum(value) == null) {
                            return l10n.invalidNumber;
                          }
                          return null;
                        },
                        onChanged: persistMarkup,
                        decoration: InputDecoration(
                          labelText: l10n.pricingMarkupPercentLabel,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FocusSafeTextField(
                        key: const ValueKey<String>(
                          'settings.workCost.pricingSetupFee.input',
                        ),
                        controller: setupFeeController,
                        externalText: data.pricingSetupFee.toString(),
                        focusNode: setupFeeFocus,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: localizedDecimalInputFormatters,
                        inputNormalizer: normalizeLeadingZeroNumericInput,
                        validator: (value) {
                          if (normalizeLocalizedNumber(value).isEmpty) {
                            return l10n.enterNumber;
                          }
                          if (tryParseLocalizedNum(value) == null) {
                            return l10n.invalidNumber;
                          }
                          return null;
                        },
                        onChanged: persistSetupFee,
                        decoration: InputDecoration(
                          labelText: l10n.pricingSetupFeeLabel,
                          prefixText: currencySettings.currencySymbol.isNotEmpty &&
                                  currencySettings.currencyPosition == 'before'
                              ? currencySettings.currencySymbol +
                                  (currencySettings.currencySpacing ? ' ' : '')
                              : null,
                          suffixText: currencySettings.currencyPosition == 'after' &&
                                  currencySettings.currencySymbol.isNotEmpty
                              ? (currencySettings.currencySpacing
                                  ? ' ${currencySettings.currencySymbol}'
                                  : currencySettings.currencySymbol)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<PricingRoundingMode>(
                        key: const ValueKey<String>(
                          'settings.workCost.pricingRounding.input',
                        ),
                        initialValue: currentRoundingMode,
                        decoration: InputDecoration(
                          labelText: l10n.pricingRoundingLabel,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: PricingRoundingMode.none,
                            child: Text(l10n.pricingRoundingNoneLabel),
                          ),
                          DropdownMenuItem(
                            value: PricingRoundingMode.wholeDollar,
                            child: Text(l10n.pricingRoundingWholeDollarLabel),
                          ),
                          DropdownMenuItem(
                            value: PricingRoundingMode.pointNinetyNine,
                            child: Text(
                              l10n.pricingRoundingPointNinetyNineLabel,
                            ),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == null) return;
                          try {
                            await settingsService.update(
                              (settings) => settings.copyWith(
                                pricingRoundingMode: value.storageValue,
                              ),
                            );
                            logPricingSettingsChange(
                              markupPercent:
                                  tryParseLocalizedNum(markupController.text) ??
                                  0,
                              setupFee:
                                  tryParseLocalizedNum(
                                    setupFeeController.text,
                                  ) ??
                                  0,
                              roundingMode: value.storageValue,
                            );
                          } catch (e, st) {
                            logger.error(
                              AppLogCategory.ui,
                              'Failed to persist pricing rounding mode',
                              context: {'setting': 'pricingRoundingMode'},
                              error: e,
                              stackTrace: st,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FocusSafeTextField(
                        key: const ValueKey<String>(
                          'settings.workCost.currencySymbol.input',
                        ),
                        controller: currencySymbolController,
                        externalText: data.currencySymbol.toString(),
                        focusNode: currencySymbolFocus,
                        decoration: InputDecoration(
                          labelText: l10n.currencySymbolLabel,
                        ),
                        onChanged: persistCurrencySymbol,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: const ValueKey<String>(
                          'settings.workCost.currencyPosition.input',
                        ),
                        initialValue: data.currencyPosition,
                        decoration: InputDecoration(
                          labelText: l10n.currencyPositionLabel,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'before',
                            child: Text(l10n.currencyPositionBeforeLabel),
                          ),
                          DropdownMenuItem(
                            value: 'after',
                            child: Text(l10n.currencyPositionAfterLabel),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == null) return;
                          await settingsService.update(
                            (settings) =>
                                settings.copyWith(currencyPosition: value),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SwitchListTile.adaptive(
                        key: const ValueKey<String>(
                          'settings.workCost.currencySpacing.toggle',
                        ),
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.currencySpacingLabel),
                        value: data.currencySpacing,
                        onChanged: (value) async {
                          await settingsService.update(
                            (settings) =>
                                settings.copyWith(currencySpacing: value),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        key: const ValueKey<String>(
                          'settings.workCost.currencyPreview',
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.currencyPreviewLabel),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrencyValue(
                                95.3,
                                currencySymbol: data.currencySymbol,
                                currencyPosition: data.currencyPosition,
                                currencySpacing: data.currencySpacing,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
