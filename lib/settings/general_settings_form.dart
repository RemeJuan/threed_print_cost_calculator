import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/services/settings_service.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/utils/debounce_constants.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

class GeneralSettings extends HookConsumerWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(context, ref) {
    final l10n = AppLocalizations.of(context)!;
    final currencyAsync = ref.watch(settingsStreamProvider);
    final currencySettings = currencyAsync is AsyncData<GeneralSettingsModel>
        ? currencyAsync.value
        : GeneralSettingsModel.initial();

    // Hook-managed controllers and focus nodes must be called at the top-level of build
    final electricityController = useTextEditingController();
    final electricityFocus = useFocusNode();
    final wattController = useTextEditingController();
    final wattFocus = useFocusNode();
    final avgWattController = useTextEditingController();
    final avgWattFocus = useFocusNode();

    final electricityDebounceRef = useRef<Timer?>(null);
    final wattDebounceRef = useRef<Timer?>(null);
    final avgWattDebounceRef = useRef<Timer?>(null);

    // Ensure debounce timers are cancelled when widget is disposed
    useEffect(() {
      return () {
        electricityDebounceRef.value?.cancel();
        wattDebounceRef.value?.cancel();
        avgWattDebounceRef.value?.cancel();
      };
    }, []);

    final settingsRepository = ref.read(settingsRepositoryProvider);
    final settingsService = ref.read(settingsServiceProvider);
    final logger = ref.read(appLoggerProvider);

    Future<void> persistElectricity(String value) async {
      // Cancel previous timer
      electricityDebounceRef.value?.cancel();

      final parsed = tryParseLocalizedNum(value);
      if (parsed == null) return;

      electricityDebounceRef.value = Timer(debounce400ms, () async {
        try {
          await settingsService.update(
            (settings) => settings.copyWith(electricityCost: parsed.toString()),
          );
        } catch (e, st) {
          logger.error(
            AppLogCategory.ui,
            'Failed to persist electricity cost',
            context: {'setting': 'electricityCost'},
            error: e,
            stackTrace: st,
          );
        }
      });
    }

    Future<void> persistWatt(String value) async {
      wattDebounceRef.value?.cancel();

      final parsed = tryParseLocalizedInt(value);
      if (parsed == null) return;

      wattDebounceRef.value = Timer(debounce400ms, () async {
        try {
          await settingsService.update(
            (settings) => settings.copyWith(wattage: parsed.toString()),
          );
        } catch (e, st) {
          logger.error(
            AppLogCategory.ui,
            'Failed to persist wattage',
            context: {'setting': 'wattage'},
            error: e,
            stackTrace: st,
          );
        }
      });
    }

    Future<void> persistAverageWatt(String value) async {
      avgWattDebounceRef.value?.cancel();

      if (value.trim().isEmpty) {
        avgWattDebounceRef.value = Timer(debounce400ms, () async {
          try {
            await settingsService.update(
              (settings) => settings.copyWith(averageWattage: ''),
            );
          } catch (e, st) {
            logger.error(
              AppLogCategory.ui,
              'Failed to clear average wattage',
              context: {'setting': 'averageWattage'},
              error: e,
              stackTrace: st,
            );
          }
        });
        return;
      }

      final parsed = tryParseLocalizedInt(value);
      if (parsed == null) return;

      avgWattDebounceRef.value = Timer(debounce400ms, () async {
        try {
          await settingsService.update(
            (settings) => settings.copyWith(averageWattage: parsed.toString()),
          );
        } catch (e, st) {
          logger.error(
            AppLogCategory.ui,
            'Failed to persist average wattage',
            context: {'setting': 'averageWattage'},
            error: e,
            stackTrace: st,
          );
        }
      });
    }

    // Use a hook to subscribe to the database record stream at top-level
    final snapshot = useStream<GeneralSettingsModel>(
      settingsRepository.watchSettings(),
      initialData: GeneralSettingsModel.initial(),
    );

    final data = snapshot.data ?? GeneralSettingsModel.initial();

    // If the stream has an error, log it (keep rendering the form with initial/default data)
    if (snapshot.hasError) {
      logger.warn(
        AppLogCategory.ui,
        'General settings stream reported an error',
        context: {'stream': 'settings'},
        error: snapshot.error,
      );
    }

    // Sync controller text with external data when field is not focused
    useEffect(() {
      if (!electricityFocus.hasFocus) {
        electricityController.text = data.electricityCost.toString();
      }
      if (!wattFocus.hasFocus) {
        wattController.text = data.wattage.toString();
      }
      if (!avgWattFocus.hasFocus) {
        avgWattController.text = data.averageWattage.toString();
      }
      return null;
    }, [data.electricityCost, data.wattage, data.averageWattage]);

    return Column(
      children: [
        FocusSafeTextField(
          key: const ValueKey<String>('settings.electricityCost.input'),
          controller: electricityController,
          externalText: data.electricityCost.toString(),
          focusNode: electricityFocus,
          keyboardType: TextInputType.number,
          inputNormalizer: normalizeLeadingZeroNumericInput,
          decoration: InputDecoration(
            labelText: l10n.electricityCostSettingsLabel,
            prefixText:
                currencySettings.currencySymbol.isNotEmpty &&
                    currencySettings.currencyPosition == 'before'
                ? currencySettings.currencySymbol +
                      (currencySettings.currencySpacing ? ' ' : '')
                : null,
            suffixText:
                currencySettings.currencyPosition == 'after' &&
                    currencySettings.currencySymbol.isNotEmpty
                ? '${l10n.kwh}${currencySettings.currencySpacing ? ' ${currencySettings.currencySymbol}' : currencySettings.currencySymbol}'
                : l10n.kwh,
          ),
          onChanged: (value) async {
            await persistElectricity(value);
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FocusSafeTextField(
                key: const ValueKey<String>('settings.generalWattage.input'),
                controller: wattController,
                externalText: data.wattage.toString(),
                focusNode: wattFocus,
                keyboardType: TextInputType.number,
                inputNormalizer: normalizeLeadingZeroNumericInput,
                decoration: InputDecoration(
                  labelText: l10n.wattageLabel,
                  suffixText: l10n.watt,
                ),
                onChanged: (value) async {
                  await persistWatt(value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FocusSafeTextField(
                key: const ValueKey<String>(
                  'settings.generalAverageWattage.input',
                ),
                controller: avgWattController,
                externalText: data.averageWattage.toString(),
                focusNode: avgWattFocus,
                keyboardType: TextInputType.number,
                inputNormalizer: normalizeLeadingZeroNumericInput,
                decoration: InputDecoration(
                  labelText: l10n.averageWattageLabel,
                  suffixText: l10n.watt,
                ),
                onChanged: (value) async {
                  await persistAverageWatt(value);
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.wattageFaqHint,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: TEXT_TERTIARY),
            ),
          ),
        ),
      ],
    );
  }
}
