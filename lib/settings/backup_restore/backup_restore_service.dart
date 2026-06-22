import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:auto_backup_platform/auto_backup_platform.dart';
import 'package:share_plus/share_plus.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import 'backup_restore_file_write.dart'
    if (dart.library.io) 'backup_restore_file_write_io.dart';

const autoBackupFileName = '3d_print_cost_calculator_auto_backup.json';

Map<String, Object?> buildBackupPayload({
  required Map<String, Object?> settings,
  required List<Map<String, Object?>> printers,
  required List<Map<String, Object?>> materials,
  required List<Map<String, Object?>> history,
}) {
  return <String, Object?>{
    'version': 1,
    'schemaVersion': 1,
    'createdAt': DateTime.now().toUtc().toIso8601String(),
    'data': {
      'settings': settings,
      'printers': printers,
      'materials': materials,
      'history': history,
    },
  };
}

final backupRestoreServiceProvider = Provider<BackupRestoreService>(
  BackupRestoreService.new,
);

final autoBackupPlatformProvider = Provider<AutoBackupPlatform>((ref) {
  return AutoBackupPlatform();
});

class BackupRestoreService {
  BackupRestoreService(this.ref);
  final Ref ref;
  Database get _db => ref.read(databaseProvider);

  Future<String> exportBackup() async {
    final jsonText = await exportBackupJson();
    final date = DateTime.now().toUtc().toIso8601String().split('T').first;
    final fileName = '3d_print_cost_calculator_backup_$date.json';
    if (_isDesktopPlatform) {
      final saveLocation = await getSaveLocation(suggestedName: fileName);
      if (saveLocation == null) return '';
      await writeStringToFile(saveLocation.path, jsonText);
      return saveLocation.path;
    }

    if (kIsWeb) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(utf8.encode(jsonText), name: fileName)],
        ),
      );
      return fileName;
    }

    final platform = ref.read(autoBackupPlatformProvider);
    final destination = await platform.pickDestination();
    if (destination == null) return '';
    final label = destination['displayLabel'] as String? ?? '';
    await platform.writeBackup(
      accessToken: destination['accessToken'] as String,
      displayLabel: label,
      fileName: fileName,
      contents: jsonText,
    );
    return label;
  }

  bool get _isDesktopPlatform {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux => true,
      _ => false,
    };
  }

  Future<String> exportBackupJson() async {
    final payload = await _buildPayload();
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> restoreBackupJson(String raw) async {
    final payload = _parseAndValidate(raw);
    await _restorePayload(payload);
  }

  Future<void> restoreBackupFromFile(XFile file) async {
    await restoreBackupJson(await file.readAsString());
  }

  Future<Map<String, Object?>> _buildPayload() async {
    final settings = await ref.read(settingsRepositoryProvider).getSettings();
    final printers = await ref.read(printersRepositoryProvider).getPrinters();
    final materials = await ref
        .read(materialsRepositoryProvider)
        .getMaterials();
    final history = await ref.read(historyRepositoryProvider).getAllHistory();
    return buildBackupPayload(
      settings: settings.toMap(),
      printers: printers.map((e) => {'id': e.id, ...e.toMap()}).toList(),
      materials: materials.map((e) => {'id': e.id, ...e.toMap()}).toList(),
      history: history.map((e) => {'id': e.key, ...e.model.toMap()}).toList(),
    );
  }

  Map<String, Object?> _parseAndValidate(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) throw FormatException('Invalid backup payload');
    final map = decoded.map((k, v) => MapEntry(k.toString(), v));
    if (map['version'] != 1 || map['schemaVersion'] != 1) {
      throw FormatException('Unsupported backup version');
    }
    final data = map['data'];
    if (data is! Map) throw FormatException('Invalid backup data');
    return map;
  }

  Future<void> _restorePayload(Map<String, Object?> payload) async {
    final data = payload['data'] as Map;
    final settings = GeneralSettingsModel.fromMap(_mapOf(data['settings']));
    final printers = _parsePrinters(data['printers']);
    final materials = _parseMaterials(data['materials']);
    final historyRaw = _strictListOfMaps(data['history']);
    final history = historyRaw.map((e) {
      final id = e['id']?.toString() ?? '';
      if (id.trim().isEmpty) {
        throw FormatException('History entry missing required id');
      }
      return HistoryModel.fromMap(e);
    }).toList();

    await _db.transaction((txn) async {
      await _clearDb(txn);
      await _writeRestore(
        txn,
        settings,
        printers,
        materials,
        history,
        historyRaw,
      );
    });
  }

  Future<void> _clearDb(Transaction txn) async {
    for (final store in [
      StoreRef<String, Object?>.main(),
      stringMapStoreFactory.store(DBName.printers.name),
      stringMapStoreFactory.store(DBName.materials.name),
      StoreRef<Object?, Object?>(DBName.history.name),
      stringMapStoreFactory.store('printer_index'),
      stringMapStoreFactory.store('history_search_index'),
    ]) {
      await store.delete(txn);
    }
  }

  Future<void> _writeRestore(
    Transaction txn,
    GeneralSettingsModel settings,
    List<PrinterModel> printers,
    List<MaterialModel> materials,
    List<HistoryModel> history,
    List<Map<String, dynamic>> historyRaw,
  ) async {
    final settingsStore = StoreRef<String, Object?>.main();
    final printersStore = stringMapStoreFactory.store(DBName.printers.name);
    final materialsStore = stringMapStoreFactory.store(DBName.materials.name);
    final historyStore = StoreRef<Object?, Map<String, Object?>>(
      DBName.history.name,
    );
    final printerIndex = PrinterIndexHelpers.fromRef(ref);
    final historyIndex = HistorySearchIndexHelpers.fromRef(ref);

    await settingsStore.record(DBName.settings.name).put(txn, settings.toMap());
    for (final printer in printers) {
      await printersStore.record(printer.id).put(txn, printer.toMap());
    }
    for (final material in materials) {
      await materialsStore.record(material.id).put(txn, material.toMap());
    }
    final seenIds = <String>{};
    for (var i = 0; i < history.length; i++) {
      final item = history[i];
      final raw = historyRaw[i];
      final id = raw['id']?.toString().trim().isNotEmpty == true
          ? raw['id'].toString()
          : 'history_$i';
      if (!seenIds.add(id)) {
        throw FormatException('Duplicate history entry id: $id');
      }
      await historyStore.record(id).put(txn, item.toMap());
      if (item.printer.trim().isNotEmpty) {
        await printerIndex.addKeyInTransaction(txn, item.printer, id);
      }
      await historyIndex.addRecordInTransaction(
        txn: txn,
        name: item.name,
        printer: item.printer,
        recordKey: id,
      );
    }
  }

  Map<String, dynamic> _mapOf(Object? raw) =>
      (raw as Map).map((k, v) => MapEntry(k.toString(), v));
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

  List<Map<String, dynamic>> _strictListOfMaps(Object? raw) {
    final list = raw as List;
    return list.map((e) {
      if (e is! Map) {
        throw FormatException('Expected a Map, got ${e.runtimeType}');
      }
      return _mapOf(e);
    }).toList();
  }
}
