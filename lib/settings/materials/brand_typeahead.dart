import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/providers/materials_providers.dart';

import 'suggestion_typeahead.dart';

class BrandTypeahead extends ConsumerWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const BrandTypeahead({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(context, ref) {
    final brands = ref.watch(materialBrandsProvider).toList()..sort();
    return SuggestionTypeahead(
      suggestions: brands,
      labelText: AppLocalizations.of(context)!.brandLabel,
      initialValue: initialValue,
      onChanged: onChanged,
    );
  }
}
