import 'dart:convert';

import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

class BackupRestorePayload {
  const BackupRestorePayload({
    required this.settings,
    required this.printers,
    required this.materials,
    required this.history,
    required this.historyRaw,
  });

  final GeneralSettingsModel settings;
  final List<PrinterModel> printers;
  final List<MaterialModel> materials;
  final List<HistoryModel> history;
  final List<Map<String, dynamic>> historyRaw;
}

BackupRestorePayload parseBackupPayload(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map) throw FormatException('Invalid backup payload');
  final map = decoded.map((k, v) => MapEntry(k.toString(), v));
  if (map['version'] != 1 || map['schemaVersion'] != 1) {
    throw FormatException('Unsupported backup version');
  }
  final data = map['data'];
  if (data is! Map) throw FormatException('Invalid backup data');

  final typedData = _mapOf(data);
  final restoredSettings = GeneralSettingsModel.fromMap(
    _mapOf(typedData['settings']),
  );
  final printers = _parsePrinters(typedData['printers']);
  final materials = _parseMaterials(typedData['materials']);
  final historyRaw = _strictListOfMaps(typedData['history']);
  final history = historyRaw.map((e) {
    final id = e['id']?.toString() ?? '';
    if (id.trim().isEmpty) {
      throw FormatException('History entry missing required id');
    }
    return HistoryModel.fromMap(e);
  }).toList();

  return BackupRestorePayload(
    settings: restoredSettings,
    printers: printers,
    materials: materials,
    history: history,
    historyRaw: historyRaw,
  );
}

Map<String, dynamic> _mapOf(Object? raw) {
  if (raw is! Map) {
    throw FormatException('Expected a Map, got ${raw?.runtimeType ?? 'null'}');
  }
  return raw.map((k, v) => MapEntry(k.toString(), v));
}

List<Map<String, dynamic>> _strictListOfMaps(Object? raw) {
  if (raw is! List) {
    throw FormatException('Expected a List, got ${raw?.runtimeType ?? 'null'}');
  }
  return raw.map((e) {
    if (e is! Map) {
      throw FormatException('Expected a Map, got ${e.runtimeType}');
    }
    return _mapOf(e);
  }).toList();
}

List<PrinterModel> _parsePrinters(Object? raw) {
  final items = _strictListOfMaps(raw);
  final seenIds = <String>{};
  return items.map((e) {
    final id = e['id']?.toString() ?? '';
    if (id.trim().isEmpty) {
      throw FormatException('Printer entry missing required id');
    }
    if (!seenIds.add(id)) {
      throw FormatException('Duplicate printer entry id: $id');
    }
    return PrinterModel.fromMap(e, id);
  }).toList();
}

List<MaterialModel> _parseMaterials(Object? raw) {
  final items = _strictListOfMaps(raw);
  final seenIds = <String>{};
  return items.map((e) {
    final id = e['id']?.toString() ?? '';
    if (id.trim().isEmpty) {
      throw FormatException('Material entry missing required id');
    }
    if (!seenIds.add(id)) {
      throw FormatException('Duplicate material entry id: $id');
    }
    return MaterialModel.fromMap(e, id);
  }).toList();
}
