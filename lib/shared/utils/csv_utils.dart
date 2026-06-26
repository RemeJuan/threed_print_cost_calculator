import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_generation.dart';
import 'package:threed_print_cost_calculator/shared/utils/xlsx_export.dart';

export 'csv_generation.dart';

Future<String> writeCsvToFile(String csv) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/3d_print_history.csv');
  await file.writeAsString(csv);
  return file.path;
}

Future<void> exportCSVFile(
  List<HistoryModel> items, {
  required String csvHeader,
  required String shareText,
}) async {
  final csv = generateCsv(items, csvHeader);
  final path = await writeCsvToFile(csv);
  await SharePlus.instance.share(
    ShareParams(files: [XFile(path)], text: shareText),
  );
}

enum ExportRange { all, last7Days, last30Days }

class CsvUtils {
  final Ref ref;
  CsvUtils(this.ref);
  String generateCsvForItems(List<HistoryModel> items, String csvHeader) =>
      generateCsv(items, csvHeader);
  Future<String> writeCsvFileToDisk(String csv) => writeCsvToFile(csv);
  Future<void> exportCsvForItems(
    List<HistoryModel> items, {
    required String csvHeader,
    required String shareText,
  }) => exportCSVFile(items, csvHeader: csvHeader, shareText: shareText);
  Future<List<HistoryModel>> queryHistory(
    ExportRange range, {
    DateTime? now,
  }) async {
    final referenceNow = (now ?? DateTime.now()).toUtc();
    var items = await ref.read(historyRepositoryProvider).getAllHistory();
    if (range != ExportRange.all) {
      final days = range == ExportRange.last7Days ? 7 : 30;
      final cutoff = referenceNow.subtract(Duration(days: days));
      items = items.where((entry) {
        final dt = entry.model.date.toUtc();
        return dt.isAtSameMomentAs(cutoff) || dt.isAfter(cutoff);
      }).toList();
    }
    return items.map((entry) => entry.model).toList();
  }

  Future<void> exportForRange(
    ExportRange range, {
    required String csvHeader,
    required String shareText,
  }) async {
    final items = await queryHistory(range);
    await exportCSVFile(items, csvHeader: csvHeader, shareText: shareText);
  }

  Future<void> exportMixedHistoryForRange(
    ExportRange range, {
    required String shareText,
  }) async {
    final policy = ref.read(premiumAccessPolicyProvider);
    if (!policy.bulkHistoryExport().allowed) return;
    final items = await queryHistory(range);
    final path = await generateMixedHistoryXlsx(items);
    await shareXlsxFile(path, shareText);
  }

  Future<void> exportBatchQuote(
    HistoryModel item, {
    required String shareText,
  }) async {
    final policy = ref.read(premiumAccessPolicyProvider);
    if (!policy.batchExport().allowed) return;
    final path = await generateBatchQuoteXlsx(item);
    await shareXlsxFile(path, shareText);
  }
}

final csvUtilsProvider = Provider<CsvUtils>((ref) => CsvUtils(ref));
