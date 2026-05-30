import 'dart:developer' as developer;

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_gcode_import_helpers.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_import_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/purchases/premium_upsell_helper.dart';

class GCodeImportPageState {
  final List<BatchImportRow> rows = <BatchImportRow>[];
  BatchSingleImport? singleImport;
  String? singleImportError;
  bool loading = false;
  bool autoStarted = false;

  void dispose() {
    singleImport = null;
    rows.clear();
  }
}

class BatchGCodeImportHandler {
  BatchGCodeImportHandler({required this.ref});

  final WidgetRef ref;
  bool _mounted = true;

  void markMounted() => _mounted = true;
  void markUnmounted() => _mounted = false;

  void applyDetails(BatchImportRow row, void Function(VoidCallback) setState) {
    final parsed = parseImportOverrideDetails(
      existingWeight: null,
      existingDuration: null,
      missingWeight: row.missingWeight,
      weightText: row.weightText,
      missingDuration: row.missingDuration,
      durationText: row.durationText,
    );
    if (parsed == null) return;

    final notifier = ref.read(batchCostingProvider.notifier);
    final stateItems = ref.read(batchCostingProvider).items;
    final item = findItemById(stateItems, row.batchItemId);
    if (item == null) return;

    final updated = item.copyWith(
      printWeightG: parsed.weight ?? item.printWeightG,
      printDuration: parsed.duration ?? item.printDuration,
    );
    notifier.updateItem(updated);
    setState(() => row.status = ImportStatus.ready);
  }

  void applySingleImportDetails(
    BatchSingleImport singleImport,
    void Function(VoidCallback) setState,
  ) {
    final parsed = parseImportOverrideDetails(
      existingWeight: singleImport.result.filamentWeightG,
      existingDuration: singleImport.result.estimatedDuration,
      missingWeight: singleImport.missingWeight,
      weightText: singleImport.weightText,
      missingDuration: singleImport.missingDuration,
      durationText: singleImport.durationText,
    );
    if (parsed == null) return;

    setState(() {
      singleImport.missingWeight = false;
      singleImport.missingDuration = false;
      singleImport.overrideWeightG = parsed.weight;
      singleImport.overrideDuration = parsed.duration;
    });
  }

  void removeSingleImport(
    BatchSingleImport singleImport,
    void Function(VoidCallback) setState,
  ) {
    AppAnalytics.safeLog(() => AppAnalytics.batchItemRemoved(source: 'gcode'));
    ref
        .read(batchCostingProvider.notifier)
        .removeItem(singleImport.batchItemId);
    setState(() {}); // caller should null out singleImport
  }

