import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

import 'duration_dialog.dart';

class TimeSection extends HookConsumerWidget {
  const TimeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = S.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Builder(
          builder: (ctx) {
            final currentHours = (state.hours.value ?? 0).toInt();
            final currentMinutes = (state.minutes.value ?? 0).toInt();
            return GestureDetector(
              onTap: () async {
                int selectedHours = currentHours;
                int selectedMinutes = currentMinutes;

                // Show a dedicated dialog widget that owns its controller and focus node
                final result = await showDialog<Map<String, int>>(
                  context: ctx,
                  builder: (_) => DurationDialog(
                    initialHours: selectedHours,
                    initialMinutes: selectedMinutes,
                    l10n: l10n,
                  ),
                );

                if (result != null) {
                  notifier
                    ..updateHours(result['hours'] ?? 0)
                    ..updateMinutes(result['minutes'] ?? 0)
                    ..submit();
                }
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Printing time (hh:mm)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${currentHours.toString().padLeft(2, '0')}:${currentMinutes.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
