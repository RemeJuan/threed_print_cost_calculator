"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vitest_1 = require("vitest");
const index_1 = require("./index");
(0, vitest_1.describe)('normalizeResponseForTest', () => {
    (0, vitest_1.it)('maps nested verdict fields', () => {
        const response = (0, index_1.normalizeResponseForTest)({
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
        (0, vitest_1.expect)(response.license).toBe('LICENSED');
        (0, vitest_1.expect)(response.deviceIntegrity).toBe('MEETS_DEVICE_INTEGRITY,MEETS_BASIC_INTEGRITY');
        (0, vitest_1.expect)(response.virtualIntegrity).toBe('NOT_MET');
        (0, vitest_1.expect)(response.recentDeviceActivity).toBe('LEVEL_1');
        (0, vitest_1.expect)(response.playProtect).toBe('NO_ISSUES');
        (0, vitest_1.expect)(response.appAccessRisk).toEqual(['KNOWN_OVERLAYS']);
    });
});
(0, vitest_1.describe)('decideForTest', () => {
    (0, vitest_1.it)('hard blocks tampered apps', () => {
        const decision = (0, index_1.decideForTest)('purchase', {
            license: 'LICENSED',
            appIntegrity: 'UNRECOGNIZED_VERSION',
            deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
            virtualIntegrity: 'NOT_MET',
            recentDeviceActivity: 'UNEVALUATED',
            playProtect: 'NO_ISSUES',
            appAccessRisk: [],
            decision: 'allow',
        });
        (0, vitest_1.expect)(decision).toBe('block_tampered');
    });
    (0, vitest_1.it)('hard blocks unlicensed premium flows', () => {
        const decision = (0, index_1.decideForTest)('restore', {
            license: 'UNLICENSED',
            appIntegrity: 'PLAY_RECOGNIZED',
            deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
            virtualIntegrity: 'NOT_MET',
            recentDeviceActivity: 'UNEVALUATED',
            playProtect: 'NO_ISSUES',
            appAccessRisk: [],
            decision: 'allow',
        });
        (0, vitest_1.expect)(decision).toBe('block_unlicensed');
    });
    (0, vitest_1.it)('soft gates premium when device integrity missing', () => {
        const decision = (0, index_1.decideForTest)('purchase', {
            license: 'LICENSED',
            appIntegrity: 'PLAY_RECOGNIZED',
            deviceIntegrity: 'UNEVALUATED',
            virtualIntegrity: 'UNEVALUATED',
            recentDeviceActivity: 'UNEVALUATED',
            playProtect: 'NO_ISSUES',
            appAccessRisk: [],
            decision: 'allow',
        });
        (0, vitest_1.expect)(decision).toBe('soft_gate_premium');
    });
    (0, vitest_1.it)('does not mark LEVEL_1 and NO_ISSUES as risk', () => {
        const decision = (0, index_1.decideForTest)('restore', {
            license: 'LICENSED',
            appIntegrity: 'PLAY_RECOGNIZED',
            deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
            virtualIntegrity: 'NOT_MET',
            recentDeviceActivity: 'LEVEL_1',
            playProtect: 'NO_ISSUES',
            appAccessRisk: [],
            decision: 'allow',
        });
        (0, vitest_1.expect)(decision).toBe('allow');
    });
    (0, vitest_1.it)('returns allow_logged_risk for recent device activity risk', () => {
        const decision = (0, index_1.decideForTest)('calculator', {
            license: 'LICENSED',
            appIntegrity: 'PLAY_RECOGNIZED',
            deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
            virtualIntegrity: 'NOT_MET',
            recentDeviceActivity: 'LEVEL_2',
            playProtect: 'NO_ISSUES',
            appAccessRisk: [],
            decision: 'allow',
        });
        (0, vitest_1.expect)(decision).toBe('allow_logged_risk');
    });
    (0, vitest_1.it)('returns allow_logged_risk for Play Protect risk', () => {
        const decision = (0, index_1.decideForTest)('calculator', {
            license: 'LICENSED',
            appIntegrity: 'PLAY_RECOGNIZED',
            deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
            virtualIntegrity: 'NOT_MET',
            recentDeviceActivity: 'LEVEL_1',
            playProtect: 'POSSIBLE_RISK',
            appAccessRisk: [],
            decision: 'allow',
        });
        (0, vitest_1.expect)(decision).toBe('allow_logged_risk');
    });
    (0, vitest_1.it)('returns allow_logged_risk for app access risk', () => {
        const decision = (0, index_1.decideForTest)('calculator', {
            license: 'LICENSED',
            appIntegrity: 'PLAY_RECOGNIZED',
            deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
            virtualIntegrity: 'NOT_MET',
            recentDeviceActivity: 'LEVEL_1',
            playProtect: 'NO_ISSUES',
            appAccessRisk: ['KNOWN_OVERLAYS'],
            decision: 'allow',
        });
        (0, vitest_1.expect)(decision).toBe('allow_logged_risk');
    });
    (0, vitest_1.it)('returns allow_logged_risk when device integrity is risky but evaluated', () => {
        const decision = (0, index_1.decideForTest)('calculator', {
            license: 'LICENSED',
            appIntegrity: 'PLAY_RECOGNIZED',
            deviceIntegrity: 'MEETS_BASIC_INTEGRITY',
            virtualIntegrity: 'NOT_MET',
            recentDeviceActivity: 'LEVEL_1',
            playProtect: 'NO_ISSUES',
            appAccessRisk: [],
            decision: 'allow',
        });
        (0, vitest_1.expect)(decision).toBe('allow_logged_risk');
    });
});
//# sourceMappingURL=index.test.js.map