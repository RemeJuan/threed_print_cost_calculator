import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

class WorkCostsSettings extends HookConsumerWidget {
  const WorkCostsSettings({super.key});

  @override
  Widget build(context, ref) {
    final l10n = S.of(context);

    // Controller for wearAndTear so the field reflects external updates
    final wearController = useTextEditingController();

    final db = ref.read(databaseProvider);
    final store = StoreRef.main();
    final dbHelper = ref.read(dbHelpersProvider(DBName.settings));

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
    void persistFailure(String value, GeneralSettingsModel data) {
      failureDebounce.value?.cancel();
      failureDebounce.value = Timer(
        const Duration(milliseconds: 400),
        () async {
          final v = value.replaceAll(',', '.').trim();
          final parsed = num.tryParse(v);
          if (parsed == null) return;
          try {
            final updated = data.copyWith(failureRisk: parsed.toString());
            await dbHelper.putRecord(updated.toMap());
          } catch (e, st) {
            if (kDebugMode) print('Error persisting failure risk: $e\n$st');
          }
        },
      );
    }

    void persistLabour(String value, GeneralSettingsModel data) {
      labourDebounce.value?.cancel();
      labourDebounce.value = Timer(const Duration(milliseconds: 400), () async {
        final v = value.replaceAll(',', '.').trim();
        final parsed = num.tryParse(v);
        if (parsed == null) return;
        try {
          final updated = data.copyWith(labourRate: parsed.toString());
          await dbHelper.putRecord(updated.toMap());
        } catch (e, st) {
          if (kDebugMode) print('Error persisting labour rate: $e\n$st');
        }
      });
    }

    void persistWear(String value, GeneralSettingsModel data) {
      wearDebounce.value?.cancel();
      wearDebounce.value = Timer(const Duration(milliseconds: 400), () async {
        final v = value.replaceAll(',', '.').trim();
        final parsed = num.tryParse(v);
        if (parsed == null) return;
        try {
          final updated = data.copyWith(wearAndTear: parsed.toString());
          await dbHelper.putRecord(updated.toMap());
        } catch (e, st) {
          if (kDebugMode) print('Error persisting wear and tear: $e\n$st');
        }
      });
    }

    return StreamBuilder(
      stream: store.record(DBName.settings.name).onSnapshot(db),
      builder: (context, snapshot) {
        late GeneralSettingsModel data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else {
          if (snapshot.hasData) {
            data = GeneralSettingsModel.fromMap(
              snapshot.data!.value as Map<String, dynamic>,
            );
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
                  controller: wearController,
                  externalText: wearText,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  validator: (value) {
                    final v = value?.replaceAll(',', '.') ?? '';
                    if (v.isEmpty) return l10n.enterNumber;
                    if (num.tryParse(v) == null) return l10n.invalidNumber;
                    return null;
                  },
                  onChanged: (value) {
                    // Schedule debounced persistence; fire-and-forget
                    persistWear(value, data);
                  },
                  decoration: InputDecoration(labelText: l10n.wearAndTearLabel),
                ),
                const SizedBox(height: 16),
                FocusSafeTextField(
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
                    final v = value?.replaceAll(',', '.') ?? '';
                    if (v.isEmpty) return l10n.enterNumber;
                    if (num.tryParse(v) == null) return l10n.invalidNumber;
                    return null;
                  },
                  onChanged: (value) {
                    persistFailure(value, data);
                  },
                  decoration: InputDecoration(labelText: l10n.failureRiskLabel),
                ),
                const SizedBox(height: 16),
                FocusSafeTextField(
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
                    final v = value?.replaceAll(',', '.') ?? '';
                    if (v.isEmpty) return l10n.enterNumber;
                    if (num.tryParse(v) == null) return l10n.invalidNumber;
                    return null;
                  },
                  onChanged: (value) {
                    persistLabour(value, data);
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
