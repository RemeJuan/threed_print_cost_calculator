import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

class MaterialSelect extends HookConsumerWidget {
  const MaterialSelect({super.key});

  @override
  Widget build(context, ref) {
    final loading = useState<bool>(true);
    final generalSettings = useState(GeneralSettingsModel.initial());
    final l10n = S.of(context);

    Future<void> getSettings() async {
      generalSettings.value = await ref
          .read(settingsRepositoryProvider)
          .getSettings();
      loading.value = false;
    }

    useEffect(() {
      // ignore: unnecessary_statements
      getSettings();

      return null;
    }, []);

    final materialsAsync = ref.watch(materialsStreamProvider);

    return materialsAsync.when(
      data: (data) {
        if (!loading.value) {
          // If there are no materials, render nothing
          if (data.isEmpty) {
            return const SizedBox.shrink();
          }

          // Only use the selected value if it exists in the current data set
          final selectedValue =
              data.any((e) => e.id == generalSettings.value.selectedMaterial)
              ? generalSettings.value.selectedMaterial
              : null;

          return DropdownButton<String>(
            hint: Text(l10n.selectMaterialHint),
            alignment: AlignmentDirectional.centerStart,
            isExpanded: true,
            value: selectedValue,
            items: data.map((e) {
              return DropdownMenuItem(
                value: e.id,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(e.name), Text(e.color)],
                ),
              );
            }).toList(),
            onChanged: (v) async {
              if (v == null) return;

              final updated = generalSettings.value.copyWith(
                selectedMaterial: v,
              );
              generalSettings.value = updated;

              await ref.read(settingsRepositoryProvider).saveSettings(updated);

              final materialWeight = data.firstWhere((e) => e.id == v).weight;
              final materialCost = data.firstWhere((e) => e.id == v).cost;

              ref.read(calculatorProvider.notifier)
                ..updateSpoolWeight(num.parse(materialWeight))
                ..updateSpoolCost(materialCost)
                ..submit();
            },
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
