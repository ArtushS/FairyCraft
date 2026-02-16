import { Buffer } from 'node:buffer';

export const VOICEMAKER_CONVERT_URL = 'https://developer.voicemaker.in/api/v1/voice/convert';
export const VOICEMAKER_VOICES_URL = 'https://developer.voicemaker.in/api/v1/voice/list';
export const VOICEMAKER_STT_URL = 'https://developer.voicemaker.in/api/v1/speech-to-text';
export const VOICEMAKER_TTS_STREAM_URL = 'wss://developer.voicemaker.in/api/v1/voice/convert';

const DEFAULT_TTS_TIMEOUT_MS = 30_000;
const VOICES_CACHE_TTL_MS = 6 * 60 * 60 * 1000;

export interface NormalizedTtsRequest {
  text: string;
  voiceId: string;
  languageCode: string;
  effect: string;
  speed: number;
  pitch: number;
  volume: number;
  returnBase64: boolean;
}

export interface TtsAudioResult {
  audioBuffer: Buffer;
  mimeType: string;
  usedChars?: number;
  remainChars?: number;
}

export interface TtsVoicesResponse {
  voices: VoicemakerVoice[];
  cached: boolean;
}

export interface VoicemakerVoice {
  VoiceId: string;
  VoiceWebname: string;
  Language: string;
  Gender: string;
}

export interface NormalizedSttRequest {
  model: string;
  language: string;
}

export interface SttProxyResult {
  generatedText: string;
  status: string;
  taskId?: string;
  detectedLanguage?: string;
  usedChars?: number;
  remainChars?: number;
}

export interface UploadedAudioFile {
  buffer: Buffer;
  size: number;
  mimetype: string;
  originalname: string;
}

interface CachedVoices {
  expiresAt: number;
  voices: VoicemakerVoice[];
}

export class VoicemakerHttpError extends Error {
  constructor(
    readonly statusCode: number,
    readonly errorCode: string,
    readonly safeMessage: string,
  ) {
    super(safeMessage);
  }
}

export class PerUserConcurrencyLimiter {
  private readonly activeByUser = new Map<string, number>();

  constructor(private readonly maxParallelPerUser: number) {}

  tryAcquire(userKey: string): boolean {
    const current = this.activeByUser.get(userKey) ?? 0;
    if (current >= this.maxParallelPerUser) {
      return false;
    }
    this.activeByUser.set(userKey, current + 1);
    return true;
  }

  release(userKey: string): void {
    const current = this.activeByUser.get(userKey);
    if (current == null) {
      return;
    }

    if (current <= 1) {
      this.activeByUser.delete(userKey);
      return;
    }

    this.activeByUser.set(userKey, current - 1);
  }

  activeCount(userKey: string): number {
    return this.activeByUser.get(userKey) ?? 0;
  }
}

export class VoicemakerService {
  private readonly voicesCache = new Map<string, CachedVoices>();

  constructor(private readonly apiKeyRaw: string) {}

  getApiKey(): string {
    const VOICEMAKER_API_KEY = this.apiKeyRaw.trim();
    if (!VOICEMAKER_API_KEY) {
      throw new Error('VOICEMAKER_API_KEY missing');
    }
    return VOICEMAKER_API_KEY;
  }

  normalizeTtsRequest(input: unknown): NormalizedTtsRequest {
    const payload = isRecord(input) ? input : {};

    const text = asString(payload.text, asString(payload.Text)).trim();
    if (!text) {
      throw new VoicemakerHttpError(400, 'invalid_tts_request', 'text is required');
    }
    if (text.length > 9000) {
      throw new VoicemakerHttpError(400, 'text_too_long', 'text exceeds max length of 9000');
    }

    const voiceId = asString(payload.voiceId, asString(payload.VoiceId, 'ai3-Jony')).trim();
    const languageCode = asString(payload.languageCode, asString(payload.LanguageCode, 'en-US')).trim();
    const effect = asString(payload.effect, asString(payload.Effect, 'default')).trim() || 'default';

    return {
      text,
      voiceId: voiceId || 'ai3-Jony',
      languageCode: languageCode || 'en-US',
      effect,
      speed: clampNumber(payload.speed ?? payload.masterSpeed ?? payload.MasterSpeed, -10, 10),
      pitch: clampNumber(payload.pitch ?? payload.masterPitch ?? payload.MasterPitch, -10, 10),
      volume: clampNumber(payload.volume ?? payload.masterVolume ?? payload.MasterVolume, -10, 10),
      returnBase64: asBoolean(payload.returnBase64) || asString(payload.responseType).toLowerCase() === 'base64',
    };
  }

  normalizeSttRequest(input: unknown): NormalizedSttRequest {
    const payload = isRecord(input) ? input : {};
    const model = asString(payload.model, 'stt-flagship-v1').trim() || 'stt-flagship-v1';
    const language = asString(payload.language, 'auto').trim() || 'auto';
    return { model, language };
  }

