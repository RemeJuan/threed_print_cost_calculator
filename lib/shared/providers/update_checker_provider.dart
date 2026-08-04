import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_providers.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';

const String _updateCooldownUntilKey = 'update_prompt_cooldown_until';
const String _iosAppStoreId = '6444106268';
const String _androidPackageName = 'com.threed_print_calculator';
const String _storeCountryCode = 'US';

@immutable
class UpdateAvailabilityResult {
  const UpdateAvailabilityResult.available({
    this.storeVersion,
    this.showStoreVersion = false,
  }) : isAvailable = true;

  const UpdateAvailabilityResult.unavailable()
    : isAvailable = false,
      storeVersion = null,
      showStoreVersion = false;

  const UpdateAvailabilityResult.unknown()
    : isAvailable = false,
      storeVersion = null,
      showStoreVersion = false;

  final bool isAvailable;
  final String? storeVersion;
  final bool showStoreVersion;
}

typedef UpdateAvailabilityLookup =
    Future<UpdateAvailabilityResult> Function({
      required String currentVersion,
      required TargetPlatform platform,
    });

class StoreUpdateLookupService {
  StoreUpdateLookupService({required http.Client client, AppLogger? logger})
    : _client = client,
      _logger = logger;

  final http.Client _client;
  final AppLogger? _logger;

  static final RegExp _androidVersionPattern = RegExp(
    r'\[\[\["(\d+(?:\.\d+)+)"\]\],\[\[\[\d+\]\],\[\[\[\d+,"',
  );

  Future<UpdateAvailabilityResult> lookup({
    required String currentVersion,
    required TargetPlatform platform,
  }) async {
    final storeVersion = switch (platform) {
      TargetPlatform.iOS => await _fetchIosStoreVersion(),
      TargetPlatform.android => await _fetchAndroidStoreVersion(),
      _ => null,
    };

    if (storeVersion == null || storeVersion.isEmpty) {
      return const UpdateAvailabilityResult.unknown();
    }

    if (_isStoreVersionNewer(storeVersion, currentVersion)) {
      return UpdateAvailabilityResult.available(
        storeVersion: storeVersion,
        showStoreVersion: true,
      );
    }

    return const UpdateAvailabilityResult.unavailable();
  }

  Future<String?> _fetchIosStoreVersion() async {
    final uri = Uri.https('itunes.apple.com', '/lookup', {
      'id': _iosAppStoreId,
      'country': _storeCountryCode,
    });
    final response = await _get(uri);
    if (response == null) return null;

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final results = decoded['results'];
      if (results is! List || results.isEmpty) return null;
      final first = results.first;
      if (first is! Map<String, dynamic>) return null;
      final version = first['version'];
      return version is String && version.isNotEmpty ? version : null;
    } catch (error, stackTrace) {
      _logger?.warn(
        AppLogCategory.ui,
        'Unable to parse App Store update response',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<String?> _fetchAndroidStoreVersion() async {
    final uri = Uri.https('play.google.com', '/store/apps/details', {
      'id': _androidPackageName,
      'hl': 'en_US',
      'gl': _storeCountryCode,
    });
    final response = await _get(uri);
    if (response == null) return null;

    final match = _androidVersionPattern.firstMatch(response.body);
    if (match == null) {
      _logger?.warn(
        AppLogCategory.ui,
        'Unable to parse Play Store update response',
        context: {'uri': uri.toString()},
      );
      return null;
    }

    return match.group(1);
  }

  Future<http.Response?> _get(Uri uri) async {
    try {
      final response = await _client
          .get(
            uri,
            headers: const {
              'User-Agent':
                  'Mozilla/5.0 (compatible; 3DPrintCostCalculator/1.0)',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        _logger?.warn(
          AppLogCategory.ui,
          'Store update lookup returned non-success status',
          context: {'statusCode': response.statusCode, 'uri': uri.toString()},
        );
        return null;
      }

      return response;
    } catch (error, stackTrace) {
      _logger?.warn(
        AppLogCategory.ui,
        'Unable to check store update availability',
        context: {'uri': uri.toString()},
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  bool _isStoreVersionNewer(String storeVersion, String currentVersion) {
    final storeParts = _parseVersionParts(storeVersion);
    final currentParts = _parseVersionParts(currentVersion);
    final length = math.max(storeParts.length, currentParts.length);
    for (var index = 0; index < length; index++) {
      final storePart = index < storeParts.length ? storeParts[index] : 0;
      final currentPart = index < currentParts.length ? currentParts[index] : 0;
      if (storePart > currentPart) return true;
      if (storePart < currentPart) return false;
    }
    return false;
  }

  List<int> _parseVersionParts(String version) {
    final normalized = version.split('+').first.split('-').first.trim();
    return normalized
        .split('.')
        .map((segment) => int.tryParse(segment) ?? 0)
        .toList(growable: false);
  }
}

final updateLookupHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final updateAvailabilityLookupProvider = Provider<UpdateAvailabilityLookup>((
  ref,
) {
  final service = StoreUpdateLookupService(
    client: ref.watch(updateLookupHttpClientProvider),
    logger: ref.watch(appLoggerProvider),
  );
  return ({required String currentVersion, required TargetPlatform platform}) {
    return service.lookup(currentVersion: currentVersion, platform: platform);
  };
});

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

final updateAvailabilityOverrideProvider =
    StateProvider<UpdateAvailabilityResult?>((_) => null);

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
        const UpdateAvailabilityResult.available();
  }

  void forceUnavailable() {
    ref.read(updateAvailabilityOverrideProvider.notifier).state =
        const UpdateAvailabilityResult.unavailable();
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
    final UpdateAvailabilityResult? override = ref.read(
      updateAvailabilityOverrideProvider,
    );
    final availability = override ?? await _safeGetUpdateAvailability();
    return (
      isAvailable: availability.isAvailable,
      currentVersion: packageInfo.version,
      storeVersion: availability.storeVersion,
      showStoreVersion: availability.showStoreVersion,
      platform: platform,
      source: 'startup',
    );
  }

  Future<UpdateAvailabilityResult> _safeGetUpdateAvailability() async {
    if (kIsWeb) return const UpdateAvailabilityResult.unknown();
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return const UpdateAvailabilityResult.unknown();
    }
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return await ref
          .read(updateAvailabilityLookupProvider)
          .call(
            currentVersion: packageInfo.version,
            platform: defaultTargetPlatform,
          );
    } catch (_) {
      return const UpdateAvailabilityResult.unknown();
    }
  }
}
