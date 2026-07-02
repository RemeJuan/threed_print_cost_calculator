import 'package:sentry_flutter/sentry_flutter.dart';

import 'play_integrity_models.dart';

void capturePlayIntegritySnapshot(PlayIntegritySnapshot snapshot) {
  Sentry.configureScope((scope) {
    scope.setTag('play_integrity.license', snapshot.license);
    scope.setTag('play_integrity.app_integrity', snapshot.appIntegrity);
    scope.setTag('play_integrity.device_integrity', snapshot.deviceIntegrity);
    scope.setTag('play_integrity.virtual_integrity', snapshot.virtualIntegrity);
    scope.setTag(
      'play_integrity.recent_device_activity',
      snapshot.recentDeviceActivity,
    );
    scope.setTag('play_integrity.play_protect', snapshot.playProtect);
    scope.setTag(
      'play_integrity.app_access_risk',
      snapshot.appAccessRisk.join(','),
    );
    scope.setTag(
      'play_integrity.decision',
      playIntegrityDecisionToWireValue(snapshot.decision),
    );
    scope.contexts['play_integrity'] = snapshot.toContext();
  });

  if (snapshot.decision != PlayIntegrityDecisionLabel.allow) {
    Sentry.captureMessage(
      'Play Integrity decision: ${playIntegrityDecisionToWireValue(snapshot.decision)}',
    );
  }
}
