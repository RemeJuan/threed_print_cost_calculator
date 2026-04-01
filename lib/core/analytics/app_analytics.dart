import 'dart:async';
import 'dart:convert';

import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';

import 'analytics_service.dart';
import 'firebase_analytics_service.dart';

class AppAnalytics {
  static AppLogger logger = AppLogger(
    sink: const DebugPrintAppLogSink(),
    config: const AppLoggerConfig.defaults(),
  );

  // Expose a service that can be replaced in tests. By default use the real
  // Firebase-backed implementation. Tests should override this with a
  // no-op or a mock to prevent touching Firebase.
  static AnalyticsService service = FirebaseAnalyticsService();

  static Map<String, Object>? _sanitizeParams(Map<String, Object?>? params) {
    if (params == null) return null;

    Object? sanitizeValue(Object? v) {
      if (v == null) return null;
      if (v is bool) return v ? 1 : 0; // convert bool -> num
      if (v is num) return v;
      if (v is String) return v;
      if (v is Map) {
        final Map<String, Object?> m = {};
        v.forEach((key, value) {
          m[key.toString()] = sanitizeValue(value);
        });
        return jsonEncode(m);
      }
      if (v is Iterable) {
        final list = v.map((e) => sanitizeValue(e)).toList();
        return jsonEncode(list);
      }
      // Fallback to string representation for other types
      return v.toString();
    }

    final sanitized = <String, Object>{};
    params.forEach((key, value) {
      final s = sanitizeValue(value);
      if (s == null) return; // omit null values
      // Ensure final values are either num or String
      if (s is num || s is String) {
        sanitized[key] = s;
      } else {
        // As a final fallback stringify
        sanitized[key] = s.toString();
      }
    });

    return sanitized;
  }

  static Future<void> log(String event, {Map<String, Object?>? params}) async {
    try {
      final sanitized = _sanitizeParams(params);
      await service.logEvent(event, params: sanitized);
    } catch (e, st) {
      logger.warn(
        AppLogCategory.ui,
        'Analytics log failed',
        context: {'event': event},
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Calculator usage
  static Future<void> calculationCreated({
    required int materialCount,
    required bool hasFailureRisk,
    required bool hasLabour,
  }) {
    // Firebase Analytics parameter values must be String or num. Don't pass
    // Dart bools directly (they cause an assertion). Encode booleans as 0/1.
    return log(
      'calculation_created',
      params: {
        'material_count': materialCount,
        'has_failure_risk': hasFailureRisk ? 1 : 0,
        'has_labour_cost': hasLabour ? 1 : 0,
      },
    );
  }

  /// Multi-material usage
  static Future<void> multiMaterialUsed(int materialCount) {
    return log(
      'multi_material_used',
      params: {'material_count': materialCount},
    );
  }

  /// Printer management
  static Future<void> printerProfileCreated() {
    return log('printer_profile_created');
  }

  /// Material creation
  static Future<void> materialCreated() {
    return log('material_created');
  }

  /// Export events
  static Future<void> exportUsed(String exportType) {
    return log('export_used', params: {'type': exportType});
  }

  /// Paywall exposure
  static Future<void> paywallShown(String triggerFeature) {
    return log('paywall_shown', params: {'feature': triggerFeature});
  }

  /// Locked premium feature tapped
  static Future<void> premiumFeatureTapped(String feature) {
    return log('premium_feature_tapped', params: {'feature': feature});
  }

  static void safeLog(Future<void> Function() callback) {
    unawaited(callback());
  }
}
