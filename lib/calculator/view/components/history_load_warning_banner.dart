import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class HistoryLoadWarningBanner extends ConsumerWidget {
  const HistoryLoadWarningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withAlpha(120)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(child: Text(l10n.historyLoadReplacementWarning)),
          IconButton(
            onPressed: () {
              ref
                  .read(calculatorProvider.notifier)
                  .dismissHistoryLoadReplacementWarning();
            },
            icon: const Icon(Icons.close),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          ),
        ],
      ),
    );
  }
}
