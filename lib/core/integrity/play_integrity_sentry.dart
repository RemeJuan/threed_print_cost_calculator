import 'package:sentry_flutter/sentry_flutter.dart';

import 'play_integrity_models.dart';

void capturePlayIntegritySnapshot(PlayIntegritySnapshot snapshot) {
  if (snapshot.decision == PlayIntegrityDecisionLabel.allow) return;

  final decision = playIntegrityDecisionToWireValue(snapshot.decision);
  final level = switch (snapshot.decision) {
    PlayIntegrityDecisionLabel.blockTampered => SentryLevel.error,
    PlayIntegrityDecisionLabel.blockUnlicensed => SentryLevel.error,
    PlayIntegrityDecisionLabel.softGatePremium => SentryLevel.warning,
    PlayIntegrityDecisionLabel.allowLoggedRisk => SentryLevel.info,
    PlayIntegrityDecisionLabel.allow => SentryLevel.info,
  };

  Sentry.captureMessage(
    'Play Integrity decision: $decision',
    level: level,
    withScope: (scope) {
      scope.setTag('play_integrity.license', snapshot.license);
      scope.setTag('play_integrity.app_integrity', snapshot.appIntegrity);
      scope.setTag('play_integrity.device_integrity', snapshot.deviceIntegrity);
      scope.setTag(
        'play_integrity.virtual_integrity',
        snapshot.virtualIntegrity,
      );
      scope.setTag(
        'play_integrity.recent_device_activity',
        snapshot.recentDeviceActivity,
      );
      scope.setTag('play_integrity.play_protect', snapshot.playProtect);
      scope.setTag(
        'play_integrity.app_access_risk',
        snapshot.appAccessRisk.join(','),
      );
      scope.setTag('play_integrity.decision', decision);
      scope.contexts['play_integrity'] = snapshot.toContext();
    },
  );
}
