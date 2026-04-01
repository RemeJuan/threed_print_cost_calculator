import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

class GeneralSettings extends HookConsumerWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(context, ref) {
    final l10n = S.of(context);

    // Hook-managed controllers and focus nodes must be called at the top-level of build
    final electricityController = useTextEditingController();
    final electricityFocus = useFocusNode();
    final wattController = useTextEditingController();
    final wattFocus = useFocusNode();

    final electricityDebounceRef = useRef<Timer?>(null);
    final wattDebounceRef = useRef<Timer?>(null);

    // Ensure debounce timers are cancelled when widget is disposed
    useEffect(() {
      return () {
        electricityDebounceRef.value?.cancel();
        wattDebounceRef.value?.cancel();
      };
    }, []);

    final settingsRepository = ref.read(settingsRepositoryProvider);
    final logger = ref.read(appLoggerProvider);

    Future<void> persistElectricity(
      String value,
      GeneralSettingsModel data,
    ) async {
      // Cancel previous timer
      electricityDebounceRef.value?.cancel();

      final parsed = tryParseLocalizedNum(value);
      if (parsed == null) return;

      electricityDebounceRef.value = Timer(
        const Duration(milliseconds: 400),
        () async {
          try {
            final updated = data.copyWith(electricityCost: parsed.toString());
            await settingsRepository.saveSettings(updated);
          } catch (e, st) {
            logger.error(
              AppLogCategory.ui,
              'Failed to persist electricity cost',
              context: {'setting': 'electricityCost'},
              error: e,
              stackTrace: st,
            );
          }
        },
      );
    }

    Future<void> persistWatt(String value, GeneralSettingsModel data) async {
      wattDebounceRef.value?.cancel();

      final parsed = tryParseLocalizedInt(value);
      if (parsed == null) return;

      wattDebounceRef.value = Timer(
        const Duration(milliseconds: 400),
        () async {
          try {
            final updated = data.copyWith(wattage: parsed.toString());
            await settingsRepository.saveSettings(updated);
          } catch (e, st) {
            logger.error(
              AppLogCategory.ui,
              'Failed to persist wattage',
              context: {'setting': 'wattage'},
              error: e,
              stackTrace: st,
            );
          }
        },
      );
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
      return null;
    }, [data.electricityCost, data.wattage]);

    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: FocusSafeTextField(
              controller: electricityController,
              externalText: data.electricityCost.toString(),
              focusNode: electricityFocus,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.electricityCostSettingsLabel,
                suffixText: l10n.kwh,
              ),
              onChanged: (value) async {
                await persistElectricity(value, data);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FocusSafeTextField(
              controller: wattController,
              externalText: data.wattage.toString(),
              focusNode: wattFocus,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.wattLabel,
                suffixText: l10n.watt,
              ),
              onChanged: (value) async {
                await persistWatt(value, data);
              },
            ),
          ),
        ],
      ),
    );
  }
}
