import 'play_integrity_models.dart';

bool isPlayIntegrityHardBlocked(PlayIntegritySnapshot snapshot) {
  return switch (snapshot.decision) {
    PlayIntegrityDecisionLabel.blockTampered => true,
    PlayIntegrityDecisionLabel.blockUnlicensed => true,
    PlayIntegrityDecisionLabel.allow => false,
    PlayIntegrityDecisionLabel.allowLoggedRisk => false,
    PlayIntegrityDecisionLabel.softGatePremium => false,
  };
}

bool isPlayIntegritySoftGated(PlayIntegritySnapshot snapshot) {
  return snapshot.decision == PlayIntegrityDecisionLabel.softGatePremium;
}
