import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { GoogleAuth } from 'google-auth-library';

type Flow = 'startup' | 'purchase' | 'restore' | 'calculator';
type Decision = 'allow' | 'allow_logged_risk' | 'soft_gate_premium' | 'block_tampered' | 'block_unlicensed';

type RequestData = { integrityToken?: unknown; flow?: unknown };

type ResponseData = {
  license: string;
  appIntegrity: string;
  deviceIntegrity: string;
  virtualIntegrity: string;
  recentDeviceActivity: string;
  playProtect: string;
  appAccessRisk: string[];
  decision: Decision;
};

const auth = new GoogleAuth({ scopes: ['https://www.googleapis.com/auth/playintegrity'] });
const endpointBase = 'https://playintegrity.googleapis.com/v1';
const packageName = 'com.threed_print_calculator';
const decodeTimeoutMs = 8000;

function asString(value: unknown): string {
  return typeof value === 'string' && value ? value : 'UNKNOWN';
}

function hasRisk(list: string): boolean {
  return list !== 'UNKNOWN' && list !== 'UNEVALUATED' && list !== '';
}

function hasRecentDeviceActivityRisk(level: string): boolean {
  return level === 'LEVEL_2' || level === 'LEVEL_3' || level === 'LEVEL_4';
}

function hasPlayProtectRisk(verdict: string): boolean {
  return verdict !== 'NO_ISSUES' && hasRisk(verdict);
}

function asStringList(value: unknown): string[] {
  if (!Array.isArray(value)) return [];

  return value.filter(
    (entry): entry is string => typeof entry === 'string' && entry.length > 0,
  );
}

function normalizeVirtualIntegrity(deviceIntegrityLabels: string[]): string {
  if (deviceIntegrityLabels.includes('MEETS_VIRTUAL_INTEGRITY')) {
    return 'MEETS_VIRTUAL_INTEGRITY';
  }
  if (deviceIntegrityLabels.length === 0) {
    return 'UNEVALUATED';
  }
  return 'NOT_MET';
}

function redactUpstreamBody(value: string): string {
  const normalized = value.replace(/\s+/g, ' ').trim();
  if (!normalized) return '';
  return normalized.length > 200 ? `${normalized.slice(0, 200)}…` : normalized;
}

function normalizeResponse(payload: any): ResponseData {
  const tokenPayload = payload?.tokenPayloadExternal || {};
  const appIntegrity = tokenPayload?.appIntegrity?.appRecognitionVerdict ?? 'UNKNOWN';
  const deviceIntegrityLabels = asStringList(
    tokenPayload?.deviceIntegrity?.deviceRecognitionVerdict,
  );
  const deviceIntegrity =
    deviceIntegrityLabels.length === 0
      ? 'UNEVALUATED'
      : deviceIntegrityLabels.join(',');
  const virtualIntegrity = normalizeVirtualIntegrity(deviceIntegrityLabels);
  const recentDeviceActivity = asString(
    tokenPayload?.deviceIntegrity?.recentDeviceActivity?.deviceActivityLevel,
  );
  const playProtect = asString(
    tokenPayload?.environmentDetails?.playProtectVerdict,
  );
  const appAccessRisk = asStringList(
    tokenPayload?.environmentDetails?.appAccessRiskVerdict?.appsDetected,
  );
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

function decide(flow: Flow, r: ResponseData): Decision {
  const hasDeviceIntegrity = r.deviceIntegrity
    .split(',')
    .includes('MEETS_DEVICE_INTEGRITY');

  if (r.appIntegrity !== 'PLAY_RECOGNIZED' && r.appIntegrity !== 'UNEVALUATED') return 'block_tampered';
  if (r.license === 'UNLICENSED' && (flow === 'purchase' || flow === 'restore')) return 'block_unlicensed';
  if ((flow === 'purchase' || flow === 'restore') && !hasDeviceIntegrity) return 'soft_gate_premium';
  if (
    hasRecentDeviceActivityRisk(r.recentDeviceActivity) ||
    hasPlayProtectRisk(r.playProtect) ||
    r.appAccessRisk.length > 0 ||
    (!hasDeviceIntegrity && r.deviceIntegrity !== 'UNEVALUATED')
  ) {
    return 'allow_logged_risk';
  }
  return 'allow';
}

export const normalizeResponseForTest = normalizeResponse;
export const decideForTest = decide;

export const decodePlayIntegrity = onCall(
  {
    region: 'europe-west1',
    enforceAppCheck: true,
    consumeAppCheckToken: true,
  },
  async (request): Promise<ResponseData> => {
    const { integrityToken, flow } = request.data as RequestData;
    if (typeof integrityToken !== 'string' || !integrityToken) throw new HttpsError('invalid-argument', 'Missing integrityToken');
    if (flow !== 'startup' && flow !== 'purchase' && flow !== 'restore' && flow !== 'calculator') throw new HttpsError('invalid-argument', 'Invalid flow');

    const client = await auth.getClient();
    const access = await client.getAccessToken();
    if (!access.token) throw new HttpsError('internal', 'Missing access token');

    const abortController = new AbortController();
    const timeout = setTimeout(() => abortController.abort(), decodeTimeoutMs);

    let res: Response;
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
    } catch (error) {
      logger.error('Play Integrity decode request failed', {
        error: error instanceof Error ? error.message : String(error),
      });
      throw new HttpsError('internal', 'Integrity service unavailable');
    } finally {
      clearTimeout(timeout);
    }

    if (!res.ok) {
      const text = await res.text();
      logger.error('Play Integrity decode failed', {
        status: res.status,
        text: redactUpstreamBody(text),
      });
      throw new HttpsError('internal', 'Integrity service unavailable');
    }

    const payload = await res.json();
    const normalized = normalizeResponse(payload);
    normalized.decision = decide(flow, normalized);
    return normalized;
  },
);
