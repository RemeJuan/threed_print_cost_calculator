import { describe, expect, it } from 'vitest';

import { decideForTest, normalizeResponseForTest } from './index';

describe('normalizeResponseForTest', () => {
  it('maps nested verdict fields', () => {
    const response = normalizeResponseForTest({
      tokenPayloadExternal: {
        accountDetails: { appLicensingVerdict: 'LICENSED' },
        appIntegrity: { appRecognitionVerdict: 'PLAY_RECOGNIZED' },
        deviceIntegrity: {
          deviceRecognitionVerdict: [
            'MEETS_DEVICE_INTEGRITY',
            'MEETS_BASIC_INTEGRITY',
          ],
          recentDeviceActivity: { deviceActivityLevel: 'LEVEL_1' },
        },
        environmentDetails: {
          playProtectVerdict: 'NO_ISSUES',
          appAccessRiskVerdict: {
            appsDetected: ['KNOWN_OVERLAYS'],
          },
        },
      },
    });

    expect(response.license).toBe('LICENSED');
    expect(response.deviceIntegrity).toBe(
      'MEETS_DEVICE_INTEGRITY,MEETS_BASIC_INTEGRITY',
    );
    expect(response.virtualIntegrity).toBe('NOT_MET');
    expect(response.recentDeviceActivity).toBe('LEVEL_1');
    expect(response.playProtect).toBe('NO_ISSUES');
    expect(response.appAccessRisk).toEqual(['KNOWN_OVERLAYS']);
  });
});

describe('decideForTest', () => {
  it('hard blocks tampered apps', () => {
    const decision = decideForTest('purchase', {
      license: 'LICENSED',
      appIntegrity: 'UNRECOGNIZED_VERSION',
      deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
      virtualIntegrity: 'NOT_MET',
      recentDeviceActivity: 'UNEVALUATED',
      playProtect: 'NO_ISSUES',
      appAccessRisk: [],
      decision: 'allow',
    });

    expect(decision).toBe('block_tampered');
  });

  it('hard blocks unlicensed premium flows', () => {
    const decision = decideForTest('restore', {
      license: 'UNLICENSED',
      appIntegrity: 'PLAY_RECOGNIZED',
      deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
      virtualIntegrity: 'NOT_MET',
      recentDeviceActivity: 'UNEVALUATED',
      playProtect: 'NO_ISSUES',
      appAccessRisk: [],
      decision: 'allow',
    });

    expect(decision).toBe('block_unlicensed');
  });

  it('soft gates premium when device integrity missing', () => {
    const decision = decideForTest('purchase', {
      license: 'LICENSED',
      appIntegrity: 'PLAY_RECOGNIZED',
      deviceIntegrity: 'UNEVALUATED',
      virtualIntegrity: 'UNEVALUATED',
      recentDeviceActivity: 'UNEVALUATED',
      playProtect: 'NO_ISSUES',
      appAccessRisk: [],
      decision: 'allow',
    });

    expect(decision).toBe('soft_gate_premium');
  });

  it('does not mark LEVEL_1 and NO_ISSUES as risk', () => {
    const decision = decideForTest('restore', {
      license: 'LICENSED',
      appIntegrity: 'PLAY_RECOGNIZED',
      deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
      virtualIntegrity: 'NOT_MET',
      recentDeviceActivity: 'LEVEL_1',
      playProtect: 'NO_ISSUES',
      appAccessRisk: [],
      decision: 'allow',
    });

    expect(decision).toBe('allow');
  });

  it('returns allow_logged_risk for recent device activity risk', () => {
    const decision = decideForTest('calculator', {
      license: 'LICENSED',
      appIntegrity: 'PLAY_RECOGNIZED',
      deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
      virtualIntegrity: 'NOT_MET',
      recentDeviceActivity: 'LEVEL_2',
      playProtect: 'NO_ISSUES',
      appAccessRisk: [],
      decision: 'allow',
    });

    expect(decision).toBe('allow_logged_risk');
  });

  it('returns allow_logged_risk for Play Protect risk', () => {
    const decision = decideForTest('calculator', {
      license: 'LICENSED',
      appIntegrity: 'PLAY_RECOGNIZED',
      deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
      virtualIntegrity: 'NOT_MET',
      recentDeviceActivity: 'LEVEL_1',
      playProtect: 'POSSIBLE_RISK',
      appAccessRisk: [],
      decision: 'allow',
    });

    expect(decision).toBe('allow_logged_risk');
  });

  it('returns allow_logged_risk for app access risk', () => {
    const decision = decideForTest('calculator', {
      license: 'LICENSED',
      appIntegrity: 'PLAY_RECOGNIZED',
      deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
      virtualIntegrity: 'NOT_MET',
      recentDeviceActivity: 'LEVEL_1',
      playProtect: 'NO_ISSUES',
      appAccessRisk: ['KNOWN_OVERLAYS'],
      decision: 'allow',
    });

    expect(decision).toBe('allow_logged_risk');
  });

  it('returns allow_logged_risk when device integrity is risky but evaluated', () => {
    const decision = decideForTest('calculator', {
      license: 'LICENSED',
      appIntegrity: 'PLAY_RECOGNIZED',
      deviceIntegrity: 'MEETS_BASIC_INTEGRITY',
      virtualIntegrity: 'NOT_MET',
      recentDeviceActivity: 'LEVEL_1',
      playProtect: 'NO_ISSUES',
      appAccessRisk: [],
      decision: 'allow',
    });

    expect(decision).toBe('allow_logged_risk');
  });
});
