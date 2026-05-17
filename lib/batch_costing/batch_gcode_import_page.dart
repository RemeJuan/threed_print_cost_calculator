import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';

class BatchGCodeImportPage extends ConsumerStatefulWidget {
  const BatchGCodeImportPage({super.key});

  @override
  ConsumerState<BatchGCodeImportPage> createState() =>
      _BatchGCodeImportPageState();
}

class _BatchGCodeImportPageState extends ConsumerState<BatchGCodeImportPage> {
  final List<_BatchImportRow> _rows = <_BatchImportRow>[];
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(batchCostingEnabledProvider)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final successCount = _rows.where((row) => row.success).length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.batchGcodeImportTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.batchGcodeImportBody),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loading ? null : () => _pickAndImport(context),
              icon: const Icon(Icons.folder_open),
              label: Text(l10n.batchGcodeImportPickButton),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _rows.length,
                separatorBuilder: (context, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final row = _rows[index];
                  return ListTile(
                    leading: Icon(
                      row.success ? Icons.check_circle : Icons.error,
                      color: row.success
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                    ),
                    title: Text(row.file.name),
                    subtitle: Text(
                      row.success
                          ? l10n.batchGcodeImportSuccessLabel
                          : row.errorMessage ?? l10n.batchGcodeImportFailureLabel,
                    ),
                  );
                },
              ),
            ),
            if (successCount > 0)
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const BatchCostingPage(),
                    ),
                  );
                },
                child: Text(l10n.batchGcodeImportContinueButton),
              )
            else if (_rows.isNotEmpty)
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(MaterialLocalizations.of(context).backButtonTooltip),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _loading ? null : () => _pickAndImport(context),
                    child: Text(l10n.batchGcodeImportRetryButton),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndImport(BuildContext context) async {
    setState(() {
      _loading = true;
      _rows.clear();
    });

    try {
      final l10n = AppLocalizations.of(context)!;
      final files = await ref.read(gcodeImportFilePickerProvider).pickMany();
      if (!mounted || files.isEmpty) return;

      final service = ref.read(gcodeImportServiceProvider);
      final notifier = ref.read(batchCostingProvider.notifier);
      for (var index = 0; index < files.length; index++) {
        final file = files[index];
        try {
          final result = await service.importPickedFile(file);
          if (result.estimatedDuration != null && result.filamentWeightG != null) {
            notifier.addItem(
              BatchCostingItem.fromGCodeImport(
                id: '${DateTime.now().microsecondsSinceEpoch}-$index',
                displayName: file.name,
                quantity: 1,
                importResult: result,
                sourceFileName: file.name,
                sourcePath: file.path,
              ),
            );
            _rows.add(_BatchImportRow.success(file));
          } else {
            _rows.add(
              _BatchImportRow.failure(file, l10n.batchGcodeImportParseFailure),
            );
          }
        } catch (error, stackTrace) {
          developer.log(
            'Batch G-code import failed for ${file.name}',
            error: error,
            stackTrace: stackTrace,
          );
          _rows.add(
            _BatchImportRow.failure(
              file,
              '${l10n.batchGcodeImportParseFailure}: $error',
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}

class _BatchImportRow {
  _BatchImportRow.success(this.file)
      : success = true,
        errorMessage = null;

  _BatchImportRow.failure(this.file, this.errorMessage) : success = false;

  final GCodePickedFile file;
  final bool success;
  final String? errorMessage;
}
