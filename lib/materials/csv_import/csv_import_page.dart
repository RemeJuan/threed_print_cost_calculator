import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_service.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_expansion_card.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_file_export.dart';

class CsvImportPage extends ConsumerStatefulWidget {
  const CsvImportPage({super.key, this.filePicker, this.initialReview});

  @visibleForTesting
  final Future<XFile?> Function()? filePicker;

  @visibleForTesting
  final ClassifiedCsvImport? initialReview;

  @override
  ConsumerState<CsvImportPage> createState() => _CsvImportPageState();
}

@visibleForTesting
String csvImportFileErrorMessage(AppLocalizations l10n, Object error) =>
    error is CsvImportHeaderException
    ? l10n.csvInvalidHeaderError
    : l10n.csvReadError;

class _CsvImportPageState extends ConsumerState<CsvImportPage> {
  final _parser = const CsvImportParser();
  ClassifiedCsvImport? _review;
  CsvImportResult? _result;
  bool _loading = false;
  bool _confirming = false;
  bool _downloadingTemplate = false;

  @override
  void initState() {
    super.initState();
    _review = widget.initialReview;
  }

  Future<void> _downloadTemplate() async {
    if (_downloadingTemplate) return;
    File? tempFile;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _downloadingTemplate = true);
    try {
      final tempDir = await getTemporaryDirectory();
      await cleanupStaleMaterialTemplateFiles();
      tempFile = File(
        '${tempDir.path}/material_template_${DateTime.now().microsecondsSinceEpoch}.csv',
      );
      await tempFile.writeAsString('$csvHeader\n$sampleRow1\n$sampleRow2');
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempFile.path)],
          text: l10n.csvTemplateShareText,
        ),
      );
    } catch (_) {
      if (mounted) BotToast.showText(text: l10n.csvTemplateError);
    } finally {
      if (mounted) {
        setState(() => _downloadingTemplate = false);
      }
    }
  }

  Future<void> _pickFile() async {
    if (_loading) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _review = null;
      _result = null;
    });
    try {
      final result = await (widget.filePicker?.call() ?? openFile());
      if (result == null) return;
      if (!result.name.toLowerCase().endsWith('.csv')) {
        if (mounted) BotToast.showText(text: l10n.csvFileTypeError);
        return;
      }

      final content = await result.readAsString();
      final parsed = parseCsvImportFile(content);
      final classified = await _parser.classifyAsync(
        file: parsed,
        lookupIds: (ids) =>
            ref.read(materialsRepositoryProvider).existingIds(ids),
      );
      AppAnalytics.safeLog(AppAnalytics.csvImportStarted);
      if (!mounted) return;
      setState(() => _review = classified);
    } catch (error) {
      if (mounted) {
        BotToast.showText(text: csvImportFileErrorMessage(l10n, error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmImport() async {
    final review = _review;
    if (review == null || _confirming) return;
    final l10n = AppLocalizations.of(context)!;
    if (!ref.read(premiumAccessPolicyProvider).stockTracking().allowed) {
      BotToast.showText(text: l10n.csvImportAccessError);
      return;
    }

    setState(() => _confirming = true);
    try {
      final result = await ref
          .read(csvImportServiceProvider)
          .importRows(review.rows);
      if (!mounted) return;
      if (result.quotaExceeded) {
        BotToast.showText(text: l10n.csvImportQuotaExceededError);
        return;
      }
      AppAnalytics.safeLog(
        () => AppAnalytics.csvImportCompleted(
          rowsSuccess: result.imported,
          rowsFailed:
              result.preValidatedFailures +
              result.skippedRows.length +
              result.saveFailures.length,
        ),
      );
      setState(() => _result = result);
    } catch (_) {
      if (mounted) BotToast.showText(text: l10n.csvImportSaveError);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppScreenHeader(
        title: l10n.csvImportTitle,
        actions: [
          TextButton.icon(
            onPressed: _downloadingTemplate ? null : _downloadTemplate,
            icon: const Icon(Icons.download, color: OFF_WHITE),
            label: Text(
              l10n.csvTemplateButton,
              style: const TextStyle(color: OFF_WHITE),
            ),
          ),
        ],
      ),
      body: _result != null
          ? _buildResult(l10n)
          : _review != null
          ? _buildReview(l10n, _review!)
          : _buildStart(l10n),
    );
  }

  Widget _buildStart(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kAppSpace16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.upload_file, size: 64, color: TEXT_TERTIARY),
            const SizedBox(height: kAppSpace16),
            Text(
              l10n.csvImportIntro,
              textAlign: TextAlign.center,
              style: const TextStyle(color: TEXT_SECONDARY),
            ),
            const SizedBox(height: kAppSpace16),
            AppPrimaryButton(
              key: const ValueKey<String>('csv_import.select_file.button'),
              onPressed: _loading ? null : _pickFile,
              loading: _loading,
              icon: const Icon(Icons.folder_open),
              label: l10n.csvSelectFileButton,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(AppLocalizations l10n, ClassifiedCsvImport review) {
    final updates = _rowsOf(review, CsvImportRowKind.update);
    final creates = _rowsOf(review, CsvImportRowKind.create);
    final invalid = _rowsOf(review, CsvImportRowKind.invalid);
    final validCount = updates.length + creates.length;
    return Column(
      children: [
        AppSurfaceCard(
          margin: const EdgeInsets.all(kAppSpace16),
          padding: const EdgeInsets.all(kAppSpace12),
          child: Text(
            l10n.csvImportReviewSummary(
              creates.length,
              invalid.length,
              review.rows.length,
              updates.length,
            ),
            style: const TextStyle(
              color: TEXT_PRIMARY,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: kAppSpace16),
            children: [
              _buildSection(
                key: const ValueKey<String>('csv_import.needs_fixing.section'),
                title: l10n.csvImportNeedsFixingSection(invalid.length),
                rows: invalid,
                initiallyExpanded: true,
                kind: CsvImportRowKind.invalid,
                l10n: l10n,
              ),
              _buildSection(
                key: const ValueKey<String>('csv_import.updating.section'),
                title: l10n.csvImportUpdatingSection(updates.length),
                rows: updates,
                kind: CsvImportRowKind.update,
                l10n: l10n,
              ),
              _buildSection(
                key: const ValueKey<String>('csv_import.creating.section'),
                title: l10n.csvImportCreatingSection(creates.length),
                rows: creates,
                kind: CsvImportRowKind.create,
                l10n: l10n,
              ),
            ],
          ),
        ),
        if (validCount > 0)
          SafeArea(
            minimum: const EdgeInsets.all(kAppSpace16),
            child: SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                key: const ValueKey<String>('csv_import.apply.button'),
                onPressed: _confirming ? null : _confirmImport,
                loading: _confirming,
                icon: const Icon(Icons.check),
                label: l10n.csvImportApplyButton(
                  creates.length,
                  updates.length,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSection({
    required Key key,
    required String title,
    required List<CsvImportRow> rows,
    required CsvImportRowKind kind,
    required AppLocalizations l10n,
    bool initiallyExpanded = false,
  }) {
    return AppExpansionCard(
      key: key,
      initiallyExpanded: initiallyExpanded,
      title: Text(title),
      margin: const EdgeInsets.symmetric(
        horizontal: kAppSpace16,
        vertical: kAppSpace4,
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: kAppSpace16),
      childrenPadding: const EdgeInsets.only(bottom: kAppSpace8),
      children: rows.map((row) => _buildRowCard(row, kind, l10n)).toList(),
    );
  }

  Widget _buildRowCard(
    CsvImportRow row,
    CsvImportRowKind kind,
    AppLocalizations l10n,
  ) {
    final invalid = kind == CsvImportRowKind.invalid;
    final status = invalid
        ? l10n.csvImportNeedsFixingStatus
        : kind == CsvImportRowKind.update
        ? l10n.csvImportUpdatingStatus
        : l10n.csvImportCreatingStatus;
    return AppSurfaceCard(
      margin: const EdgeInsets.symmetric(
        horizontal: kAppSpace16,
        vertical: kAppSpace4,
      ),
      padding: const EdgeInsets.all(kAppSpace12),
      backgroundColor: invalid
          ? STATUS_ERROR.withValues(alpha: 0.14)
          : CARD_BACKGROUND,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.name.isEmpty ? l10n.csvEmptyNamePlaceholder : row.name,
                  style: const TextStyle(
                    color: TEXT_PRIMARY,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                invalid ? Icons.error_outline : Icons.check_circle_outline,
                color: invalid ? STATUS_ERROR : STATUS_SUCCESS,
              ),
            ],
          ),
          const SizedBox(height: kAppSpace4),
          Text(
            '${l10n.csvImportRowLine(row.lineNumber)} · $status',
            style: const TextStyle(color: TEXT_TERTIARY),
          ),
          if (invalid) ...[
            const SizedBox(height: kAppSpace8),
            Text(
              row.errors.map((error) => _errorMessage(l10n, error)).join(', '),
              style: const TextStyle(color: STATUS_ERROR),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResult(AppLocalizations l10n) {
    final result = _result!;
    final skipped =
        result.preValidatedFailures +
        result.skippedRows.length +
        result.saveFailures.length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kAppSpace16),
      child: AppSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.csvImportResultTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: TEXT_PRIMARY),
            ),
            const SizedBox(height: kAppSpace16),
            Text(
              l10n.csvImportResultUpdated(result.updated),
              style: const TextStyle(color: TEXT_SECONDARY),
            ),
            const SizedBox(height: kAppSpace8),
            Text(
              l10n.csvImportResultCreated(result.created),
              style: const TextStyle(color: TEXT_SECONDARY),
            ),
            const SizedBox(height: kAppSpace8),
            Text(
              l10n.csvImportResultSkipped(skipped),
              style: const TextStyle(color: TEXT_SECONDARY),
            ),
            const SizedBox(height: kAppSpace16),
            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                key: const ValueKey<String>('csv_import.return.button'),
                onPressed: () => Navigator.of(context).pop(),
                label: l10n.csvImportReturnButton,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CsvImportRow> _rowsOf(
    ClassifiedCsvImport review,
    CsvImportRowKind kind,
  ) => review.rows.where((row) => row.kind == kind).toList();

  String _errorMessage(AppLocalizations l10n, CsvImportError error) {
    switch (error.code) {
      case CsvImportErrorCode.requiredName:
        return l10n.csvNameRequiredError;
      case CsvImportErrorCode.requiredColor:
        return l10n.csvColorRequiredError;
      case CsvImportErrorCode.requiredSpoolWeight:
        return l10n.csvSpoolWeightPositiveError;
      case CsvImportErrorCode.invalidSpoolWeight:
        return l10n.csvInvalidSpoolWeightError;
      case CsvImportErrorCode.invalidRemainingWeight:
        return l10n.csvInvalidRemainingWeightError;
      case CsvImportErrorCode.requiredCost:
        return l10n.csvCostPositiveError;
      case CsvImportErrorCode.invalidCost:
        return l10n.csvInvalidCostError;
      case CsvImportErrorCode.invalidTrackRemaining:
        return l10n.csvInvalidTrackRemainingError;
      case CsvImportErrorCode.invalidArchived:
        return l10n.csvInvalidArchivedError;
      case CsvImportErrorCode.invalidHeader:
        return l10n.csvInvalidHeaderError;
      case CsvImportErrorCode.malformedCsv:
        return l10n.csvMalformedError;
    }
  }
}
