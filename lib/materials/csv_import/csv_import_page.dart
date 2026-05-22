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
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';

const _csvHeader =
    'name,brand,material_type,color,color_hex,spool_weight,'
    'remaining_weight,spool_cost,notes';

const _sampleRow1 = 'PLA Pro+,Sunlu,PLA,Black,,1000,950,24.99,';
const _sampleRow2 = 'PETG Black,Overture,PETG,White,,1000,950,24.99,';

class CsvImportPage extends ConsumerStatefulWidget {
  const CsvImportPage({super.key});

  @override
  ConsumerState<CsvImportPage> createState() => _CsvImportPageState();
}

class _CsvImportPageState extends ConsumerState<CsvImportPage> {
  List<_ImportRow> _rows = [];
  bool _imported = false;
  AppLocalizations? _l10n;

  String get _csvTemplate => '$_csvHeader\n$_sampleRow1\n$_sampleRow2';

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
      _parseCsv(content);
    } catch (e) {
      if (!mounted) return;
      BotToast.showText(text: _l10n!.csvReadError);
    }
  }

  void _parseCsv(String content) {
    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return;

    final headers = _parseCsvLine(lines[0]);
    final columnIndex = <String, int>{};
    for (var i = 0; i < headers.length; i++) {
      columnIndex[headers[i].toLowerCase().trim()] = i;
    }

    final rows = <_ImportRow>[];
    for (var i = 1; i < lines.length; i++) {
      final values = _parseCsvLine(lines[i]);
      rows.add(_parseRow(values, columnIndex, i));
    }

    setState(() {
      _rows = rows;
      _imported = true;
    });
  }

  _ImportRow _parseRow(
    List<String> values,
    Map<String, int> colIndex,
    int lineNumber,
  ) {
    String val(String col) {
      final idx = colIndex[col];
      if (idx == null || idx >= values.length) return '';
      return values[idx].trim();
    }

    final name = val('name');
    final brand = val('brand');
    final materialType = val('material_type');
    final color = val('color');
    final colorHex = val('color_hex');
    final spoolWeightStr = val('spool_weight');
    final remainingWeightStr = val('remaining_weight');
    final costStr = val('spool_cost');
    final notes = val('notes');

    final errors = <String>[];
    if (name.isEmpty) errors.add(_l10n!.csvNameRequiredError);
    if (color.isEmpty) errors.add(_l10n!.csvColorRequiredError);

    final spoolWeight = double.tryParse(spoolWeightStr) ?? 0;
    if (spoolWeightStr.isEmpty) {
      errors.add(_l10n!.csvSpoolWeightRequiredError);
    } else if (spoolWeight <= 0) {
      errors.add(_l10n!.csvSpoolWeightPositiveError);
    }

    final cost = double.tryParse(costStr) ?? 0;
    if (costStr.isEmpty) {
      errors.add(_l10n!.csvCostRequiredError);
    } else if (cost <= 0) {
      errors.add(_l10n!.csvCostPositiveError);
    }

    final remainingWeight = double.tryParse(remainingWeightStr) ?? spoolWeight;

    return _ImportRow(
      lineNumber: lineNumber,
      name: name,
      brand: brand,
      materialType: materialType,
      color: color,
      colorHex: colorHex,
      spoolWeight: spoolWeight,
      remainingWeight: remainingWeight,
      cost: cost,
      notes: notes,
      errors: errors,
    );
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result;
  }

  Future<void> _importValid() async {
    final valid = _rows.where((r) => r.errors.isEmpty).toList();
    final failed = _rows.length - valid.length;
    if (valid.isEmpty) {
      AppAnalytics.safeLog(
        () =>
            AppAnalytics.csvImportCompleted(rowsSuccess: 0, rowsFailed: failed),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final repo = ref.read(materialsRepositoryProvider);
    var imported = 0;
    final failedRows = <_ImportRow>[];

    for (final row in valid) {
      final material = MaterialModel(
        id: '',
        name: row.name,
        cost: row.cost.toString(),
        color: row.color,
        weight: row.spoolWeight.toString(),
        archived: false,
        autoDeductEnabled:
            row.remainingWeight > 0 && row.remainingWeight != row.spoolWeight,
        originalWeight: row.spoolWeight,
        remainingWeight: row.remainingWeight,
        brand: row.brand,
        materialType: row.materialType,
        colorHex: row.colorHex,
        notes: row.notes,
      );
      try {
        await repo.saveMaterial(material);
        imported++;
      } catch (error, stackTrace) {
        failedRows.add(row);
        debugPrint(
          'CSV import failed for row ${row.lineNumber} '
          '(name: ${row.name}): $error',
        );
        debugPrint(stackTrace.toString());
      }
    }

    AppAnalytics.safeLog(
      () => AppAnalytics.csvImportCompleted(
        rowsSuccess: imported,
        rowsFailed: failed + failedRows.length,
      ),
    );

    if (!mounted) return;
    BotToast.showText(text: _l10n!.csvImportSuccessMessage(imported));
    navigator.pop();
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
          Icon(Icons.upload_file, size: 64, color: Colors.white38),
          const SizedBox(height: 16),
          Text(
            l10n.csvImportIntro,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
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
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.csvPreviewSummary(_rows.length, valid, invalid),
            style: const TextStyle(color: Colors.white70),
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
                    ? Colors.red.withAlpha(15)
                    : const Color.fromRGBO(26, 28, 43, 1),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: ListTile(
                  title: Text(
                    row.name.isNotEmpty
                        ? row.name
                        : l10n.csvEmptyNamePlaceholder,
                    style: TextStyle(
                      color: hasErrors ? Colors.red[300] : Colors.white,
                    ),
                  ),
                  subtitle: hasErrors
                      ? Text(
                          row.errors.join(', '),
                          style: TextStyle(
                            color: Colors.red[200],
                            fontSize: 12,
                          ),
                        )
                      : Text(
                          '${row.brand.isNotEmpty ? '${row.brand} · ' : ''}'
                          '${row.materialType.isNotEmpty ? '${row.materialType} · ' : ''}'
                          '${formatCurrencyValue(row.cost, currencySymbol: currencySettings.currencySymbol, currencyPosition: currencySettings.currencyPosition, currencySpacing: currencySettings.currencySpacing)}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                  trailing: hasErrors
                      ? const Icon(Icons.error_outline, color: Colors.red)
                      : const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
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

class _ImportRow {
  final int lineNumber;
  final String name;
  final String brand;
  final String materialType;
  final String color;
  final String colorHex;
  final double spoolWeight;
  final double remainingWeight;
  final double cost;
  final String notes;
  final List<String> errors;

  _ImportRow({
    required this.lineNumber,
    required this.name,
    required this.brand,
    required this.materialType,
    required this.color,
    required this.colorHex,
    required this.spoolWeight,
    required this.remainingWeight,
    required this.cost,
    required this.notes,
    required this.errors,
  });
}
