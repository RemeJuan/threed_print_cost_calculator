import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class EnablePremiumCodeDialog extends StatefulWidget {
  const EnablePremiumCodeDialog({
    required this.onSubmit,
    required this.onAccepted,
    required this.onCancelled,
    super.key,
  });

  final Future<bool> Function(String code) onSubmit;
  final VoidCallback onAccepted;
  final VoidCallback onCancelled;

  @override
  State<EnablePremiumCodeDialog> createState() =>
      _EnablePremiumCodeDialogState();
}

class _EnablePremiumCodeDialogState extends State<EnablePremiumCodeDialog> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    final ok = await widget.onSubmit(_controller.text.trim());
    if (!mounted) return;

    if (ok) {
      widget.onAccepted();
      return;
    }

    setState(() {
      _submitting = false;
      _error = AppLocalizations.of(context)!.invalidConfirmationCodeMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.enablePremiumTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.enablePremiumBody),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey<String>('settings.testData.enablePremium.code'),
            controller: _controller,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : widget.onCancelled,
          child: Text(l10n.cancelButton),
        ),
        TextButton(
          key: const ValueKey<String>(
            'settings.testData.enablePremium.submit.button',
          ),
          onPressed: _submitting ? null : _submit,
          child: Text(l10n.enablePremiumButton),
        ),
      ],
    );
  }
}
