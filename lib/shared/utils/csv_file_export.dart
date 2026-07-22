import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_generation.dart';

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
