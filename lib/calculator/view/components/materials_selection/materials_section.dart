import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_section_free.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_section_premium.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

class MaterialsSection extends HookConsumerWidget {
  const MaterialsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    if (!isPremium) {
      return const MaterialsSectionFree();
    }
    return const MaterialsSectionPremium();
  }
}
