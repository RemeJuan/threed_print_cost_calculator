import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_section_free.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_section_premium.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';

class MaterialsSection extends HookConsumerWidget {
  const MaterialsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policy = ref.watch(premiumAccessPolicyProvider);

    return policy.materialsLibrary().allowed
        ? const MaterialsSectionPremium()
        : const MaterialsSectionFree();
  }
}
