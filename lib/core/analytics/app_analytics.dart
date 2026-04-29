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

  static bool _gcodeImportTriggeredThisSession = false;
  static DateTime? _gcodeImportOpenedAt;
  static String _gcodeImportSlicer = 'unknown';
  static bool _gcodeImportHasPreview = false;
  static String _gcodeImportParseStatus = 'unknown';
  static String _gcodeImportFileSizeBucket = 'unknown';

  static void resetGcodeImportTrackingForTests() {
    _gcodeImportTriggeredThisSession = false;
    _gcodeImportOpenedAt = null;
    _gcodeImportSlicer = 'unknown';
    _gcodeImportHasPreview = false;
    _gcodeImportParseStatus = 'unknown';
    _gcodeImportFileSizeBucket = 'unknown';
  }

  static String fileSizeBucket(int bytes) {
    if (bytes < 1 * 1024 * 1024) return '<1MB';
    if (bytes < 5 * 1024 * 1024) return '1-5MB';
    if (bytes < 20 * 1024 * 1024) return '5-20MB';
    return '20MB+';
  }

  static String slicerValue(String? slicer) {
    if (slicer == null || slicer.isEmpty) return 'unknown';
    return slicer;
  }

  static void _startGcodeImportFlow() {
    _gcodeImportOpenedAt = DateTime.now();
    _gcodeImportSlicer = 'unknown';
    _gcodeImportHasPreview = false;
    _gcodeImportParseStatus = 'unknown';
    _gcodeImportFileSizeBucket = 'unknown';
  }

  static int? _gcodeTimeToValueMs() {
    final openedAt = _gcodeImportOpenedAt;
    if (openedAt == null) return null;
    return DateTime.now().difference(openedAt).inMilliseconds;
  }

  static Map<String, Object?> _gcodeImportParams({String? entryPoint}) {
    return {
      'slicer': _gcodeImportSlicer,
      'has_preview': _gcodeImportHasPreview ? 1 : 0,
      'parse_status': _gcodeImportParseStatus,
      'file_size_bucket': _gcodeImportFileSizeBucket,
      ...?(entryPoint == null ? null : {'entry_point': entryPoint}),
    };
  }

  static void _setGcodeContext({
    String? slicer,
    bool? hasPreview,
    String? parseStatus,
    String? fileSizeBucket,
  }) {
    if (slicer != null) _gcodeImportSlicer = slicer;
    if (hasPreview != null) _gcodeImportHasPreview = hasPreview;
    if (parseStatus != null) _gcodeImportParseStatus = parseStatus;
    if (fileSizeBucket != null) _gcodeImportFileSizeBucket = fileSizeBucket;
  }

  static String _entryPointValue({String defaultValue = 'manual'}) {
    return _gcodeImportTriggeredThisSession ? 'gcode_import' : defaultValue;
  }

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
    required bool hasPricing,
  }) {
    // Firebase Analytics parameter values must be String or num. Don't pass
    // Dart bools directly (they cause an assertion). Encode booleans as 0/1.
    return log(
      'calculation_created',
      params: {
        'material_count': materialCount,
        'has_failure_risk': hasFailureRisk ? 1 : 0,
        'has_labour_cost': hasLabour ? 1 : 0,
        'has_pricing': hasPricing ? 1 : 0,
      },
    );
  }

  static Future<void> pricingSettingsChanged({
    required num markupPercent,
    required num setupFee,
    required String roundingMode,
  }) {
    return log(
      'pricing_settings_changed',
      params: {
        'pricing_enabled':
            (markupPercent > 0 || setupFee > 0 || roundingMode != 'none') ? 1 : 0,
        'markup_percent': markupPercent,
        'setup_fee': setupFee,
        'rounding_mode': roundingMode,
      },
    );
  }

  static Future<void> pricingOverrideUsed({
    required String field,
    required bool hasOverrides,
  }) {
    return log(
      'pricing_override_used',
      params: {
        'field': field,
        'has_overrides': hasOverrides ? 1 : 0,
      },
    );
  }

  static Future<void> pricingSaved({
    required bool hasPricing,
    required bool usedOverrides,
    required String roundingMode,
  }) {
    return log(
      'pricing_saved',
      params: {
        'has_pricing': hasPricing ? 1 : 0,
        'used_overrides': usedOverrides ? 1 : 0,
        'rounding_mode': roundingMode,
      },
    );
  }

  static Future<void> pricingRoundingUsed({required String roundingMode}) {
    return log(
      'pricing_rounding_used',
      params: {'rounding_mode': roundingMode},
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
  static Future<void> paywallViewed(
    String triggerFeature, {
    String defaultEntryPoint = 'manual',
  }) {
    return log(
      'paywall_viewed',
      params: {
        'feature': triggerFeature,
        'entry_point': _entryPointValue(defaultValue: defaultEntryPoint),
      },
    );
  }

  static Future<void> paywallShown(String triggerFeature) {
    return paywallViewed(triggerFeature);
  }

  static Future<void> purchaseCompleted(
    String source, {
    String defaultEntryPoint = 'manual',
  }) {
    return log(
      'purchase_completed',
      params: {
        'source': source,
        'entry_point': _entryPointValue(defaultValue: defaultEntryPoint),
      },
    );
  }

  /// Locked premium feature tapped
  static Future<void> premiumFeatureTapped(String feature) {
    return log('premium_feature_tapped', params: {'feature': feature});
  }

  /// What's New sheet shown
  static Future<void> whatsNewShown({
    required String wnId,
    required String locale,
    required bool isPremium,
  }) {
    return log(
      'whats_new_shown',
      params: {
        'wn_id': wnId,
        'locale': locale,
        'is_premium': isPremium ? 1 : 0,
      },
    );
  }

  /// What's New sheet dismissed (Got it)
  static Future<void> whatsNewDismissed({
    required String wnId,
    required String locale,
    required bool isPremium,
  }) {
    return log(
      'whats_new_dismissed',
      params: {
        'wn_id': wnId,
        'locale': locale,
        'is_premium': isPremium ? 1 : 0,
      },
    );
  }

  /// What's New unlock Pro CTA tapped
  static Future<void> whatsNewUnlockProTapped({
    required String wnId,
    required String locale,
  }) {
    return log(
      'whats_new_unlock_pro_tapped',
      params: {'wn_id': wnId, 'locale': locale},
    );
  }

  /// G-code import funnel
  static Future<void> gcodeImportOpened() {
    _gcodeImportTriggeredThisSession = true;
    _startGcodeImportFlow();
    return log('gcode_import_opened', params: _gcodeImportParams());
  }

  static Future<void> gcodeFileSelected({
    required int fileSizeBytes,
    String? slicer,
    required bool hasPreview,
  }) {
    _setGcodeContext(
      slicer: slicerValue(slicer),
      hasPreview: hasPreview,
      fileSizeBucket: fileSizeBucket(fileSizeBytes),
    );
    return log('gcode_file_selected', params: _gcodeImportParams());
  }

  static Future<void> gcodeParseSuccess({
    required String slicer,
    required bool hasPreview,
    required int fileSizeBytes,
  }) {
    _setGcodeContext(
      slicer: slicerValue(slicer),
      hasPreview: hasPreview,
      parseStatus: 'success',
      fileSizeBucket: fileSizeBucket(fileSizeBytes),
    );
    return log('gcode_parse_success', params: _gcodeImportParams());
  }

  static Future<void> gcodeParsePartial({
    required String slicer,
    required bool hasPreview,
    required int fileSizeBytes,
  }) {
    _setGcodeContext(
      slicer: slicerValue(slicer),
      hasPreview: hasPreview,
      parseStatus: 'partial',
      fileSizeBucket: fileSizeBucket(fileSizeBytes),
    );
    return log('gcode_parse_partial', params: _gcodeImportParams());
  }

  static Future<void> gcodeParseFailed({
    required String slicer,
    required bool hasPreview,
    required int fileSizeBytes,
  }) {
    _setGcodeContext(
      slicer: slicerValue(slicer),
      hasPreview: hasPreview,
      parseStatus: 'failed',
      fileSizeBucket: fileSizeBucket(fileSizeBytes),
    );
    return log('gcode_parse_failed', params: _gcodeImportParams());
  }

  static Future<void> gcodePreviewViewed({
    required String slicer,
    required bool hasPreview,
    required int fileSizeBytes,
    required String parseStatus,
  }) {
    _setGcodeContext(
      slicer: slicerValue(slicer),
      hasPreview: hasPreview,
      parseStatus: parseStatus,
      fileSizeBucket: fileSizeBucket(fileSizeBytes),
    );
    return log('gcode_preview_viewed', params: _gcodeImportParams());
  }

  static Future<void> gcodeApplyToCalculator({
    required String slicer,
    required bool hasPreview,
    required int fileSizeBytes,
    required String parseStatus,
  }) {
    final timeToValueMs = _gcodeTimeToValueMs();
    _setGcodeContext(
      slicer: slicerValue(slicer),
      hasPreview: hasPreview,
      parseStatus: parseStatus,
      fileSizeBucket: fileSizeBucket(fileSizeBytes),
    );
    return log(
      'gcode_apply_to_calculator',
      params: {
        ..._gcodeImportParams(),
        ...?(timeToValueMs == null
            ? null
            : {'gcode_time_to_value_ms': timeToValueMs}),
      },
    );
  }

  static Future<void> gcodeFlowCompleted({
    required String slicer,
    required bool hasPreview,
    required int fileSizeBytes,
    required String parseStatus,
  }) {
    final timeToValueMs = _gcodeTimeToValueMs();
    _setGcodeContext(
      slicer: slicerValue(slicer),
      hasPreview: hasPreview,
      parseStatus: parseStatus,
      fileSizeBucket: fileSizeBucket(fileSizeBytes),
    );
    final params = <String, Object?>{
      ..._gcodeImportParams(),
      ...?(timeToValueMs == null
          ? null
          : {'gcode_time_to_value_ms': timeToValueMs}),
    };
    _gcodeImportOpenedAt = null;
    return log('gcode_flow_completed', params: params);
  }

  static Future<void> gcodeImportAbandoned() {
    if (_gcodeImportOpenedAt == null) return Future.value();
    final params = _gcodeImportParams();
    _gcodeImportOpenedAt = null;
    return log('gcode_import_abandoned', params: params);
  }

  static void safeLog(Future<void> Function() callback) {
    unawaited(callback());
  }
}
