import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import 'backup_restore_file_write.dart'
    if (dart.library.io) 'backup_restore_file_write_io.dart';
import 'backup_restore_database_writer.dart';
import 'backup_restore_payload_parser.dart';
import 'backup_restore_settings_merge.dart';

const autoBackupFileName = '3d_print_cost_calculator_auto_backup.json';
const backupJsonMimeType = 'application/json';

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

class BackupRestoreResult {
  const BackupRestoreResult({this.skippedPremiumSettings = false});

  final bool skippedPremiumSettings;
}

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
        buildBackupShareParams(jsonText, fileName),
      );
      return fileName;
    }

    await SharePlus.instance.share(buildBackupShareParams(jsonText, fileName));
    return fileName;
  }

  @visibleForTesting
  static ShareParams buildBackupShareParams(String jsonText, String fileName) {
    return ShareParams(
      files: [
        XFile.fromData(
          utf8.encode(jsonText),
          name: fileName,
          mimeType: backupJsonMimeType,
        ),
      ],
      fileNameOverrides: [fileName],
    );
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

  Future<BackupRestoreResult> restoreBackupJson(String raw) async {
    final payload = parseBackupPayload(raw);
    return _restorePayload(payload);
  }

  Future<BackupRestoreResult> restoreBackupFromFile(XFile file) async {
    return restoreBackupJson(await file.readAsString());
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

  Future<BackupRestoreResult> _restorePayload(
    BackupRestorePayload payload,
  ) async {
    final restoredSettings = payload.settings;
    final printers = payload.printers;
    final materials = payload.materials;
    final history = payload.history;
    final historyRaw = payload.historyRaw;

    final currentSettings = await ref
        .read(settingsRepositoryProvider)
        .getSettings();
    final policy = ref.read(premiumAccessPolicyProvider);
    final settingsMerge = mergeBackupRestoreSettings(
      restored: restoredSettings,
      current: currentSettings,
      isPremium: policy.isPremium,
    );
    final settings = settingsMerge.settings;
    final skippedPremiumSettings = settingsMerge.skippedPremiumSettings;

    await _db.transaction((txn) async {
      await restoreBackupToDatabase(
        ref: ref,
        txn: txn,
        settings: settings,
        printers: printers,
        materials: materials,
        history: history,
        historyRaw: historyRaw,
      );
    });

    return BackupRestoreResult(skippedPremiumSettings: skippedPremiumSettings);
  }
}
