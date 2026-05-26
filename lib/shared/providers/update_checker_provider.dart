import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:update_available/update_available.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_providers.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';

const String _updateCooldownUntilKey = 'update_prompt_cooldown_until';

class UpdatePromptInfo {
  const UpdatePromptInfo({
    required this.isAvailable,
    required this.currentVersion,
    required this.storeVersion,
    required this.showStoreVersion,
    required this.platform,
    required this.source,
    required this.shouldShow,
  });

  final bool isAvailable;
  final String currentVersion;
  final String? storeVersion;
  final bool showStoreVersion;
  final String platform;
  final String source;
  final bool shouldShow;
}

class UpdateCheckerState {
  const UpdateCheckerState._({required this.info, required this.cooldownUntil});

  const UpdateCheckerState.loading() : this._(info: null, cooldownUntil: null);

  final UpdatePromptInfo? info;
  final DateTime? cooldownUntil;

  bool get canShowPrompt => info?.shouldShow ?? false;
}

Future<bool> openAppStoreForPlatform({AppLogger? logger}) async {
  final url = switch (defaultTargetPlatform) {
    TargetPlatform.iOS => Uri.parse('https://apps.apple.com/app/id6444106268'),
    TargetPlatform.android => Uri.parse(
      'https://play.google.com/store/apps/details?id=com.threed_print_calculator',
    ),
    _ => Uri.parse('https://printcostcalc.app'),
  };
  if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
    return true;
  }
  if (await launchUrl(url, mode: LaunchMode.platformDefault)) {
    return true;
  }
  logger?.warn(
    AppLogCategory.ui,
    'Unable to open app store',
    context: {'platform': defaultTargetPlatform.name},
  );
  return false;
}

final updateCheckerProvider =
    AsyncNotifierProvider<UpdateCheckerNotifier, UpdateCheckerState>(
      UpdateCheckerNotifier.new,
    );

final updateAvailabilityOverrideProvider = StateProvider<Availability?>(
  (_) => null,
);

class UpdateCheckerNotifier extends AsyncNotifier<UpdateCheckerState> {
  UpdateCheckerNotifier();

  static const Duration cooldownDuration = Duration(days: 7);

  @override
  Future<UpdateCheckerState> build() async {
    ref.listen<int>(appRefreshProvider, (previous, next) {
      unawaited(refresh());
    });

    final prefs = ref.read(sharedPreferencesProvider);
    final cooldownUntil = _readCooldownUntil(prefs);
    final info = await _checkUpdate();
    final shouldShow = _shouldShow(info.isAvailable, cooldownUntil);
    final state = UpdateCheckerState._(
      info: UpdatePromptInfo(
        isAvailable: info.isAvailable,
        currentVersion: info.currentVersion,
        storeVersion: info.storeVersion,
        showStoreVersion: info.showStoreVersion,
        platform: info.platform,
        source: info.source,
        shouldShow: shouldShow,
      ),
      cooldownUntil: cooldownUntil,
    );
    return state;
  }

  Future<void> refresh() async => ref.invalidateSelf();

  void forceAvailable() {
    ref.read(updateAvailabilityOverrideProvider.notifier).state =
        const UpdateAvailable();
  }

  void forceUnavailable() {
    ref.read(updateAvailabilityOverrideProvider.notifier).state =
        const NoUpdateAvailable();
  }

  Future<void> dismissPrompt() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final until = DateTime.now().add(cooldownDuration);
    await prefs.setInt(_updateCooldownUntilKey, until.millisecondsSinceEpoch);
    ref.invalidateSelf();
  }

  Future<void> clearCooldown() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_updateCooldownUntilKey);
    ref.invalidateSelf();
  }

  DateTime? _readCooldownUntil(SharedPreferences prefs) {
    final millis = prefs.getInt(_updateCooldownUntilKey);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  bool _shouldShow(bool available, DateTime? cooldownUntil) {
    if (!available) return false;
    if (cooldownUntil == null) return true;
    return DateTime.now().isAfter(cooldownUntil);
  }

  Future<
    ({
      bool isAvailable,
      String currentVersion,
      String? storeVersion,
      bool showStoreVersion,
      String platform,
      String source,
    })
  >
  _checkUpdate() async {
    final platform = defaultTargetPlatform.name.toLowerCase();
    final packageInfo = await PackageInfo.fromPlatform();
    final Availability? override = ref.read(updateAvailabilityOverrideProvider);
    final availability = override ?? await _safeGetUpdateAvailability();
    final isAvailable = switch (availability) {
      UpdateAvailable() => true,
      NoUpdateAvailable() => false,
      UnknownAvailability() => false,
    };
    return (
      isAvailable: isAvailable,
      currentVersion: packageInfo.version,
      storeVersion: null,
      showStoreVersion: false,
      platform: platform,
      source: 'startup',
    );
  }

  Future<Availability> _safeGetUpdateAvailability() async {
    if (kIsWeb) return const UnknownAvailability();
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return const UnknownAvailability();
    }
    try {
      return await getUpdateAvailability();
    } catch (_) {
      return const UnknownAvailability();
    }
  }
}
