import 'play_integrity_models.dart';

bool isPlayIntegrityHardBlocked(PlayIntegritySnapshot snapshot) {
  return switch (snapshot.decision) {
    PlayIntegrityDecisionLabel.blockTampered => true,
    PlayIntegrityDecisionLabel.blockUnlicensed => true,
    _ => false,
  };
}

bool isPlayIntegritySoftGated(PlayIntegritySnapshot snapshot) {
  return snapshot.decision == PlayIntegrityDecisionLabel.softGatePremium;
}
