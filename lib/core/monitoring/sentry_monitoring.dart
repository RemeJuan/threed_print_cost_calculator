import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

const _sentryBuildName = String.fromEnvironment('FLUTTER_BUILD_NAME');
const _sentryBuildNumber = String.fromEnvironment('FLUTTER_BUILD_NUMBER');
const _fallbackSentryRelease = 'threed_print_cost_calculator@dev';
const _fallbackSentryDist = 'dev';

Future<void> initSentry() async {
  try {
    final identity = await resolveSentryReleaseIdentity();
    await SentryFlutter.init(
      (options) => configureSentryOptions(options, identity: identity),
    );
  } catch (_) {
    // Monitoring must never block or crash app startup.
  }
}

/// Configures Sentry with startup-safe defaults.
void configureSentryOptions(
  SentryFlutterOptions options, {
  SentryReleaseIdentity? identity,
}) {
  options.dsn =
      'https://05f1c49136e3510a42d66d4fd9b511d5@o4511607690756096.ingest.de.sentry.io/4511607696326736';
  options.sendDefaultPii = false;
  options.environment = kReleaseMode ? 'release' : 'debug';
  if (kReleaseMode) {
    options.tracesSampleRate = 0.1;
  }
  options.beforeSend = _beforeSend;
  if (!kReleaseMode && options.platform.isIOS) {
    options.autoInitializeNativeSdk = false;
  }

  final resolved = identity ?? _compileTimeReleaseIdentity;
  options.release = resolved.release;
  options.dist = resolved.dist;
}

class SentryReleaseIdentity {
  const SentryReleaseIdentity(this.release, this.dist);

  final String release;
  final String dist;
}

const _compileTimeReleaseIdentity = SentryReleaseIdentity(
  _sentryBuildName == ''
      ? _fallbackSentryRelease
      : 'threed_print_cost_calculator@$_sentryBuildName+'
            '${_sentryBuildNumber == '' ? _fallbackSentryDist : _sentryBuildNumber}',
  _sentryBuildNumber == '' ? _fallbackSentryDist : _sentryBuildNumber,
);

Future<SentryReleaseIdentity> resolveSentryReleaseIdentity({
  Future<PackageInfo> Function()? loadPackageInfo,
  String buildName = _sentryBuildName,
  String buildNumber = _sentryBuildNumber,
}) async {
  if (buildName.isNotEmpty && buildNumber.isNotEmpty) {
    return SentryReleaseIdentity(
      'threed_print_cost_calculator@$buildName+$buildNumber',
      buildNumber,
    );
  }

  try {
    final info = await (loadPackageInfo ?? PackageInfo.fromPlatform)();
    final resolvedBuildName = buildName.isEmpty ? info.version : buildName;
    final resolvedBuildNumber = buildNumber.isEmpty
        ? info.buildNumber
        : buildNumber;
    if (resolvedBuildName.isEmpty || resolvedBuildNumber.isEmpty) {
      return _compileTimeReleaseIdentity;
    }
    return SentryReleaseIdentity(
      'threed_print_cost_calculator@$resolvedBuildName+$resolvedBuildNumber',
      resolvedBuildNumber,
    );
  } catch (_) {
    return _compileTimeReleaseIdentity;
  }
}

SentryEvent? _beforeSend(SentryEvent event, Hint hint) {
  event.request = null;
  event.user = null;
  event.breadcrumbs = event.breadcrumbs
      ?.map(_scrubBreadcrumb)
      .whereType<Breadcrumb>()
      .toList(growable: false);
  _scrubContexts(event.contexts);
  final exceptions = event.exceptions;
  if (exceptions != null) {
    for (final exception in exceptions) {
      exception.value = _sanitizeString(exception.value);
    }
  }
  return event;
}

Breadcrumb? _scrubBreadcrumb(Breadcrumb breadcrumb) {
  final message = _sanitizeString(breadcrumb.message);
  final data = _scrubMap(breadcrumb.data);
  if ((message?.isEmpty ?? true) && (data?.isEmpty ?? true)) return null;
  breadcrumb.message = message;
  breadcrumb.data = data;
  return breadcrumb;
}

Contexts _scrubContexts(Contexts contexts) {
  for (final entry in contexts.entries.toList(growable: false)) {
    contexts[entry.key] = _scrubValue(entry.value);
  }
  return contexts;
}

Map<String, dynamic>? _scrubMap(Map<String, dynamic>? values) {
  if (values == null) return null;
  return Map<String, dynamic>.fromEntries(
    values.entries
        .where((entry) {
          final key = entry.key.toLowerCase();
          return !key.contains('path') &&
              !key.contains('file_name') &&
              !key.contains('filename') &&
              !key.contains('content');
        })
        .map((entry) => MapEntry(entry.key, _scrubValue(entry.value))),
  );
}

Object? _scrubValue(Object? value) {
  if (value is Map<String, dynamic>) return _scrubMap(value);
  if (value is Map) {
    return Map<String, dynamic>.fromEntries(
      value.entries
          .where((entry) => entry.key is String)
          .map(
            (entry) => MapEntry(entry.key as String, _scrubValue(entry.value)),
          ),
    );
  }
  if (value is List) {
    return value.map(_scrubValue).toList(growable: false);
  }
  if (value is String) return _sanitizeString(value);
  return value;
}

String? _sanitizeString(String? value) {
  if (value == null || value.isEmpty) return value;
  if (!_looksSensitive(value)) return value;
  return value
      .replaceAll(RegExp(r'([A-Za-z]:)?[\\/][^\s]+'), '[path]')
      .replaceAll(RegExp(r'[^\s]+\.[A-Za-z0-9]+'), '[file]');
}

bool _looksSensitive(String? value) {
  if (value == null || value.isEmpty) return false;
  return value.contains('/') ||
      value.contains('\\') ||
      value.contains('.gcode');
}
