import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

class HistoryLoadWarningBanner extends ConsumerWidget {
  const HistoryLoadWarningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: kAppSpace12),
      padding: const EdgeInsets.all(kAppSpace12),
      decoration: BoxDecoration(
        color: STATUS_WARNING.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(kAppSurfaceRadius),
        border: Border.all(color: STATUS_WARNING.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: STATUS_WARNING),
          const SizedBox(width: kAppSpace12),
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
