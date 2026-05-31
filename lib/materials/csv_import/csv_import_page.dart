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
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_service.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';

class CsvImportPage extends ConsumerStatefulWidget {
  const CsvImportPage({super.key});

  @override
  ConsumerState<CsvImportPage> createState() => _CsvImportPageState();
}

class _CsvImportPageState extends ConsumerState<CsvImportPage> {
  List<ImportRow> _rows = [];
  bool _imported = false;
  AppLocalizations? _l10n;

  String get _csvTemplate => '$csvHeader\n$sampleRow1\n$sampleRow2';

  Future<void> _downloadTemplate() async {
    File? tempFile;
    try {
      tempFile = File(
        '${(await getTemporaryDirectory()).path}/material_template.csv',
      );
      await tempFile.writeAsString(_csvTemplate);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempFile.path)],
          text: _l10n!.csvTemplateShareText,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      BotToast.showText(text: _l10n!.csvTemplateError);
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  Future<void> _pickFile() async {
    final result = await openFile();

    if (result == null) return;
    if (!result.name.toLowerCase().endsWith('.csv')) {
      BotToast.showText(text: _l10n!.csvFileTypeError);
      return;
    }

    try {
      final content = await result.readAsString();
      AppAnalytics.safeLog(AppAnalytics.csvImportStarted);
      final rows = parseCsvContent(content, _l10n!);
      setState(() {
        _rows = rows;
        _imported = true;
      });
    } catch (e) {
      if (!mounted) return;
      BotToast.showText(text: _l10n!.csvReadError);
    }
  }

  Future<void> _importValid() async {
    final validCount = _rows.where((r) => r.errors.isEmpty).length;
    if (validCount == 0) {
      AppAnalytics.safeLog(
        () => AppAnalytics.csvImportCompleted(
          rowsSuccess: 0,
          rowsFailed: _rows.length,
        ),
      );
      BotToast.showText(text: _l10n!.csvNoValidRowsError);
      return;
    }

    final policy = ref.read(premiumAccessPolicyProvider);
    final limit = policy.materialLimit;
    if (limit != null) {
      final currentCount = await ref.read(materialsRepositoryProvider).count();
      if (currentCount + validCount > limit) {
        BotToast.showText(text: _l10n!.csvImportQuotaExceededError);
        return;
      }
    }

    final service = ref.read(csvImportServiceProvider);
    final result = await service.importRows(_rows);

    if (result.quotaExceeded) {
      if (!mounted) return;
      BotToast.showText(text: _l10n!.csvImportQuotaExceededError);
      return;
    }

    AppAnalytics.safeLog(
      () => AppAnalytics.csvImportCompleted(
        rowsSuccess: result.imported,
        rowsFailed: result.preValidatedFailures + result.saveFailures.length,
      ),
    );

    if (!mounted) return;
    BotToast.showText(text: _l10n!.csvImportSuccessMessage(result.imported));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    _l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppScreenHeader(
        title: _l10n!.csvImportTitle,
        actions: [
          TextButton.icon(
            onPressed: _downloadTemplate,
            icon: const Icon(Icons.download, color: OFF_WHITE),
            label: Text(
              _l10n!.csvTemplateButton,
              style: const TextStyle(color: OFF_WHITE),
            ),
          ),
        ],
      ),
      body: _imported ? _buildPreview() : _buildStart(),
      floatingActionButton: _imported && _rows.any((r) => r.errors.isEmpty)
          ? FloatingActionButton.extended(
              backgroundColor: LIGHT_BLUE,
              onPressed: _importValid,
              icon: const Icon(Icons.save),
              label: Text(_l10n!.csvImportButton),
            )
          : null,
    );
  }

  Widget _buildStart() {
    final l10n = _l10n!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.upload_file, size: 64, color: TEXT_TERTIARY),
          const SizedBox(height: kAppSpace16),
          Text(
            l10n.csvImportIntro,
            textAlign: TextAlign.center,
            style: const TextStyle(color: TEXT_SECONDARY),
          ),
          const SizedBox(height: kAppSpace16),
          AppPrimaryButton(
            key: const ValueKey<String>('csv_import.select_file.button'),
            onPressed: _pickFile,
            icon: const Icon(Icons.folder_open),
            label: l10n.csvSelectFileButton,
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final valid = _rows.where((r) => r.errors.isEmpty).length;
    final invalid = _rows.length - valid;
    final l10n = _l10n!;
    final currencyAsync = ref.watch(settingsStreamProvider);
    final currencySettings = currencyAsync is AsyncData<GeneralSettingsModel>
        ? currencyAsync.value
        : GeneralSettingsModel.initial();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(kAppSpace16),
          child: Text(
            l10n.csvPreviewSummary(_rows.length, valid, invalid),
            style: const TextStyle(color: TEXT_SECONDARY),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _rows.length,
            itemBuilder: (_, i) {
              final row = _rows[i];
              final hasErrors = row.errors.isNotEmpty;
              return Card(
                color: hasErrors
                    ? STATUS_ERROR.withValues(alpha: 0.15)
                    : DARK_BLUE,
                margin: const EdgeInsets.symmetric(
                  horizontal: kAppSpace16,
                  vertical: kAppSpace2,
                ),
                child: ListTile(
                  title: Text(
                    row.name.isNotEmpty
                        ? row.name
                        : l10n.csvEmptyNamePlaceholder,
                    style: TextStyle(
                      color: hasErrors
                          ? STATUS_ERROR.withValues(alpha: 0.8)
                          : TEXT_PRIMARY,
                    ),
                  ),
                  subtitle: hasErrors
                      ? Text(
                          row.errors.join(', '),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: STATUS_ERROR.withValues(alpha: 0.7),
                              ),
                        )
                      : Text(
                          '${row.brand.isNotEmpty ? '${row.brand} · ' : ''}'
                          '${row.materialType.isNotEmpty ? '${row.materialType} · ' : ''}'
                          '${formatCurrencyValue(row.cost, currencySymbol: currencySettings.currencySymbol, currencyPosition: currencySettings.currencyPosition, currencySpacing: currencySettings.currencySpacing)}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: TEXT_TERTIARY),
                        ),
                  trailing: hasErrors
                      ? const Icon(Icons.error_outline, color: STATUS_ERROR)
                      : const Icon(
                          Icons.check_circle_outline,
                          color: STATUS_SUCCESS,
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
