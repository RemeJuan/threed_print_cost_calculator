import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppMonitoring {
  AppMonitoring._();

  static Future<void> init(Future<void> Function() appRunner) async {
    final packageInfo = await PackageInfo.fromPlatform();
    await SentryFlutter.init((options) {
      options.dsn =
          'https://05f1c49136e3510a42d66d4fd9b511d5@o4511607690756096.ingest.de.sentry.io/4511607696326736';
      options.sendDefaultPii = false;
      options.release = '${packageInfo.version}+${packageInfo.buildNumber}';
      options.environment = kReleaseMode ? 'release' : 'debug';
      options.beforeSend = _beforeSend;
    }, appRunner: appRunner);
  }

  static SentryEvent? _beforeSend(SentryEvent event, Hint hint) {
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

  static Breadcrumb? _scrubBreadcrumb(Breadcrumb breadcrumb) {
    final message = _sanitizeString(breadcrumb.message);
    final data = _scrubMap(breadcrumb.data);
    if ((message?.isEmpty ?? true) && (data?.isEmpty ?? true)) return null;
    breadcrumb.message = message;
    breadcrumb.data = data;
    return breadcrumb;
  }

  static Contexts _scrubContexts(Contexts contexts) {
    for (final entry in contexts.entries.toList(growable: false)) {
      contexts[entry.key] = _scrubValue(entry.value);
    }
    return contexts;
  }

  static Map<String, dynamic>? _scrubMap(Map<String, dynamic>? values) {
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

  static Object? _scrubValue(Object? value) {
    if (value is Map<String, dynamic>) return _scrubMap(value);
    if (value is Map) {
      return Map<String, dynamic>.fromEntries(
        value.entries
            .where((entry) => entry.key is String)
            .map(
              (entry) =>
                  MapEntry(entry.key as String, _scrubValue(entry.value)),
            ),
      );
    }
    if (value is List) {
      return value.map(_scrubValue).toList(growable: false);
    }
    if (value is String) return _sanitizeString(value);
    return value;
  }

  static String? _sanitizeString(String? value) {
    if (value == null || value.isEmpty) return value;
    if (!_looksSensitive(value)) return value;
    return value
        .replaceAll(RegExp(r'([A-Za-z]:)?[\\/][^\s]+'), '[path]')
        .replaceAll(RegExp(r'[^\s]+\.[A-Za-z0-9]+'), '[file]');
  }

  static bool _looksSensitive(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.contains('/') ||
        value.contains('\\') ||
        value.contains('.gcode');
  }
}
