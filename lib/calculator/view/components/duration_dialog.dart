import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

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

  void _normalizeController(TextEditingController controller) {
    final normalized = normalizeLeadingZeroNumericInput(
      controller.text,
      allowDecimal: false,
    );
    if (normalized == controller.text) return;

    controller.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
      composing: TextRange.empty,
    );
  }

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
                    hintText: widget.l10n.numberExampleHint,
                  ),
                  onChanged: (_) => _normalizeController(_hoursController),
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
                  onChanged: (_) => _normalizeController(_minutesController),
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
