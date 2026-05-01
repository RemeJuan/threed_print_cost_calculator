import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/providers/materials_providers.dart';

import 'suggestion_typeahead.dart';

class MaterialTypeTypeahead extends ConsumerWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const MaterialTypeTypeahead({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(context, ref) {
    final types = ref.watch(materialTypesProvider).toList()..sort();
    return SuggestionTypeahead(
      key: const ValueKey<String>('settings.materials.material_type.input'),
      fieldKey: const ValueKey<String>(
        'settings.materials.material_type.input',
      ),
      suggestions: types,
      labelText: AppLocalizations.of(context)!.materialTypeLabel,
      initialValue: initialValue,
      onChanged: onChanged,
    );
  }
}
