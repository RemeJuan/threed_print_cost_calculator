import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_decision.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_models.dart';

void main() {
  test('decision helpers map hard and soft gates', () {
    expect(
      isPlayIntegrityHardBlocked(
        const PlayIntegritySnapshot(
          license: 'UNLICENSED',
          appIntegrity: 'UNEVALUATED',
          deviceIntegrity: 'UNEVALUATED',
          virtualIntegrity: 'UNEVALUATED',
          recentDeviceActivity: 'UNEVALUATED',
          playProtect: 'UNEVALUATED',
          appAccessRisk: <String>[],
          decision: PlayIntegrityDecisionLabel.blockUnlicensed,
        ),
      ),
      isTrue,
    );

    expect(
      isPlayIntegritySoftGated(
        const PlayIntegritySnapshot(
          license: 'LICENSED',
          appIntegrity: 'UNEVALUATED',
          deviceIntegrity: 'UNEVALUATED',
          virtualIntegrity: 'UNEVALUATED',
          recentDeviceActivity: 'UNEVALUATED',
          playProtect: 'UNEVALUATED',
          appAccessRisk: <String>[],
          decision: PlayIntegrityDecisionLabel.softGatePremium,
        ),
      ),
      isTrue,
    );

    expect(
      isPlayIntegrityHardBlocked(
        const PlayIntegritySnapshot(
          license: 'LICENSED',
          appIntegrity: 'PLAY_RECOGNIZED',
          deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
          virtualIntegrity: 'UNEVALUATED',
          recentDeviceActivity: 'UNEVALUATED',
          playProtect: 'NO_ISSUES',
          appAccessRisk: <String>[],
          decision: PlayIntegrityDecisionLabel.allow,
        ),
      ),
      isFalse,
    );

    expect(
      isPlayIntegrityHardBlocked(
        const PlayIntegritySnapshot(
          license: 'LICENSED',
          appIntegrity: 'PLAY_RECOGNIZED',
          deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
          virtualIntegrity: 'UNEVALUATED',
          recentDeviceActivity: 'UNEVALUATED',
          playProtect: 'NO_ISSUES',
          appAccessRisk: <String>[],
          decision: PlayIntegrityDecisionLabel.allowLoggedRisk,
        ),
      ),
      isFalse,
    );

    expect(
      isPlayIntegrityHardBlocked(
        const PlayIntegritySnapshot(
          license: 'LICENSED',
          appIntegrity: 'PLAY_RECOGNIZED',
          deviceIntegrity: 'UNEVALUATED',
          virtualIntegrity: 'UNEVALUATED',
          recentDeviceActivity: 'UNEVALUATED',
          playProtect: 'UNEVALUATED',
          appAccessRisk: <String>[],
          decision: PlayIntegrityDecisionLabel.softGatePremium,
        ),
      ),
      isFalse,
    );

    expect(
      isPlayIntegritySoftGated(
        const PlayIntegritySnapshot(
          license: 'UNLICENSED',
          appIntegrity: 'PLAY_RECOGNIZED',
          deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
          virtualIntegrity: 'UNEVALUATED',
          recentDeviceActivity: 'UNEVALUATED',
          playProtect: 'NO_ISSUES',
          appAccessRisk: <String>[],
          decision: PlayIntegrityDecisionLabel.blockUnlicensed,
        ),
      ),
      isFalse,
    );

    expect(
      isPlayIntegritySoftGated(
        const PlayIntegritySnapshot(
          license: 'LICENSED',
          appIntegrity: 'UNRECOGNIZED_VERSION',
          deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
          virtualIntegrity: 'UNEVALUATED',
          recentDeviceActivity: 'UNEVALUATED',
          playProtect: 'NO_ISSUES',
          appAccessRisk: <String>[],
          decision: PlayIntegrityDecisionLabel.blockTampered,
        ),
      ),
      isFalse,
    );
  });
}
