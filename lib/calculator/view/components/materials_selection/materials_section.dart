import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_section_free.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_section_premium.dart';

class MaterialsSection extends HookConsumerWidget {
  const MaterialsSection({required this.premium, super.key});

  final bool premium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!premium) {
      return const MaterialsSectionFree();
    }
    return const MaterialsSectionPremium();
  }
}
