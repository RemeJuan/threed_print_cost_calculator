import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(batchCostingEnabledProvider)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final hasReady = _rows.any((row) => row.status == _ImportStatus.ready);
    final hasNeedsDetails =
        _rows.any((row) => row.status == _ImportStatus.needsDetails);
    final allDone = !_loading &&
        _rows.isNotEmpty &&
        _rows.every(
          (row) => row.status != _ImportStatus.importing,
        );

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
            const SizedBox(height: 8),
            Text(
              l10n.batchGcodeImportQuantityHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _rows.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.separated(
                      itemCount: _rows.length,
                      separatorBuilder: (context, _) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) =>
                          _buildFileRow(_rows[index], index, l10n),
                    ),
            ),
            if (allDone && hasReady && !hasNeedsDetails)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const BatchCostingPage(),
                      ),
                    );
                  },
                  child: Text(l10n.batchGcodeImportContinueButton),
                ),
              )
            else if (allDone && _rows.isNotEmpty && !hasReady && !hasNeedsDetails)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        MaterialLocalizations.of(context).backButtonTooltip,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _pickAndImport(context),
                      child: Text(l10n.batchGcodeImportRetryButton),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileRow(_BatchImportRow row, int index, AppLocalizations l10n) {
    switch (row.status) {
      case _ImportStatus.importing:
        return ListTile(
          leading: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text(row.file.name),
          subtitle: Text(l10n.batchGcodeImportImportingLabel),
        );
      case _ImportStatus.needsDetails:
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        row.file.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.batchGcodeImportNeedsDetailsLabel,
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 13,
                  ),
                ),
                if (row.missingWeight) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: row.weightController,
                    decoration: InputDecoration(
                      labelText: l10n.batchGcodeImportNeedsWeight,
                      suffixText: l10n.gramsSuffix,
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                  ),
                ],
                if (row.missingDuration) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: row.durationController,
                    decoration: InputDecoration(
                      labelText: l10n.batchGcodeImportNeedsDuration,
                      suffixText: 'min',
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => _removeRow(index),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(l10n.batchCostingReviewRemoveButton),
                    ),
                    const Spacer(),
                    FilledButton.tonalIcon(
                      onPressed: () => _applyDetails(index),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(l10n.batchGcodeImportApply),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      case _ImportStatus.ready:
        return ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text(row.file.name),
          subtitle: Text(l10n.batchGcodeImportReadyLabel),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.batchCostingReviewRemoveButton,
            onPressed: () => _removeRow(index),
          ),
        );
      case _ImportStatus.failed:
        return ListTile(
          leading: Icon(Icons.error,
              color: Theme.of(context).colorScheme.error),
          title: Text(row.file.name),
          subtitle:
              Text(row.errorMessage ?? l10n.batchGcodeImportFailureLabel),
        );
    }
  }

  void _applyDetails(int index) {
    final row = _rows[index];
    final notifier = ref.read(batchCostingProvider.notifier);
    final stateItems = ref.read(batchCostingProvider).items;
    final item = stateItems.firstWhere((i) => i.id == row.batchItemId);

    double? weight = item.printWeightG;
    Duration? duration = item.printDuration;

    if (row.missingWeight) {
      final parsed = double.tryParse(row.weightController!.text);
      if (parsed == null || parsed <= 0) return;
      weight = parsed;
    }

    if (row.missingDuration) {
      final parsed = int.tryParse(row.durationController!.text);
      if (parsed == null || parsed <= 0) return;
      duration = Duration(minutes: parsed);
    }

    final updated = item.copyWith(
      printWeightG: weight,
      printDuration: duration,
    );
    notifier.updateItem(updated);
    setState(() => _rows[index].status = _ImportStatus.ready);
  }

  void _removeRow(int index) {
    final row = _rows[index];
    if (row.batchItemId != null) {
      ref.read(batchCostingProvider.notifier).removeItem(row.batchItemId!);
    }
    row.dispose();
    setState(() => _rows.removeAt(index));
  }

  bool _isDuplicate(GCodePickedFile file) {
    return _rows.any((row) {
      if (file.path != null && row.file.path != null) {
        return file.path == row.file.path;
      }
      return file.name == row.file.name;
    });
  }

  Future<void> _pickAndImport(BuildContext context) async {
    setState(() => _loading = true);

    try {
      final l10n = AppLocalizations.of(context)!;
      final messenger = ScaffoldMessenger.of(context);
      final files = await ref.read(gcodeImportFilePickerProvider).pickMany();
      if (!mounted) return;

      if (files.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      final newFiles = <GCodePickedFile>[];
      var dupCount = 0;
      for (final file in files) {
        if (_isDuplicate(file)) {
          dupCount++;
        } else {
          newFiles.add(file);
        }
      }

      if (dupCount > 0 && mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.batchGcodeImportDuplicateMessage)),
        );
      }

      if (newFiles.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      final oldCount = _rows.length;
      setState(() {
        for (final file in newFiles) {
          _rows.add(_BatchImportRow(file));
        }
      });

      final service = ref.read(gcodeImportServiceProvider);
      final notifier = ref.read(batchCostingProvider.notifier);
      for (var i = 0; i < newFiles.length; i++) {
        if (!mounted) return;
        final index = oldCount + i;
        final file = newFiles[i];

        setState(() => _rows[index].status = _ImportStatus.importing);

        try {
          final result = await service.importPickedFile(file);
          final batchId = '${DateTime.now().microsecondsSinceEpoch}-$i';
          notifier.addItem(
            BatchCostingItem.fromGCodeImport(
              id: batchId,
              displayName: file.name,
              quantity: 1,
              importResult: result,
              sourceFileName: file.name,
              sourcePath: file.path,
            ),
          );

          final missingW = result.filamentWeightG == null;
          final missingD = result.estimatedDuration == null;

          if (missingW || missingD) {
            setState(() {
              _rows[index].status = _ImportStatus.needsDetails;
              _rows[index].batchItemId = batchId;
              _rows[index].missingWeight = missingW;
              _rows[index].missingDuration = missingD;
              _rows[index].weightController = TextEditingController();
              _rows[index].durationController = TextEditingController();
            });
          } else {
            setState(() {
              _rows[index].status = _ImportStatus.ready;
              _rows[index].batchItemId = batchId;
            });
          }
        } catch (error, stackTrace) {
          developer.log(
            'Batch G-code import failed for ${file.name}',
            error: error,
            stackTrace: stackTrace,
          );
          if (mounted) {
            setState(() {
              _rows[index].status = _ImportStatus.failed;
              _rows[index].errorMessage =
                  '${l10n.batchGcodeImportParseFailure}: $error';
            });
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}

enum _ImportStatus { importing, needsDetails, ready, failed }

class _BatchImportRow {
  _BatchImportRow(this.file)
      : status = _ImportStatus.importing,
        errorMessage = null;

  final GCodePickedFile file;
  _ImportStatus status;
  String? errorMessage;
  String? batchItemId;
  bool missingWeight = false;
  bool missingDuration = false;
  TextEditingController? weightController;
  TextEditingController? durationController;

  void dispose() {
    weightController?.dispose();
    durationController?.dispose();
  }
}
