import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_presentation.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_service.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';
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
    AppAnalytics.safeLog(AppAnalytics.csvImportStarted);
    setState(() {
      _loading = true;
      _review = null;
      _result = null;
    });
    try {
      final result = await (widget.filePicker?.call() ?? openFile());
      if (result == null) {
        AppAnalytics.safeLog(AppAnalytics.csvImportCancelled);
        return;
      }
      if (!result.name.toLowerCase().endsWith('.csv')) {
        if (mounted) BotToast.showText(text: l10n.csvFileTypeError);
        AppAnalytics.safeLog(
          () => AppAnalytics.csvImportFailed(
            reason: CsvImportFailureReason.parseFailed,
          ),
        );
        return;
      }

      final content = await result.readAsString();
      final parsed = parseCsvImportFile(content);
      final classified = await _parser.classifyAsync(
        file: parsed,
        lookupIds: (ids) =>
            ref.read(materialsRepositoryProvider).existingIds(ids),
      );
      if (!mounted) return;
      setState(() => _review = classified);
    } catch (error) {
      if (mounted) {
        BotToast.showText(text: csvImportFileErrorMessage(l10n, error));
      }
      final reason = error is CsvImportHeaderException
          ? CsvImportFailureReason.parseFailed
          : error is FileSystemException
          ? CsvImportFailureReason.readFailed
          : CsvImportFailureReason.unknown;
      AppAnalytics.safeLog(() => AppAnalytics.csvImportFailed(reason: reason));
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
      AppAnalytics.safeLog(
        () => AppAnalytics.csvImportFailed(
          reason: CsvImportFailureReason.accessDenied,
        ),
      );
      return;
    }

    setState(() => _confirming = true);
    try {
      final result = await ref
          .read(csvImportServiceProvider)
          .importRows(review.rows);
      if (result.quotaExceeded) {
        AppAnalytics.safeLog(
          () => AppAnalytics.csvImportFailed(
            reason: CsvImportFailureReason.quotaExceeded,
          ),
        );
        if (!mounted) return;
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
      if (!mounted) return;
      setState(() => _result = result);
    } catch (_) {
      if (mounted) BotToast.showText(text: l10n.csvImportSaveError);
      AppAnalytics.safeLog(
        () => AppAnalytics.csvImportFailed(
          reason: CsvImportFailureReason.saveFailed,
        ),
      );
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
          ? CsvImportResultView(
              result: _result!,
              l10n: l10n,
              onReturn: () => Navigator.of(context).pop(),
            )
          : _review != null
          ? CsvImportReviewView(
              review: _review!,
              l10n: l10n,
              confirming: _confirming,
              onApply: _confirmImport,
            )
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
}
