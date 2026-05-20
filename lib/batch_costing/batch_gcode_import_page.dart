import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_import_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_gcode_import_body.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';

class BatchGCodeImportPage extends ConsumerStatefulWidget {
  const BatchGCodeImportPage({
    super.key,
    this.initialFiles,
    this.embedded = false,
  });

  final List<GCodePickedFile>? initialFiles;
  final bool embedded;

  @override
  ConsumerState<BatchGCodeImportPage> createState() =>
      _BatchGCodeImportPageState();
}

class _BatchGCodeImportPageState extends ConsumerState<BatchGCodeImportPage> {
  final List<BatchImportRow> _rows = <BatchImportRow>[];
  BatchSingleImport? _singleImport;
  String? _singleImportError;
  bool _loading = false;
  bool _autoStarted = false;

  @override
  void dispose() {
    _singleImport?.dispose();
    _singleImportError = null;
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(batchCostingEnabledProvider)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    final body = BatchGcodeImportBody(
      rows: _rows,
      singleImport: _singleImport,
      singleImportError: _singleImportError,
      loading: _loading,
      onPickFiles: () => _pickAndImport(context),
      onRemoveSingleImport: () => _removeSingleImport(_singleImport!),
      onApplySingleImportDetails: () =>
          _applySingleImportDetails(_singleImport!),
      onConfirmSingleImport: () => _confirmSingleImport(context),
      onRemoveRow: (row) => _removeRow(row),
      onApplyDetails: (row) => _applyDetails(row),
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.batchGcodeImportTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: SafeArea(
        child: body,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_autoStarted) return;
    final initialFiles = widget.initialFiles;
    if (initialFiles == null || initialFiles.isEmpty) return;
    _autoStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startWithFiles(initialFiles);
    });
  }

  Future<void> _startWithFiles(List<GCodePickedFile> files) async {
    setState(() => _loading = true);
    try {
      await _pickAndImportFromFiles(files, AppLocalizations.of(context)!);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyDetails(BatchImportRow row) {
    final notifier = ref.read(batchCostingProvider.notifier);
    final stateItems = ref.read(batchCostingProvider).items;
    final item = _findItemById(stateItems, row.batchItemId);
    if (item == null) return;

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
    if (!_rows.contains(row)) return;
    setState(() => row.status = ImportStatus.ready);
  }

  void _applySingleImportDetails(BatchSingleImport singleImport) {
    double? weight = singleImport.result.filamentWeightG;
    Duration? duration = singleImport.result.estimatedDuration;

    if (singleImport.missingWeight) {
      final parsed = double.tryParse(singleImport.weightController.text);
      if (parsed == null || parsed <= 0) return;
      weight = parsed;
    }

    if (singleImport.missingDuration) {
      final parsed = int.tryParse(singleImport.durationController.text);
      if (parsed == null || parsed <= 0) return;
      duration = Duration(minutes: parsed);
    }

    if (!mounted) return;
    setState(() {
      singleImport.missingWeight = false;
      singleImport.missingDuration = false;
      singleImport.overrideWeightG = weight;
      singleImport.overrideDuration = duration;
    });
  }

  void _removeSingleImport(BatchSingleImport singleImport) {
    AppAnalytics.safeLog(
      () => AppAnalytics.batchItemRemoved(source: 'gcode'),
    );
    ref
        .read(batchCostingProvider.notifier)
        .removeItem(singleImport.batchItemId);
    singleImport.dispose();
    setState(() => _singleImport = null);
  }

  void _confirmSingleImport(BuildContext context) {
    final singleImport = _singleImport;
    if (singleImport == null || !singleImport.canContinue) return;

    final importResult =
        (singleImport.overrideWeightG != null ||
                singleImport.overrideDuration != null)
            ? GCodeImportResult(
                slicer: singleImport.result.slicer,
                estimatedDuration:
                    singleImport.overrideDuration ??
                    singleImport.result.estimatedDuration,
                filamentLengthMm: singleImport.result.filamentLengthMm,
                filamentWeightG:
                    singleImport.overrideWeightG ??
                    singleImport.result.filamentWeightG,
                layerHeightMm: singleImport.result.layerHeightMm,
                previewMetadata: singleImport.result.previewMetadata,
                previewImageBytes: singleImport.result.previewImageBytes,
                warnings: singleImport.result.warnings,
                rawExtractedValues: singleImport.result.rawExtractedValues,
                hasSafePreview: singleImport.result.hasSafePreview,
              )
            : singleImport.result;

    ref
        .read(batchCostingProvider.notifier)
        .addItem(
          BatchCostingItem.fromGCodeImport(
            id: singleImport.batchItemId,
            displayName: singleImport.file.name,
            quantity: 1,
            importResult: importResult,
            sourceFileName: singleImport.file.name,
            sourcePath: singleImport.file.path,
            sourceFileSizeBytes: singleImport.file.size,
          ),
        );

    AppAnalytics.safeLog(
      () => AppAnalytics.batchStarted(source: 'gcode_single'),
    );
    AppAnalytics.safeLog(
      () => AppAnalytics.batchItemAdded(source: 'gcode'),
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const BatchCostingPage()));
  }

  void _removeRow(BatchImportRow row) {
    AppAnalytics.safeLog(
      () => AppAnalytics.batchItemRemoved(source: 'gcode'),
    );
    if (row.batchItemId != null) {
      ref.read(batchCostingProvider.notifier).removeItem(row.batchItemId!);
    }
    row.dispose();
    setState(() => _rows.remove(row));
  }

  BatchCostingItem? _findItemById(
    List<BatchCostingItem> items,
    String? id,
  ) {
    if (id == null) return null;
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  bool _isDuplicate(GCodePickedFile file) {
    final singleImport = _singleImport;
    if (singleImport != null) {
      if (file.path != null && singleImport.file.path != null) {
        if (file.path == singleImport.file.path) return true;
      }
      if (file.name == singleImport.file.name) return true;
    }
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

      await _pickAndImportFromFiles(newFiles, l10n);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickAndImportFromFiles(
    List<GCodePickedFile> newFiles,
    AppLocalizations l10n,
  ) async {
    final singleFileMode = newFiles.length == 1;
    final service = ref.read(gcodeImportServiceProvider);
    final notifier = ref.read(batchCostingProvider.notifier);
    final pendingRows = <BatchImportRow>[];
    if (!singleFileMode) {
      setState(() {
        _singleImport?.dispose();
        _singleImport = null;
        _singleImportError = null;
        _rows
          ..forEach((row) => row.dispose())
          ..clear();
        for (final file in newFiles) {
          final row = BatchImportRow(file);
          pendingRows.add(row);
          _rows.add(row);
        }
      });
      AppAnalytics.safeLog(
        () => AppAnalytics.batchStarted(source: 'gcode_multi'),
      );
    }

    var readyCount = 0;
    var needsDetailsCount = 0;
    var failedCount = 0;

    for (var i = 0; i < newFiles.length; i++) {
      if (!mounted) return;
      final file = newFiles[i];
      final row = singleFileMode ? null : pendingRows[i];

      if (row != null && _rows.contains(row)) {
        setState(() => row.status = ImportStatus.importing);
      }

      try {
        final result = await service.importPickedFile(file);
        if (!mounted) {
          continue;
        }
        final batchId = '${DateTime.now().microsecondsSinceEpoch}-$i';

        final missingW = result.filamentWeightG == null;
        final missingD = result.estimatedDuration == null;

        if (singleFileMode) {
          setState(() {
            _singleImport?.dispose();
            _singleImport = null;
            for (final row in _rows) {
              row.dispose();
            }
            _rows.clear();
            _singleImportError = null;
            _singleImport = BatchSingleImport(
              file: file,
              batchItemId: batchId,
              result: result,
              missingWeight: missingW,
              missingDuration: missingD,
            );
          });
          continue;
        }

        notifier.addItem(
          BatchCostingItem.fromGCodeImport(
            id: batchId,
            displayName: file.name,
            quantity: 1,
            importResult: result,
            sourceFileName: file.name,
            sourcePath: file.path,
            sourceFileSizeBytes: file.size,
          ),
        );

        AppAnalytics.safeLog(
          () => AppAnalytics.batchItemAdded(source: 'gcode'),
        );

        if (missingW || missingD) {
          needsDetailsCount++;
          setState(() {
            row!.status = ImportStatus.needsDetails;
            row.batchItemId = batchId;
            row.missingWeight = missingW;
            row.missingDuration = missingD;
            row.weightController = TextEditingController();
            row.durationController = TextEditingController();
          });
        } else {
          readyCount++;
          setState(() {
            row!.status = ImportStatus.ready;
            row.batchItemId = batchId;
          });
        }
      } catch (error, stackTrace) {
        developer.log(
          'Batch G-code import failed for ${file.name}',
          error: error,
          stackTrace: stackTrace,
        );
        if (singleFileMode) {
          setState(() {
            _singleImport?.dispose();
            _singleImport = null;
            _singleImportError = '${l10n.batchGcodeImportParseFailure}: $error';
          });
        } else if (row != null && mounted && _rows.contains(row)) {
          failedCount++;
          setState(() {
            row.status = ImportStatus.failed;
            row.errorMessage = '${l10n.batchGcodeImportParseFailure}: $error';
          });
        }
      }
    }

    if (!singleFileMode && mounted) {
      AppAnalytics.safeLog(
        () => AppAnalytics.batchGCodeImportCompleted(
          totalCount: readyCount + needsDetailsCount + failedCount,
          readyCount: readyCount,
          needsDetailsCount: needsDetailsCount,
          failedCount: failedCount,
          duplicateSkippedCount: 0,
        ),
      );
    }
  }
}

