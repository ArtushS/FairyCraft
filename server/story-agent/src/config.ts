import dotenv from 'dotenv';

dotenv.config();

const parseBoolean = (value: string | undefined, fallback: boolean): boolean => {
  if (value == null || value.trim() === '') {
    return fallback;
  }
  return ['1', 'true', 'yes', 'on'].includes(value.trim().toLowerCase());
};

const parseNumber = (value: string | undefined, fallback: number): number => {
  if (value == null || value.trim() === '') {
    return fallback;
  }
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
};

export interface AppConfig {
  port: number;
  nodeEnv: string;
  isProduction: boolean;
  authRequired: boolean;
  appCheckRequired: boolean;
  mockEngine: boolean;
  storeDisabled: boolean;
  policyTtlMs: number;
  requestTimeoutMs: number;
  globalRateLimitPerMin: number;
  rateEntryTtlMs: number;
  rateMapCap: number;
  defaultPolicyModel: string;
  vertexLocation?: string;
  geminiModel?: string;
  vertexImageModel?: string;
  googleCloudProject?: string;
  storageBucket?: string;
  serviceName: string;
  serviceRevision: string;
  configurationName: string;
  voicemakerApiKey: string;
  sttRateLimitPerMin: number;
}

export const loadConfig = (): AppConfig => {
  const nodeEnv = process.env.NODE_ENV ?? 'development';
  return {
    port: parseNumber(process.env.PORT, 8080),
    nodeEnv,
    isProduction: nodeEnv === 'production',
    authRequired: parseBoolean(process.env.AUTH_REQUIRED, false),
    appCheckRequired: parseBoolean(process.env.APPCHECK_REQUIRED, false),
    mockEngine: parseBoolean(process.env.MOCK_ENGINE, true),
    storeDisabled: parseBoolean(process.env.STORE_DISABLED, true),
    policyTtlMs: parseNumber(process.env.POLICY_TTL_MS, 60_000),
    requestTimeoutMs: parseNumber(process.env.REQUEST_TIMEOUT_MS, 20_000),
    globalRateLimitPerMin: parseNumber(process.env.GLOBAL_RATE_LIMIT_PER_MIN, 120),
    rateEntryTtlMs: parseNumber(process.env.RATE_ENTRY_TTL_MS, 120_000),
    rateMapCap: parseNumber(process.env.RATE_MAP_CAP, 10_000),
    defaultPolicyModel: process.env.GEMINI_MODEL ?? 'gemini-2.0-flash',
    vertexLocation: process.env.VERTEX_LOCATION,
    geminiModel: process.env.GEMINI_MODEL,
    vertexImageModel: process.env.VERTEX_IMAGE_MODEL,
    googleCloudProject: process.env.GOOGLE_CLOUD_PROJECT,
    storageBucket: process.env.STORAGE_BUCKET,
    serviceName: process.env.K_SERVICE ?? 'story-agent',
    serviceRevision: process.env.K_REVISION ?? 'local',
    configurationName: process.env.K_CONFIGURATION ?? 'local',
    voicemakerApiKey: process.env.VOICEMAKER_API_KEY ?? '',
    sttRateLimitPerMin: parseNumber(process.env.STT_RATE_LIMIT_PER_MIN, 30),
  };
};
