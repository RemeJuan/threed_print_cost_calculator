import 'dart:convert';

import 'package:auto_backup_platform/auto_backup_platform.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/automatic_backup_task.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/backup_restore_service.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:workmanager/workmanager.dart';

final automaticBackupServiceProvider = Provider<AutomaticBackupService>((ref) {
  return AutomaticBackupService(ref);
});

final automaticBackupConfigProvider = FutureProvider<AutomaticBackupConfig?>((
  ref,
) {
  return ref.read(automaticBackupServiceProvider).readConfig();
});

class AutomaticBackupService {
  AutomaticBackupService(this.ref);
  final Ref ref;

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  Future<AutomaticBackupConfig?> readConfig() async {
    final raw = _prefs.getString(_configKey);
    if (raw == null) return null;
    try {
      return AutomaticBackupConfig.fromJson(
        jsonDecode(raw) as Map<String, Object?>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveConfig(AutomaticBackupConfig config) async {
    await _prefs.setString(_configKey, jsonEncode(config.toJson()));
    ref.invalidate(automaticBackupConfigProvider);
  }

  Future<void> clearRuntimeState() async {
    final config = await readConfig();
    if (config == null) return;
    await saveConfig(config.copyWith(enabled: false));
    await Workmanager().cancelByUniqueName(automaticBackupTaskUniqueName);
  }

  Future<void> schedule(AutomaticBackupConfig config) async {
    await saveConfig(config.copyWith(enabled: true));
    await _registerHeartbeat();
  }

  Future<void> reconcile(bool isPremium) async {
    final config = await readConfig();
    if (config == null) return;
    if (!isPremium) {
      await Workmanager().cancelByUniqueName(automaticBackupTaskUniqueName);
      return;
    }
    if (config.enabled) {
      await _registerHeartbeat();
    } else {
      await Workmanager().cancelByUniqueName(automaticBackupTaskUniqueName);
    }
  }

  Future<void> _registerHeartbeat() {
    return Workmanager().registerPeriodicTask(
      automaticBackupTaskUniqueName,
      automaticBackupTaskName,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      frequency: _heartbeatFrequency,
      initialDelay: _initialDelay,
    );
  }

  Future<bool> verifyDestination(AutomaticBackupConfig config) async {
    await AutoBackupPlatform().verifyDestination(
      accessToken: config.accessToken,
      displayLabel: config.displayLabel,
      fileName: autoBackupFileName,
    );
    return true;
  }

  Future<AutomaticBackupRunResult> runOnce({bool force = false}) async {
    final config = await readConfig();
    if (config == null || !config.enabled) {
      return AutomaticBackupRunResult.skipped;
    }
    final attemptAt = _nowIso();
    if (!force && !config.isDue(DateTime.now().toUtc())) {
      await saveConfig(
        config.copyWith(
          lastAttemptAt: attemptAt,
          lastResult: AutomaticBackupRunResult.skipped.value,
          lastErrorMessage: null,
        ),
      );
      return AutomaticBackupRunResult.skipped;
    }
    await saveConfig(
      config.copyWith(
        lastAttemptAt: attemptAt,
        lastResult: AutomaticBackupRunResult.skipped.value,
        lastErrorMessage: null,
      ),
    );
    try {
      final payload = await ref
          .read(backupRestoreServiceProvider)
          .exportBackupJson();
      final successAt = _nowIso();
      await AutoBackupPlatform().writeBackup(
        accessToken: config.accessToken,
        displayLabel: config.displayLabel,
        fileName: autoBackupFileName,
        contents: payload,
      );
      await saveConfig(
        config.copyWith(
          lastAttemptAt: attemptAt,
          lastSuccessAt: successAt,
          lastResult: AutomaticBackupRunResult.success.value,
          lastErrorMessage: null,
        ),
      );
      return AutomaticBackupRunResult.success;
    } catch (e) {
      await saveConfig(
        config.copyWith(
          lastAttemptAt: attemptAt,
          lastResult: AutomaticBackupRunResult.failure.value,
          lastErrorMessage: e.toString(),
        ),
      );
      return AutomaticBackupRunResult.failure;
    }
  }
}

String _nowIso() => DateTime.now().toUtc().toIso8601String();

enum AutomaticBackupRunResult {
  success('success'),
  failure('failure'),
  skipped('skipped');

  const AutomaticBackupRunResult(this.value);
  final String value;

  static AutomaticBackupRunResult? fromValue(String? value) {
    return switch (value) {
      'success' => success,
      'failure' => failure,
      'skipped' => skipped,
      _ => null,
    };
  }
}

enum AutomaticBackupCadence {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly');

  const AutomaticBackupCadence(this.value);
  final String value;

  static AutomaticBackupCadence fromValue(String? value) {
    return switch (value) {
      'weekly' => weekly,
      'monthly' => monthly,
      _ => daily,
    };
  }

  Duration get interval => switch (this) {
    daily => const Duration(days: 1),
    weekly => const Duration(days: 7),
    monthly => const Duration(days: 30),
  };
}

class AutomaticBackupConfig {
  const AutomaticBackupConfig({
    required this.enabled,
    required this.cadence,
    required this.accessToken,
    required this.displayLabel,
    required this.platform,
    this.lastAttemptAt,
    this.lastSuccessAt,
    this.lastResult,
    this.lastErrorMessage,
  });

  final bool enabled;
  final String cadence;
  final String accessToken;
  final String displayLabel;
  final String platform;
  final String? lastAttemptAt;
  final String? lastSuccessAt;
  final String? lastResult;
  final String? lastErrorMessage;

  AutomaticBackupConfig copyWith({
    bool? enabled,
    String? cadence,
    String? accessToken,
    String? displayLabel,
    String? platform,
    Object? lastAttemptAt = _noChange,
    Object? lastSuccessAt = _noChange,
    Object? lastResult = _noChange,
    Object? lastErrorMessage = _noChange,
  }) {
    return AutomaticBackupConfig(
      enabled: enabled ?? this.enabled,
      cadence: cadence ?? this.cadence,
      accessToken: accessToken ?? this.accessToken,
      displayLabel: displayLabel ?? this.displayLabel,
      platform: platform ?? this.platform,
      lastAttemptAt: identical(lastAttemptAt, _noChange)
          ? this.lastAttemptAt
          : lastAttemptAt as String?,
      lastSuccessAt: identical(lastSuccessAt, _noChange)
          ? this.lastSuccessAt
          : lastSuccessAt as String?,
      lastResult: identical(lastResult, _noChange)
          ? this.lastResult
          : lastResult as String?,
      lastErrorMessage: identical(lastErrorMessage, _noChange)
          ? this.lastErrorMessage
          : lastErrorMessage as String?,
    );
  }

  Map<String, Object?> toJson() => {
    'enabled': enabled,
    'cadence': cadence,
    'accessToken': accessToken,
    'displayLabel': displayLabel,
    'platform': platform,
    'lastAttemptAt': lastAttemptAt,
    'lastSuccessAt': lastSuccessAt,
    'lastResult': lastResult,
    'lastErrorMessage': lastErrorMessage,
  };

  static AutomaticBackupConfig fromJson(Map<String, Object?> json) {
    return AutomaticBackupConfig(
      enabled: json['enabled'] == true,
      cadence: AutomaticBackupCadence.fromValue(
        json['cadence']?.toString(),
      ).value,
      accessToken: json['accessToken']?.toString() ?? '',
      displayLabel: json['displayLabel']?.toString() ?? '',
      platform: json['platform']?.toString() ?? '',
      lastAttemptAt: json['lastAttemptAt']?.toString(),
      lastSuccessAt: json['lastSuccessAt']?.toString(),
      lastResult: AutomaticBackupRunResult.fromValue(
        json['lastResult']?.toString(),
      )?.value,
      lastErrorMessage: json['lastErrorMessage']?.toString(),
    );
  }

  AutomaticBackupCadence get cadenceValue =>
      AutomaticBackupCadence.fromValue(cadence);

  bool isDue(DateTime nowUtc) {
    final lastSuccess = DateTime.tryParse(lastSuccessAt ?? '');
    if (lastSuccess == null) return true;
    final nextRun = lastSuccess.add(cadenceValue.interval);
    return !nextRun.isAfter(nowUtc);
  }
}

const _configKey = 'automatic_backup_config';
const _heartbeatFrequency = Duration(hours: 12);
const _initialDelay = Duration(minutes: 15);
const _noChange = Object();
