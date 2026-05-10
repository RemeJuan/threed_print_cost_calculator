import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

enum CancelFeedbackReason {
  tooExpensive('too_expensive'),
  missingFeatures('missing_features'),
  notEnoughValue('not_enough_value'),
  confusingToUse('confusing_to_use'),
  justTesting('just_testing_the_app'),
  other('other');

  const CancelFeedbackReason(this.analyticsValue);

  final String analyticsValue;
}

Future<void> showCancelFeedbackSheet(
  BuildContext context, {
  required Future<void> Function() onDismiss,
  required Future<void> Function(CancelFeedbackReason reason) onSubmitted,
}) {
  var submitted = false;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => CancelFeedbackSheet(
      onSubmitted: (reason) async {
        submitted = true;
        await onSubmitted(reason);
      },
    ),
  ).whenComplete(() async {
    if (!submitted) {
      await onDismiss();
    }
  });
}

class CancelFeedbackSheet extends StatefulWidget {
  const CancelFeedbackSheet({super.key, required this.onSubmitted});

  final Future<void> Function(CancelFeedbackReason reason) onSubmitted;

  @override
  State<CancelFeedbackSheet> createState() => _CancelFeedbackSheetState();
}

class _CancelFeedbackSheetState extends State<CancelFeedbackSheet> {
  CancelFeedbackReason? _selectedReason;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.cancelFeedbackPromptTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RadioGroup<CancelFeedbackReason>(
              groupValue: _selectedReason,
              onChanged: _isSubmitting
                  ? (_) {}
                  : (value) {
                      setState(() {
                        _selectedReason = value;
                      });
                    },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: CancelFeedbackReason.values
                    .map(
                      (reason) => RadioListTile<CancelFeedbackReason>(
                        value: reason,
                        selected: _selectedReason == reason,
                        contentPadding: EdgeInsets.zero,
                        title: Text(_labelForReason(l10n, reason)),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(l10n.closeButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSubmitting || _selectedReason == null
                        ? null
                        : () async {
                            setState(() {
                              _isSubmitting = true;
                            });

                            try {
                              await widget.onSubmitted(_selectedReason!);
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isSubmitting = false;
                                });
                              }
                            }
                          },
                    child: Text(l10n.feedbackSubmitButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _labelForReason(AppLocalizations l10n, CancelFeedbackReason reason) {
    return switch (reason) {
      CancelFeedbackReason.tooExpensive =>
        l10n.cancelFeedbackReasonTooExpensive,
      CancelFeedbackReason.missingFeatures =>
        l10n.cancelFeedbackReasonMissingFeatures,
      CancelFeedbackReason.notEnoughValue =>
        l10n.cancelFeedbackReasonNotEnoughValue,
      CancelFeedbackReason.confusingToUse =>
        l10n.cancelFeedbackReasonConfusingToUse,
      CancelFeedbackReason.justTesting => l10n.cancelFeedbackReasonJustTesting,
      CancelFeedbackReason.other => l10n.slicerOther,
    };
  }
}
