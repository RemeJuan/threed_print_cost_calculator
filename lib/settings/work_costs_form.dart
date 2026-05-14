import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/services/settings_service.dart';
import 'package:threed_print_cost_calculator/shared/utils/debounce_constants.dart';
import 'package:threed_print_cost_calculator/shared/utils/numeric_input_formatters.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

class WorkCostsSettings extends HookConsumerWidget {
  const WorkCostsSettings({super.key});

  @override
  Widget build(context, ref) {
    final l10n = AppLocalizations.of(context)!;

    final wearController = useTextEditingController();
    final failureController = useTextEditingController();
    final failureFocus = useFocusNode();
    final labourController = useTextEditingController();
    final labourFocus = useFocusNode();
    final markupController = useTextEditingController();
    final setupFeeController = useTextEditingController();
    final currencySymbolController = useTextEditingController();

    final settingsRepository = ref.read(settingsRepositoryProvider);
    final settingsService = ref.read(settingsServiceProvider);
    final logger = ref.read(appLoggerProvider);

    final failureDebounce = useRef<Timer?>(null);
    final labourDebounce = useRef<Timer?>(null);
    final wearDebounce = useRef<Timer?>(null);
    final markupDebounce = useRef<Timer?>(null);
    final setupFeeDebounce = useRef<Timer?>(null);
    final currencySymbolDebounce = useRef<Timer?>(null);

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

    void firePricingSettingsChanged(GeneralSettingsModel s) {
      AppAnalytics.safeLog(
        () => AppAnalytics.pricingSettingsChanged(
          markupPercent: tryParseLocalizedNum(s.pricingMarkupPercent) ?? 0,
          setupFee: tryParseLocalizedNum(s.pricingSetupFee) ?? 0,
          roundingMode: s.pricingRoundingMode,
        ),
      );
    }

    void persistFailure(String value) {
      failureDebounce.value?.cancel();
      failureDebounce.value = Timer(debounce400ms, () async {
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
      });
    }

    void persistLabour(String value) {
      labourDebounce.value?.cancel();
      labourDebounce.value = Timer(debounce400ms, () async {
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
      wearDebounce.value = Timer(debounce400ms, () async {
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
      markupDebounce.value = Timer(debounce400ms, () async {
        final parsed = tryParseLocalizedNum(value);
        if (parsed == null) return;
        try {
          await settingsService.update(
            (settings) =>
                settings.copyWith(pricingMarkupPercent: parsed.toString()),
          );
        } catch (e, st) {
          logger.error(
            AppLogCategory.ui,
            'Failed to persist markup percent',
            context: {'setting': 'pricingMarkupPercent'},
            error: e,
            stackTrace: st,
          );
        }
      });
    }

    void persistSetupFee(String value) {
      setupFeeDebounce.value?.cancel();
      setupFeeDebounce.value = Timer(debounce400ms, () async {
        final parsed = tryParseLocalizedNum(value);
        if (parsed == null) return;
        try {
          await settingsService.update(
            (settings) => settings.copyWith(pricingSetupFee: parsed.toString()),
          );
        } catch (e, st) {
          logger.error(
            AppLogCategory.ui,
            'Failed to persist setup fee',
            context: {'setting': 'pricingSetupFee'},
            error: e,
            stackTrace: st,
          );
        }
      });
    }

    void persistCurrencySymbol(String value) {
      currencySymbolDebounce.value?.cancel();
      currencySymbolDebounce.value = Timer(debounce400ms, () async {
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
      });
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

          final wearText = data.wearAndTear.toString();
          if (wearController.text != wearText) {
            wearController.text = wearText;
          }

          if (!failureFocus.hasFocus) {
            failureController.text = data.failureRisk.toString();
          }
          if (!labourFocus.hasFocus) {
            labourController.text = data.labourRate.toString();
          }

          return Container(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        onChanged: persistWear,
                        decoration: InputDecoration(
                          labelText: l10n.wearAndTearLabel,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
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
                        onChanged: persistFailure,
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
                        onChanged: persistLabour,
                        decoration: InputDecoration(
                          labelText: l10n.labourRateLabel,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: FocusSafeTextField(
                        key: const ValueKey<String>(
                          'settings.workCost.pricingMarkupPercent.input',
                        ),
                        controller: markupController,
                        externalText: data.pricingMarkupPercent.toString(),
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
                          persistMarkup(value);
                          firePricingSettingsChanged(data);
                        },
                        decoration: InputDecoration(
                          labelText: l10n.pricingMarkupPercentLabel,
                          suffixText: '%',
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
                          persistSetupFee(value);
                          firePricingSettingsChanged(data);
                        },
                        decoration: InputDecoration(
                          labelText: l10n.pricingSetupFeeLabel,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: const ValueKey<String>(
                          'settings.workCost.pricingRoundingMode.dropdown',
                        ),
                        initialValue: data.pricingRoundingMode,
                        decoration: InputDecoration(
                          labelText: l10n.pricingRoundingLabel,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'none',
                            child: Text(l10n.pricingRoundingNoneLabel),
                          ),
                          DropdownMenuItem(
                            value: '.00',
                            child: Text(l10n.pricingRoundingWholeDollarLabel),
                          ),
                          DropdownMenuItem(
                            value: '.99',
                            child: Text(
                              l10n.pricingRoundingPointNinetyNineLabel,
                            ),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == null) return;
                          try {
                            await settingsService.update(
                              (settings) =>
                                  settings.copyWith(pricingRoundingMode: value),
                            );
                            firePricingSettingsChanged(data);
                          } catch (e, st) {
                            logger.error(
                              AppLogCategory.ui,
                              'Failed to persist rounding mode',
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
                        externalText: data.currencySymbol,
                        keyboardType: TextInputType.text,
                        onChanged: persistCurrencySymbol,
                        decoration: InputDecoration(
                          labelText: l10n.currencySymbolLabel,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: const ValueKey<String>(
                          'settings.workCost.currencyPosition.dropdown',
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
                          try {
                            await settingsService.update(
                              (settings) =>
                                  settings.copyWith(currencyPosition: value),
                            );
                          } catch (e, st) {
                            logger.error(
                              AppLogCategory.ui,
                              'Failed to persist currency position',
                              context: {'setting': 'currencyPosition'},
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
                      child: SwitchListTile.adaptive(
                        key: const ValueKey<String>(
                          'settings.workCost.currencySpacing.toggle',
                        ),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(l10n.currencySpacingLabel),
                        value: data.currencySpacing,
                        onChanged: (value) async {
                          try {
                            await settingsService.update(
                              (settings) =>
                                  settings.copyWith(currencySpacing: value),
                            );
                          } catch (e, st) {
                            logger.error(
                              AppLogCategory.ui,
                              'Failed to persist currency spacing',
                              context: {'setting': 'currencySpacing'},
                              error: e,
                              stackTrace: st,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${l10n.currencyPreviewLabel}: ${_formatPreview(data)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white54),
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

  String _formatPreview(GeneralSettingsModel s) {
    final amount = '95.30';
    final symbol = s.currencySymbol;
    if (symbol.isEmpty) return amount;
    final sep = s.currencySpacing ? ' ' : '';
    return s.currencyPosition == 'after'
        ? '$amount$sep$symbol'
        : '$symbol$sep$amount';
  }
}
