import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

class WorkCostsSettings extends HookConsumerWidget {
  const WorkCostsSettings({super.key});

  @override
  Widget build(context, ref) {
    final l10n = S.of(context);

    // Controller for wearAndTear so the field reflects external updates
    final wearController = useTextEditingController();

    final settingsRepository = ref.read(settingsRepositoryProvider);
    final logger = ref.read(appLoggerProvider);

    // Hooks for other fields/debounces: keep at top-level to preserve hook order
    final failureController = useTextEditingController();
    final failureFocus = useFocusNode();
    final labourController = useTextEditingController();
    final labourFocus = useFocusNode();

    final failureDebounce = useRef<Timer?>(null);
    final labourDebounce = useRef<Timer?>(null);
    final wearDebounce = useRef<Timer?>(null);

    // Cancel any pending timers when widget unmounts
    useEffect(() {
      return () {
        failureDebounce.value?.cancel();
        labourDebounce.value?.cancel();
        wearDebounce.value?.cancel();
      };
    }, []);

    // persist functions: fire-and-forget debounced schedulers
    void persistFailure(String value) {
      failureDebounce.value?.cancel();
      failureDebounce.value = Timer(
        const Duration(milliseconds: 400),
        () async {
          final parsed = tryParseLocalizedNum(value);
          if (parsed == null) return;
          try {
            final latest = await settingsRepository.getSettings();
            final updated = latest.copyWith(failureRisk: parsed.toString());
            await settingsRepository.saveSettings(updated);
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
          final latest = await settingsRepository.getSettings();
          final updated = latest.copyWith(labourRate: parsed.toString());
          await settingsRepository.saveSettings(updated);
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
          final latest = await settingsRepository.getSettings();
          final updated = latest.copyWith(wearAndTear: parsed.toString());
          await settingsRepository.saveSettings(updated);
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

          return Container(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                FocusSafeTextField(
                  key: const ValueKey<String>(
                    'settings.workCost.wearAndTear.input',
                  ),
                  controller: wearController,
                  externalText: wearText,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
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
                    // Schedule debounced persistence; fire-and-forget
                    persistWear(value);
                  },
                  decoration: InputDecoration(labelText: l10n.wearAndTearLabel),
                ),
                const SizedBox(height: 16),
                FocusSafeTextField(
                  key: const ValueKey<String>(
                    'settings.workCost.failureRisk.input',
                  ),
                  controller: failureController,
                  externalText: data.failureRisk.toString(),
                  focusNode: failureFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
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
                  decoration: InputDecoration(labelText: l10n.failureRiskLabel),
                ),
                const SizedBox(height: 16),
                FocusSafeTextField(
                  key: const ValueKey<String>(
                    'settings.workCost.labourRate.input',
                  ),
                  controller: labourController,
                  externalText: data.labourRate.toString(),
                  focusNode: labourFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
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
                  decoration: InputDecoration(labelText: l10n.labourRateLabel),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
