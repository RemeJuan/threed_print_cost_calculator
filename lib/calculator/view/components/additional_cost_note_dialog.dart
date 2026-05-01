import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class AdditionalCostNoteDialog extends StatefulWidget {
  const AdditionalCostNoteDialog({required this.initialValue, super.key});

  final String? initialValue;

  @override
  State<AdditionalCostNoteDialog> createState() =>
      _AdditionalCostNoteDialogState();
}

class _AdditionalCostNoteDialogState extends State<AdditionalCostNoteDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.additionalCostNoteDialogTitle),
      content: TextField(
        key: const ValueKey<String>('calculator.additionalCost.note.input'),
        controller: _controller,
        focusNode: _focusNode,
        minLines: 3,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: l10n.additionalCostNoteLabel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          key: const ValueKey<String>('calculator.additionalCost.note.save.button'),
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}
