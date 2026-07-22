import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_generation.dart';

const _appCsvRetention = Duration(days: 1);

Future<void> cleanupStaleMaterialExportFiles() =>
    _cleanupStaleCsvFiles('materials_');

Future<void> cleanupStaleMaterialTemplateFiles() =>
    _cleanupStaleCsvFiles('material_template_');

Future<void> _cleanupStaleCsvFiles(String prefix) async {
  try {
    final directory = await getTemporaryDirectory();
    final cutoff = DateTime.now().subtract(_appCsvRetention);
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File ||
          !entity.uri.pathSegments.last.startsWith(prefix) ||
          !entity.path.endsWith('.csv')) {
        continue;
      }
      try {
        if ((await entity.stat()).modified.isBefore(cutoff)) {
          await entity.delete();
        }
      } catch (_) {}
    }
  } catch (_) {}
}

Future<String> writeCsvToFile(String csv, {String? fileName}) async {
  final directory = await getTemporaryDirectory();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final file = File(
    '${directory.path}/${fileName ?? '3d_print_history_$timestamp.csv'}',
  );
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
