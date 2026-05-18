import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';

class BatchPricingScopePage extends ConsumerWidget {
  const BatchPricingScopePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(batchCostingEnabledProvider)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.batchCostingPricingScopeAppBarTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.batchCostingPricingScopeSubtitle),
        ),
      ),
    );
  }
}
