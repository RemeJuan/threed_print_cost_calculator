import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_repository.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';

import 'duration_dialog.dart';

class TimeSection extends HookConsumerWidget {
  const TimeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final policy = ref.watch(premiumAccessPolicyProvider);
    final interfaceSettings = ref.watch(interfaceSettingsProvider);
    final printingTimeLabel = l10n.durationPickerLabel.replaceFirst(
      ' (hh:mm)',
      '',
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Builder(
          builder: (ctx) {
            final currentHours = (state.hours.value ?? 0).toInt();
            final currentMinutes = (state.minutes.value ?? 0).toInt();

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _durationButton(
                    context: ctx,
                    label: printingTimeLabel,
                    value: _formatDuration(currentHours, currentMinutes),
                    onTap: () async {
                      final result = await showDialog<Map<String, int>>(
                        context: ctx,
                        builder: (_) => DurationDialog(
                          initialHours: currentHours,
                          initialMinutes: currentMinutes,
                          title: l10n.printingTimeDialogTitle,
                          hoursLabel: l10n.durationHoursLabel,
                          minutesLabel: l10n.durationMinutesLabel,
                        ),
                      );

                      if (result != null) {
                        notifier
                          ..updateHours(result['hours'] ?? 0)
                          ..updateMinutes(result['minutes'] ?? 0)
                          ..submit(trackCompletedCosting: true);
                      }
                    },
                  ),
                ),
                if (policy.labourPricing().allowed && interfaceSettings.showLabourFields) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _durationButton(
                      context: ctx,
                      label: l10n.labourTimeLabel,
                      value: _formatDurationFromDecimal(
                        state.labourTime.value ?? 0,
                      ),
                      onTap: () async {
                        final totalMinutes =
                            ((state.labourTime.value ?? 0) * 60).round();
                        final currentWorkHours = totalMinutes ~/ 60;
                        final currentWorkMinutes = totalMinutes % 60;

                        final result = await showDialog<Map<String, int>>(
                          context: ctx,
                          builder: (_) => DurationDialog(
                            initialHours: currentWorkHours,
                            initialMinutes: currentWorkMinutes,
                            title: l10n.workTimeDialogTitle,
                            hoursLabel: l10n.durationHoursLabel,
                            minutesLabel: l10n.durationMinutesLabel,
                          ),
                        );

                        if (result != null) {
                          final hours = result['hours'] ?? 0;
                          final minutes = result['minutes'] ?? 0;
                          final workTime = hours + (minutes / 60);
                          notifier
                            ..updateLabourTime(workTime)
                            ..submit(trackCompletedCosting: true);
                        }
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _durationButton({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int hours, int minutes) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String _formatDurationFromDecimal(num value) {
    final totalMinutes = (value * 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return _formatDuration(hours, minutes);
  }
}