  async generateTtsAudio(request: NormalizedTtsRequest): Promise<TtsAudioResult> {
    const upstreamResponse = await this.fetchWithTimeout(VOICEMAKER_CONVERT_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.getApiKey()}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(this.buildUpstreamTtsPayload(request)),
    });

    if (!upstreamResponse.ok) {
      const safeMessage = await extractUpstreamErrorMessage(upstreamResponse, 'TTS provider request failed.');
      throw new VoicemakerHttpError(502, 'tts_upstream_failed', safeMessage);
    }

    const contentType = upstreamResponse.headers.get('content-type') ?? 'audio/mpeg';

    if (contentType.includes('application/json')) {
      const raw = await upstreamResponse.text();
      const decoded = parseJsonRecord(raw);
      const usedChars = asInt(decoded.usedChars);
      const remainChars = asInt(decoded.remainChars);

      const audioBytes = extractBase64Audio(decoded);
      if (audioBytes != null) {
        return {
          audioBuffer: audioBytes,
          mimeType: 'audio/mpeg',
          usedChars,
          remainChars,
        };
      }

      const path = asString(decoded.path, asString(decoded.audioUrl)).trim();
      if (!path) {
        throw new VoicemakerHttpError(502, 'tts_upstream_failed', 'TTS provider returned no audio data.');
      }

      const downloadResponse = await this.fetchWithTimeout(path, {
        method: 'GET',
        headers: {
          Authorization: `Bearer ${this.getApiKey()}`,
        },
      });

      if (!downloadResponse.ok) {
        throw new VoicemakerHttpError(502, 'tts_upstream_failed', 'Failed to download generated narration audio.');
      }

      const buffer = Buffer.from(await downloadResponse.arrayBuffer());
      return {
        audioBuffer: buffer,
        mimeType: downloadResponse.headers.get('content-type') ?? 'audio/mpeg',
        usedChars,
        remainChars,
      };
    }

    const audioBuffer = Buffer.from(await upstreamResponse.arrayBuffer());
    return {
      audioBuffer,
      mimeType: contentType,
      usedChars: undefined,
      remainChars: undefined,
    };
  }

  async listVoices(languageCode: string): Promise<TtsVoicesResponse> {
    const normalizedLanguage = languageCode.trim() || 'en-US';
    const cacheKey = normalizedLanguage.toLowerCase();
    const cached = this.voicesCache.get(cacheKey);

    if (cached && cached.expiresAt > Date.now()) {
      return {
        voices: cached.voices,
        cached: true,
      };
    }

    const upstream = await this.fetchWithTimeout(VOICEMAKER_VOICES_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.getApiKey()}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        language: normalizedLanguage,
        languageCode: normalizedLanguage,
        Language: normalizedLanguage,
      }),
    });

    if (!upstream.ok) {
      const safeMessage = await extractUpstreamErrorMessage(upstream, 'Failed to load voices.');
      throw new VoicemakerHttpError(502, 'tts_upstream_failed', safeMessage);
    }

    const rawText = await upstream.text();
    const decoded = parseJsonUnknown(rawText);
    const voices = normalizeVoices(decoded).map((voice) => ({
      VoiceId: voice.VoiceId,
      VoiceWebname: voice.VoiceWebname,
      Language: voice.Language,
      Gender: voice.Gender,
    }));

    this.voicesCache.set(cacheKey, {
      voices,
      expiresAt: Date.now() + VOICES_CACHE_TTL_MS,
    });

    return {
      voices,
      cached: false,
    };
  }

  async transcribeAudio(file: UploadedAudioFile | undefined, input: NormalizedSttRequest): Promise<SttProxyResult> {
    if (!file || file.size <= 0) {
      throw new VoicemakerHttpError(400, 'audio_required', 'Audio file is required.');
    }

    const formData = new FormData();
    formData.append('model', input.model);
    formData.append('language', input.language);
    formData.append('responseFormat', 'json');
    formData.append('includeSubtitle', 'false');
    formData.append('tagAudioEvents', 'false');
    formData.append(
      'file',
      new Blob([new Uint8Array(file.buffer)], {
        type: file.mimetype || 'audio/wav',
      }),
      file.originalname || 'recording.wav',
    );

    const upstream = await this.fetchWithTimeout(VOICEMAKER_STT_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.getApiKey()}`,
      },
      body: formData,
    });

    const rawText = await upstream.text();
    const parsed = parseJsonRecord(rawText);

    if (!upstream.ok) {
      const safeMessage =
        asString(parsed.message).trim() ||
        asString(parsed.error).trim() ||
        'Speech recognition request failed.';
      throw new VoicemakerHttpError(502, 'stt_upstream_failed', safeMessage);
    }

    const parsedData = isRecord(parsed.data) ? parsed.data : {};
    const generatedText = asString(parsedData.generatedText, asString(parsedData.text)).trim();
    const statusRaw = asString(parsed.status).trim().toLowerCase();
    const status =
      statusRaw || (parsed.isProcessing === true ? 'processing' : generatedText.length > 0 ? 'completed' : 'failed');

    return {
      generatedText,
      status,
      taskId: asString(parsed.taskId, asString(parsedData.taskId)).trim() || undefined,
      detectedLanguage: asString(parsedData.language).trim() || undefined,
      usedChars: asInt(parsed.usedChars),
      remainChars: asInt(parsed.remainChars),
    };
  }

  buildUpstreamTtsPayload(request: NormalizedTtsRequest): Record<string, string> {
    const speed = String(Math.round(request.speed));
    const pitch = String(Math.round(request.pitch));
    const volume = String(Math.round(request.volume));

    return {
      VoiceId: request.voiceId,
      LanguageCode: request.languageCode,
      Text: request.text,
      Effect: request.effect,
      OutputFormat: 'mp3',
      SampleRate: '48000',
      MasterSpeed: speed,
      MasterPitch: pitch,
      MasterVolume: volume,
      ResponseType: 'stream',
      voiceId: request.voiceId,
      languageCode: request.languageCode,
      text: request.text,
      effect: request.effect,
      masterSpeed: speed,
      masterPitch: pitch,
      masterVolume: volume,
      responseType: 'stream',
    };
  }

  private async fetchWithTimeout(input: string, init: RequestInit): Promise<Response> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), DEFAULT_TTS_TIMEOUT_MS);

    try {
      return await fetch(input, {
        ...init,
        signal: controller.signal,
      });
    } catch (error) {
      const isAbortError = error instanceof Error && error.name === 'AbortError';
      if (isAbortError) {
        throw new VoicemakerHttpError(504, 'voicemaker_timeout', 'Upstream request timed out.');
      }
      throw error;
    } finally {
      clearTimeout(timeout);
    }
  }
}

const normalizeVoices = (decoded: unknown): VoicemakerVoice[] => {
  const list = extractVoiceRecords(decoded);
  return list
    .map((item) => ({
      VoiceId: asString(item.VoiceId, asString(item.voiceId)).trim(),
      VoiceWebname: asString(item.VoiceWebname, asString(item.voiceName)).trim(),
      Language: asString(item.Language, asString(item.language)).trim(),
      Gender: asString(item.VoiceGender, asString(item.gender)).trim(),
    }))
    .filter((item) => item.VoiceId.length > 0)
    .sort((a, b) => a.VoiceWebname.localeCompare(b.VoiceWebname));
};

const extractVoiceRecords = (decoded: unknown): Record<string, unknown>[] => {
  if (Array.isArray(decoded)) {
    return decoded.filter(isRecord);
  }

  if (!isRecord(decoded)) {
    return [];
  }

  for (const key of ['voices', 'data', 'result', 'items']) {
    const value = decoded[key];
    if (Array.isArray(value)) {
      return value.filter(isRecord);
    }
  }

  return [];
};

const parseJsonUnknown = (rawText: string): unknown => {
  const trimmed = rawText.trim();
  if (!trimmed) {
    return {};
  }

  try {
    return JSON.parse(trimmed);
  } catch {
    return {};
  }
};

const parseJsonRecord = (rawText: string): Record<string, unknown> => {
  const parsed = parseJsonUnknown(rawText);
  return isRecord(parsed) ? parsed : {};
};

const isRecord = (value: unknown): value is Record<string, unknown> => {
  return typeof value === 'object' && value !== null;
};

const asString = (value: unknown, fallback = ''): string => {
  if (typeof value === 'string') {
    return value;
  }
  if (typeof value === 'number' || typeof value === 'boolean') {
    return String(value);
  }
  return fallback;
};

const asBoolean = (value: unknown): boolean => {
  if (typeof value === 'boolean') {
    return value;
  }
  if (typeof value === 'string') {
    const normalized = value.trim().toLowerCase();
    return normalized === '1' || normalized === 'true' || normalized === 'yes';
  }
  return false;
};

const asInt = (value: unknown): number | undefined => {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return Math.round(value);
  }
  if (typeof value === 'string') {
    const parsed = Number(value);
    if (Number.isFinite(parsed)) {
      return Math.round(parsed);
    }
  }
  return undefined;
};

const clampNumber = (value: unknown, min: number, max: number): number => {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    return 0;
  }
  return Math.min(max, Math.max(min, parsed));
};

const extractBase64Audio = (decoded: Record<string, unknown>): Buffer | null => {
  const raw = asString(decoded.audioBase64, asString(decoded.audioBytes)).trim();
  if (!raw) {
    return null;
  }

  try {
    return Buffer.from(raw, 'base64');
  } catch {
    return null;
  }
};

const extractUpstreamErrorMessage = async (response: Response, fallback: string): Promise<string> => {
  try {
    const raw = await response.text();
    const parsed = parseJsonRecord(raw);
    const message = asString(parsed.message, asString(parsed.error)).trim();
    return message || fallback;
  } catch {
    return fallback;
  }
};
