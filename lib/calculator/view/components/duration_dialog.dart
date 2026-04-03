import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

/// A dialog that lets the user input hours (free numeric) and minutes (0-59).
/// Returns a `Map<String,int>` via Navigator.pop: {'hours': hours, 'minutes': minutes}.
class DurationDialog extends StatefulWidget {
  final int initialHours;
  final int initialMinutes;
  final S l10n;

  const DurationDialog({
    required this.initialHours,
    required this.initialMinutes,
    required this.l10n,
    super.key,
  });

  @override
  State<DurationDialog> createState() => _DurationDialogState();
}

class _DurationDialogState extends State<DurationDialog> {
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;
  late final FocusNode _hoursFocus;
  late final FocusNode _minutesFocus;

  @override
  void initState() {
    super.initState();
    _hoursController = TextEditingController(
      text: widget.initialHours.toString(),
    );
    _hoursController.selection = TextSelection.fromPosition(
      TextPosition(offset: _hoursController.text.length),
    );
    _minutesController = TextEditingController(
      text: widget.initialMinutes.toString(),
    );
    _minutesController.selection = TextSelection.fromPosition(
      TextPosition(offset: _minutesController.text.length),
    );
    _hoursFocus = FocusNode();
    _minutesFocus = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _hoursFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _hoursFocus.dispose();
    _minutesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '${widget.l10n.hoursLabel} & ${widget.l10n.minutesLabel}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: const ValueKey<String>(
                    'calculator.duration.hours.input',
                  ),
                  controller: _hoursController,
                  focusNode: _hoursFocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: widget.l10n.hoursLabel,
                    hintText: 'e.g. 123',
                  ),
                  onChanged: (v) {
                    // Normalize leading zeros: when user types over an initial '0',
                    // we want '1' not '01'. If the text has more than 1 char and
                    // starts with '0', strip leading zeros (but keep a single '0').
                    String text = _hoursController.text;
                    if (text.length > 1 && text.startsWith('0')) {
                      final normalized = text.replaceFirst(RegExp(r'^0+'), '');
                      final newText = normalized.isEmpty ? '0' : normalized;
                      if (newText != text) {
                        // Update controller text once; this will trigger onChanged again,
                        // but the normalized text won't need further normalization.
                        _hoursController.text = newText;
                      }
                    }

                    // Ensure the caret is at the end after any normalization.
                    final len = _hoursController.text.length;
                    _hoursController.selection = TextSelection.fromPosition(
                      TextPosition(offset: len),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: const ValueKey<String>(
                    'calculator.duration.minutes.input',
                  ),
                  controller: _minutesController,
                  focusNode: _minutesFocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: widget.l10n.minutesLabel,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          key: const ValueKey<String>('calculator.duration.save.button'),
          onPressed: () {
            final hours = int.tryParse(_hoursController.text) ?? 0;
            final rawMinutes = int.tryParse(_minutesController.text) ?? 0;
            final minutes = rawMinutes.clamp(0, 59);
            Navigator.of(context).pop({'hours': hours, 'minutes': minutes});
          },
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}
