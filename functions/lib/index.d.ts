type Flow = 'startup' | 'purchase' | 'restore' | 'calculator';
type Decision = 'allow' | 'allow_logged_risk' | 'soft_gate_premium' | 'block_tampered' | 'block_unlicensed';
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
declare function normalizeResponse(payload: any): ResponseData;
declare function decide(flow: Flow, r: ResponseData): Decision;
export declare const normalizeResponseForTest: typeof normalizeResponse;
export declare const decideForTest: typeof decide;
export declare const decodePlayIntegrity: import("firebase-functions/v2/https").CallableFunction<any, Promise<ResponseData>, unknown>;
export {};
