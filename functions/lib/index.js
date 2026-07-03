"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.decodePlayIntegrity = exports.decideForTest = exports.normalizeResponseForTest = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const google_auth_library_1 = require("google-auth-library");
const auth = new google_auth_library_1.GoogleAuth({ scopes: ['https://www.googleapis.com/auth/playintegrity'] });
const endpointBase = 'https://playintegrity.googleapis.com/v1';
const packageName = 'com.threed_print_calculator';
const decodeTimeoutMs = 8000;
function asString(value) {
    return typeof value === 'string' && value ? value : 'UNKNOWN';
}
function hasRisk(list) {
    return list !== 'UNKNOWN' && list !== 'UNEVALUATED' && list !== '';
}
function hasRecentDeviceActivityRisk(level) {
    return level === 'LEVEL_2' || level === 'LEVEL_3' || level === 'LEVEL_4';
}
function hasPlayProtectRisk(verdict) {
    return verdict !== 'NO_ISSUES' && hasRisk(verdict);
}
function asStringList(value) {
    if (!Array.isArray(value))
        return [];
    return value.filter((entry) => typeof entry === 'string' && entry.length > 0);
}
function normalizeVirtualIntegrity(deviceIntegrityLabels) {
    if (deviceIntegrityLabels.includes('MEETS_VIRTUAL_INTEGRITY')) {
        return 'MEETS_VIRTUAL_INTEGRITY';
    }
    if (deviceIntegrityLabels.length === 0) {
        return 'UNEVALUATED';
    }
    return 'NOT_MET';
}
function redactUpstreamBody(value) {
    const normalized = value.replace(/\s+/g, ' ').trim();
    if (!normalized)
        return '';
    return normalized.length > 200 ? `${normalized.slice(0, 200)}…` : normalized;
}
function normalizeResponse(payload) {
    const tokenPayload = payload?.tokenPayloadExternal || {};
    const appIntegrity = tokenPayload?.appIntegrity?.appRecognitionVerdict ?? 'UNKNOWN';
    const deviceIntegrityLabels = asStringList(tokenPayload?.deviceIntegrity?.deviceRecognitionVerdict);
    const deviceIntegrity = deviceIntegrityLabels.length === 0
        ? 'UNEVALUATED'
        : deviceIntegrityLabels.join(',');
    const virtualIntegrity = normalizeVirtualIntegrity(deviceIntegrityLabels);
    const recentDeviceActivity = asString(tokenPayload?.deviceIntegrity?.recentDeviceActivity?.deviceActivityLevel);
    const playProtect = asString(tokenPayload?.environmentDetails?.playProtectVerdict);
    const appAccessRisk = asStringList(tokenPayload?.environmentDetails?.appAccessRiskVerdict?.appsDetected);
    const licensing = asString(tokenPayload?.accountDetails?.appLicensingVerdict);
    return {
        license: licensing,
        appIntegrity,
        deviceIntegrity,
        virtualIntegrity,
        recentDeviceActivity,
        playProtect,
        appAccessRisk,
        decision: 'allow',
    };
}
function decide(flow, r) {
    const hasDeviceIntegrity = r.deviceIntegrity
        .split(',')
        .includes('MEETS_DEVICE_INTEGRITY');
    if (r.appIntegrity !== 'PLAY_RECOGNIZED' && r.appIntegrity !== 'UNEVALUATED')
        return 'block_tampered';
    if (r.license === 'UNLICENSED' && (flow === 'purchase' || flow === 'restore'))
        return 'block_unlicensed';
    if ((flow === 'purchase' || flow === 'restore') && !hasDeviceIntegrity)
        return 'soft_gate_premium';
    if (hasRecentDeviceActivityRisk(r.recentDeviceActivity) ||
        hasPlayProtectRisk(r.playProtect) ||
        r.appAccessRisk.length > 0 ||
        (!hasDeviceIntegrity && r.deviceIntegrity !== 'UNEVALUATED')) {
        return 'allow_logged_risk';
    }
    return 'allow';
}
exports.normalizeResponseForTest = normalizeResponse;
exports.decideForTest = decide;
exports.decodePlayIntegrity = (0, https_1.onCall)({
    region: 'europe-west1',
    enforceAppCheck: true,
    consumeAppCheckToken: true,
}, async (request) => {
    const { integrityToken, flow } = request.data;
    if (typeof integrityToken !== 'string' || !integrityToken)
        throw new https_1.HttpsError('invalid-argument', 'Missing integrityToken');
    if (flow !== 'startup' && flow !== 'purchase' && flow !== 'restore' && flow !== 'calculator')
        throw new https_1.HttpsError('invalid-argument', 'Invalid flow');
    const client = await auth.getClient();
    const access = await client.getAccessToken();
    if (!access.token)
        throw new https_1.HttpsError('internal', 'Missing access token');
    const abortController = new AbortController();
    const timeout = setTimeout(() => abortController.abort(), decodeTimeoutMs);
    let res;
    try {
        res = await fetch(`${endpointBase}/${packageName}:decodeIntegrityToken`, {
            method: 'POST',
            headers: {
                Authorization: `Bearer ${access.token}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ integrityToken }),
            signal: abortController.signal,
        });
    }
    catch (error) {
        logger.error('Play Integrity decode request failed', {
            error: error instanceof Error ? error.message : String(error),
        });
        throw new https_1.HttpsError('internal', 'Integrity service unavailable');
    }
    finally {
        clearTimeout(timeout);
    }
    if (!res.ok) {
        const text = await res.text();
        logger.error('Play Integrity decode failed', {
            status: res.status,
            text: redactUpstreamBody(text),
        });
        throw new https_1.HttpsError('internal', 'Integrity service unavailable');
    }
    const payload = await res.json();
    const normalized = normalizeResponse(payload);
    normalized.decision = decide(flow, normalized);
    return normalized;
});
//# sourceMappingURL=index.js.map