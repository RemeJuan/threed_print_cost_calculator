import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/firebase_options.dart';

import 'play_integrity_models.dart';
import 'play_integrity_sentry.dart';

enum PlayIntegrityFlow { purchase, restore }

abstract class PlayIntegrityService {
  Future<PlayIntegritySnapshot> evaluate(PlayIntegrityFlow flow);
}

class DefaultPlayIntegrityService implements PlayIntegrityService {
  static const _requestTokenTimeout = Duration(seconds: 5);
  @visibleForTesting
  static final limitedUseAppCheckOptions = HttpsCallableOptions(
    limitedUseAppCheckToken: true,
  );

  DefaultPlayIntegrityService({
    MethodChannel? channel,
    FirebaseFunctions? functions,
    int? cloudProjectNumber,
    AppLogger? logger,
    TargetPlatform? targetPlatform,
    Duration requestTokenTimeout = _requestTokenTimeout,
    Future<dynamic> Function(String token, PlayIntegrityFlow flow)?
    decodeIntegrity,
  }) : _channel =
           channel ??
           const MethodChannel('com.threed_print_calculator/play_integrity'),
       _functions = functions,
       _cloudProjectNumber =
           cloudProjectNumber ??
           int.tryParse(DefaultFirebaseOptions.android.messagingSenderId),
       _logger =
           logger ??
           AppLogger(
             sink: const DebugPrintAppLogSink(),
             config: const AppLoggerConfig.defaults(),
           ),
       _targetPlatform = targetPlatform ?? defaultTargetPlatform,
       _requestTokenTimeoutDuration = requestTokenTimeout,
       _decodeIntegrity = decodeIntegrity;

  final MethodChannel _channel;
  final FirebaseFunctions? _functions;
  final int? _cloudProjectNumber;
  final AppLogger _logger;
  final TargetPlatform _targetPlatform;
  final Duration _requestTokenTimeoutDuration;
  final Future<dynamic> Function(String token, PlayIntegrityFlow flow)?
  _decodeIntegrity;

  @override
  Future<PlayIntegritySnapshot> evaluate(PlayIntegrityFlow flow) async {
    if (_targetPlatform != TargetPlatform.android) {
      return _unevaluatedAllowSnapshot;
    }

    try {
      final nonce = _nonce();
      final String? token;
      try {
        token = await _channel
            .invokeMethod<String>('requestToken', {
              'nonce': nonce,
              'cloudProjectNumber': _cloudProjectNumber,
            })
            .timeout(_requestTokenTimeoutDuration);
      } on TimeoutException catch (error, stackTrace) {
        return _fallback(
          flow: flow,
          error: error,
          stackTrace: stackTrace,
          reportToSentry: false,
        );
      }
      if (token == null || token.isEmpty) {
        throw StateError('Play Integrity token unavailable');
      }

      final decodeIntegrity = _decodeIntegrity;
      final response = await (decodeIntegrity != null
          ? decodeIntegrity(token, flow)
          : _decodePlayIntegrityViaCloudFunction(token, flow));
      final snapshot = PlayIntegritySnapshot.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
      capturePlayIntegritySnapshot(snapshot);
      return snapshot;
    } catch (error, stackTrace) {
      if (error is FirebaseFunctionsException &&
          error.code == 'unauthenticated') {
        rethrow;
      }
      return _fallback(flow: flow, error: error, stackTrace: stackTrace);
    }
  }

  Future<PlayIntegritySnapshot> _fallback({
    required PlayIntegrityFlow flow,
    required Object error,
    required StackTrace stackTrace,
    bool reportToSentry = true,
  }) async {
    _logger.warn(
      AppLogCategory.billing,
      'Play Integrity fallback',
      context: {'flow': flow.name},
      error: error,
      stackTrace: stackTrace,
    );
    if (reportToSentry) {
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
    return _unevaluatedAllowSnapshot;
  }

  Future<dynamic> _decodePlayIntegrityViaCloudFunction(
    String token,
    PlayIntegrityFlow flow,
  ) async {
    final callable =
        (_functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1'))
            .httpsCallable(
              'decodePlayIntegrity',
              options: limitedUseAppCheckOptions,
            );
    final response = await callable.call(<String, Object?>{
      'integrityToken': token,
      'flow': flow.name,
    });
    return response.data;
  }

  String _nonce() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static const _unevaluatedAllowSnapshot = PlayIntegritySnapshot(
    license: 'UNEVALUATED',
    appIntegrity: 'UNEVALUATED',
    deviceIntegrity: 'UNEVALUATED',
    virtualIntegrity: 'UNEVALUATED',
    recentDeviceActivity: 'UNEVALUATED',
    playProtect: 'UNEVALUATED',
    appAccessRisk: <String>[],
    decision: PlayIntegrityDecisionLabel.allow,
  );
}