  void confirmSingleImport(
    BuildContext context,
    BatchSingleImport singleImport,
  ) {
    if (!singleImport.canContinue) return;
    final l10n = AppLocalizations.of(context)!;

    final importResult = buildImportResult(singleImport);

    final added = ref
        .read(batchCostingProvider.notifier)
        .addItem(
          buildCostingItem(
            id: singleImport.batchItemId,
            file: singleImport.file,
            result: importResult,
          ),
        );

    if (!added) {
      BotToast.showText(text: l10n.batchItemLimitReachedMessage);
      return;
    }

    AppAnalytics.safeLog(
      () => AppAnalytics.batchStarted(source: 'gcode_single'),
    );
    AppAnalytics.safeLog(() => AppAnalytics.batchItemAdded(source: 'gcode'));

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const BatchCostingPage()));
  }

  void removeRow(
    BatchImportRow row,
    List<BatchImportRow> rows,
    void Function(VoidCallback) setState,
  ) {
    AppAnalytics.safeLog(() => AppAnalytics.batchItemRemoved(source: 'gcode'));
    if (row.batchItemId != null) {
      ref.read(batchCostingProvider.notifier).removeItem(row.batchItemId!);
    }
    setState(() => rows.remove(row));
  }

  Future<void> pickAndImport(
    BuildContext context,
    GCodeImportPageState pageState,
    void Function(VoidCallback) setState,
  ) async {
    setState(() => pageState.loading = true);

    try {
      final l10n = AppLocalizations.of(context)!;
      final messenger = ScaffoldMessenger.of(context);
      final files = await ref.read(gcodeImportFilePickerProvider).pickMany();
      if (!_mounted) {
        setState(() => pageState.loading = false);
        return;
      }

      if (files.isEmpty) {
        setState(() => pageState.loading = false);
        return;
      }

      final policy = ref.read(premiumAccessPolicyProvider);
      if (files.length > 1 &&
          !await requirePremium(
            ref.read(paywallPresenterProvider),
            policy.batchGcodeImport(),
            purchaseSource: 'batch_gcode_import',
            recheck: () => Future.value(
              ref.read(premiumAccessPolicyProvider).batchGcodeImport().allowed,
            ),
          )) {
        return;
      }

      final newFiles = <GCodePickedFile>[];
      var dupCount = 0;
      for (final file in files) {
        if (isDuplicateFile(file, pageState.singleImport, pageState.rows)) {
          dupCount++;
        } else {
          newFiles.add(file);
        }
      }

      if (dupCount > 0 && _mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.batchGcodeImportDuplicateMessage)),
        );
      }

      if (newFiles.isEmpty) {
        setState(() => pageState.loading = false);
        return;
      }

      await _pickAndImportFromFiles(newFiles, l10n, pageState, setState);
    } finally {
      if (_mounted) {
        setState(() => pageState.loading = false);
      }
    }
  }

  Future<void> startWithFiles(
    List<GCodePickedFile> files,
    GCodeImportPageState pageState,
    void Function(VoidCallback) setState,
    AppLocalizations l10n,
  ) async {
    setState(() => pageState.loading = true);
    try {
      await _pickAndImportFromFiles(files, l10n, pageState, setState);
    } finally {
      if (_mounted) setState(() => pageState.loading = false);
    }
  }

  Future<void> _pickAndImportFromFiles(
    List<GCodePickedFile> newFiles,
    AppLocalizations l10n,
    GCodeImportPageState pageState,
    void Function(VoidCallback) setState,
  ) async {
    final singleFileMode = newFiles.length == 1;
    final service = ref.read(gcodeImportServiceProvider);
    final notifier = ref.read(batchCostingProvider.notifier);
    final pendingRows = <BatchImportRow>[];
    if (!singleFileMode) {
      setState(() {
        pageState.singleImport = null;
        pageState.singleImportError = null;
        pageState.rows.clear();
        for (final file in newFiles) {
          final row = BatchImportRow(file);
          pendingRows.add(row);
          pageState.rows.add(row);
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
      if (!_mounted) return;
      final file = newFiles[i];
      final row = singleFileMode ? null : pendingRows[i];

      if (row != null && pageState.rows.contains(row)) {
        setState(() => row.status = ImportStatus.importing);
      }

      try {
        final result = await service.importPickedFile(file);
        if (!_mounted) continue;
        final batchId = '${DateTime.now().microsecondsSinceEpoch}-$i';

        final missingW = result.filamentWeightG == null;
        final missingD = result.estimatedDuration == null;

        if (singleFileMode) {
          setState(() {
            pageState.singleImport = null;
            pageState.rows.clear();
            pageState.singleImportError = null;
            pageState.singleImport = BatchSingleImport(
              file: file,
              batchItemId: batchId,
              result: result,
              missingWeight: missingW,
              missingDuration: missingD,
            );
          });
          continue;
        }

        final added = notifier.addItem(
          buildCostingItem(id: batchId, file: file, result: result),
        );

        if (!added) {
          failedCount++;
          setState(() {
            row!.status = ImportStatus.failed;
            row.errorMessage = l10n.batchItemLimitReachedMessage;
          });
          continue;
        }

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
            pageState.singleImport = null;
            pageState.singleImportError =
                '${l10n.batchGcodeImportParseFailure}: $error';
          });
        } else if (row != null && _mounted && pageState.rows.contains(row)) {
          failedCount++;
          setState(() {
            row.status = ImportStatus.failed;
            row.errorMessage = '${l10n.batchGcodeImportParseFailure}: $error';
          });
        }
      }
    }

    if (!singleFileMode && _mounted) {
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
