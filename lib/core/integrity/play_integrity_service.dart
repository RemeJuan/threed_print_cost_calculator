import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:threed_print_cost_calculator/firebase_options.dart';

import 'play_integrity_models.dart';
import 'play_integrity_sentry.dart';

enum PlayIntegrityFlow { purchase, restore }

abstract class PlayIntegrityService {
  Future<PlayIntegritySnapshot> evaluate(PlayIntegrityFlow flow);
}

class DefaultPlayIntegrityService implements PlayIntegrityService {
  static const _requestTokenTimeout = Duration(seconds: 10);

  DefaultPlayIntegrityService({
    MethodChannel? channel,
    FirebaseFunctions? functions,
    int? cloudProjectNumber,
  }) : _channel =
           channel ??
           const MethodChannel('com.threed_print_calculator/play_integrity'),
       _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1'),
       _cloudProjectNumber =
           cloudProjectNumber ??
           int.tryParse(DefaultFirebaseOptions.android.messagingSenderId);

  final MethodChannel _channel;
  final FirebaseFunctions _functions;
  final int? _cloudProjectNumber;

  @override
  Future<PlayIntegritySnapshot> evaluate(PlayIntegrityFlow flow) async {
    try {
      final nonce = _nonce();
      final token = await _channel
          .invokeMethod<String>('requestToken', {
            'nonce': nonce,
            'cloudProjectNumber': _cloudProjectNumber,
          })
          .timeout(_requestTokenTimeout);
      if (token == null || token.isEmpty) {
        throw StateError('Play Integrity token unavailable');
      }

      final callable = _functions.httpsCallable('decodePlayIntegrity');
      final response = await callable.call(<String, Object?>{
        'integrityToken': token,
        'flow': flow.name,
      });
      final snapshot = PlayIntegritySnapshot.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      capturePlayIntegritySnapshot(snapshot);
      return snapshot;
    } catch (error, stackTrace) {
      debugPrint('Play Integrity fallback: $error');
      await Sentry.captureException(error, stackTrace: stackTrace);
      return const PlayIntegritySnapshot(
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
  }

  String _nonce() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
