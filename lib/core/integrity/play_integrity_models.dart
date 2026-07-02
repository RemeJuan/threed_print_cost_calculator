enum PlayIntegrityDecisionLabel {
  allow,
  allowLoggedRisk,
  softGatePremium,
  blockTampered,
  blockUnlicensed,
}

PlayIntegrityDecisionLabel playIntegrityDecisionFromJsonValue(Object? value) {
  return switch (value) {
    'allow' => PlayIntegrityDecisionLabel.allow,
    'allow_logged_risk' => PlayIntegrityDecisionLabel.allowLoggedRisk,
    'soft_gate_premium' => PlayIntegrityDecisionLabel.softGatePremium,
    'block_tampered' => PlayIntegrityDecisionLabel.blockTampered,
    'block_unlicensed' => PlayIntegrityDecisionLabel.blockUnlicensed,
    _ => PlayIntegrityDecisionLabel.allow,
  };
}

String playIntegrityDecisionToWireValue(PlayIntegrityDecisionLabel value) {
  return switch (value) {
    PlayIntegrityDecisionLabel.allow => 'allow',
    PlayIntegrityDecisionLabel.allowLoggedRisk => 'allow_logged_risk',
    PlayIntegrityDecisionLabel.softGatePremium => 'soft_gate_premium',
    PlayIntegrityDecisionLabel.blockTampered => 'block_tampered',
    PlayIntegrityDecisionLabel.blockUnlicensed => 'block_unlicensed',
  };
}

class PlayIntegritySnapshot {
  const PlayIntegritySnapshot({
    required this.license,
    required this.appIntegrity,
    required this.deviceIntegrity,
    required this.virtualIntegrity,
    required this.recentDeviceActivity,
    required this.playProtect,
    required this.appAccessRisk,
    required this.decision,
  });

  final String license;
  final String appIntegrity;
  final String deviceIntegrity;
  final String virtualIntegrity;
  final String recentDeviceActivity;
  final String playProtect;
  final List<String> appAccessRisk;
  final PlayIntegrityDecisionLabel decision;

  factory PlayIntegritySnapshot.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    return PlayIntegritySnapshot(
      license: data['license']?.toString() ?? 'UNEVALUATED',
      appIntegrity: data['appIntegrity']?.toString() ?? 'UNEVALUATED',
      deviceIntegrity: data['deviceIntegrity']?.toString() ?? 'UNEVALUATED',
      virtualIntegrity: data['virtualIntegrity']?.toString() ?? 'UNEVALUATED',
      recentDeviceActivity:
          data['recentDeviceActivity']?.toString() ?? 'UNEVALUATED',
      playProtect: data['playProtect']?.toString() ?? 'UNEVALUATED',
      appAccessRisk:
          (data['appAccessRisk'] as List?)
              ?.map((entry) => entry.toString())
              .toList(growable: false) ??
          const <String>[],
      decision: playIntegrityDecisionFromJsonValue(data['decision']),
    );
  }

  Map<String, Object?> toContext() => {
    'license': license,
    'appIntegrity': appIntegrity,
    'deviceIntegrity': deviceIntegrity,
    'virtualIntegrity': virtualIntegrity,
    'recentDeviceActivity': recentDeviceActivity,
    'playProtect': playProtect,
    'appAccessRisk': appAccessRisk,
    'decision': playIntegrityDecisionToWireValue(decision),
  };
}
