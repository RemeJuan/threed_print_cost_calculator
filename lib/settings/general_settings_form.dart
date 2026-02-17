import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';

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

    final db = ref.read(databaseProvider);
    final store = StoreRef.main();
    final dbHelper = ref.read(dbHelpersProvider(DBName.settings));

    Future<void> persistElectricity(
      String value,
      GeneralSettingsModel data,
    ) async {
      // Cancel previous timer
      electricityDebounceRef.value?.cancel();

      final trimmed = value.trim();
      if (trimmed.isEmpty) return;

      // Normalize decimal separator and parse
      final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
      if (parsed == null) return;

      electricityDebounceRef.value = Timer(
        const Duration(milliseconds: 400),
        () async {
          try {
            final updated = data.copyWith(electricityCost: parsed.toString());
            await dbHelper.putRecord(updated.toMap());
          } catch (e, st) {
            if (kDebugMode) print('Error persisting electricity cost: $e\n$st');
          }
        },
      );
    }

    Future<void> persistWatt(String value, GeneralSettingsModel data) async {
      wattDebounceRef.value?.cancel();

      final trimmed = value.trim();
      if (trimmed.isEmpty) return;

      // wattage is an integer-like value in the model; try parse as int first
      final parsedInt = int.tryParse(trimmed.replaceAll(',', '.'));
      final parsed =
          parsedInt ?? double.tryParse(trimmed.replaceAll(',', '.'))?.toInt();
      if (parsed == null) return;

      wattDebounceRef.value = Timer(
        const Duration(milliseconds: 400),
        () async {
          try {
            final updated = data.copyWith(wattage: parsed.toString());
            await dbHelper.putRecord(updated.toMap());
          } catch (e, st) {
            if (kDebugMode) print('Error persisting wattage: $e\n$st');
          }
        },
      );
    }

    // Use a hook to subscribe to the database record stream at top-level
    final snapshot = useStream<RecordSnapshot?>(
      store.record(DBName.settings.name).onSnapshot(db),
    );

    late GeneralSettingsModel data;

    // If the stream has an error, log it (keep rendering the form with initial/default data)
    if (snapshot.hasError) {
      if (kDebugMode) print('GeneralSettings stream error: ${snapshot.error}');
    }

    if (snapshot.hasData && snapshot.data?.value != null) {
      data = GeneralSettingsModel.fromMap(
        snapshot.data!.value as Map<String, dynamic>,
      );
    } else {
      // Use initial/default settings until the database provides a value so the form is visible
      data = GeneralSettingsModel.initial();
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
    }, [data]);

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
