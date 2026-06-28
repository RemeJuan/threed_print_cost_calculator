import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_file_export.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_generation.dart';
import 'package:threed_print_cost_calculator/shared/utils/xlsx_export.dart';

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
