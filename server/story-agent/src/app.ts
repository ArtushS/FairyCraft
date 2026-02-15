import { randomUUID } from 'node:crypto';

import express, { type Request, type Response } from 'express';
import rateLimit from 'express-rate-limit';
import multer from 'multer';

import { loadConfig, type AppConfig } from './config';
import { storyRequestSchema } from './schemas';
import { EngineUnavailableError, MockStoryEngine, VertexStoryEngine, type StoryEngine } from './services/engine';
import { createAuthMiddleware } from './middleware/auth';
import { defaultRuntimePolicy, PolicyService } from './services/policy';
import { BoundedRateCounter } from './services/rateLimiter';
import { FirestoreStoryStore, InMemoryStoryStore, type StoryStore } from './services/store';
import type { RuntimePolicy, StoryAction, StoryRequest, StoryResponse, StorySession } from './types';

interface AppServices {
  config: AppConfig;
  store: StoryStore;
  policyService: PolicyService;
  engine: StoryEngine;
  ipCounter: BoundedRateCounter;
  uidCounter: BoundedRateCounter;
}

export interface CreateAppOptions {
  config?: AppConfig;
  store?: StoryStore;
  engine?: StoryEngine;
}

const isoDay = (date: Date): string => {
  const yyyy = date.getUTCFullYear();
  const mm = String(date.getUTCMonth() + 1).padStart(2, '0');
  const dd = String(date.getUTCDate()).padStart(2, '0');
  return `${yyyy}${mm}${dd}`;
};

const nowIso = (): string => new Date().toISOString();

const withDebug = (config: AppConfig, payload: StoryResponse, extra: Record<string, unknown>): StoryResponse => {
  if (config.isProduction) {
    return payload;
  }

  return {
    ...payload,
    debug: {
      service: config.serviceName,
      revision: config.serviceRevision,
      configuration: config.configurationName,
      ...extra,
    },
  };
};

const placeholderImage = (prompt?: string): StoryResponse['image'] => ({
  disabled: true,
  prompt: prompt ?? 'Illustration placeholder is returned in current mode.',
});

const jsonSizeKb = (value: unknown): number => Buffer.byteLength(JSON.stringify(value ?? {}), 'utf8') / 1024;

const runWithTimeout = async <T>(promise: Promise<T>, timeoutMs: number): Promise<T> => {
  let timeout: NodeJS.Timeout | undefined;
  const timeoutPromise = new Promise<T>((_, reject) => {
    timeout = setTimeout(() => reject(new Error('request_timeout')), timeoutMs);
  });
  try {
    return await Promise.race([promise, timeoutPromise]);
  } finally {
    if (timeout) {
      clearTimeout(timeout);
    }
  }
};

const createServices = (options?: CreateAppOptions): AppServices => {
  const config = options?.config ?? loadConfig();
  const store =
    options?.store ??
    (config.storeDisabled ? new InMemoryStoryStore(defaultRuntimePolicy) : new FirestoreStoryStore());

  const engine =
    options?.engine ?? (config.mockEngine ? new MockStoryEngine() : new VertexStoryEngine(config));

  return {
    config,
    store,
    engine,
    policyService: new PolicyService(store, config.policyTtlMs),
    ipCounter: new BoundedRateCounter(config.rateEntryTtlMs, config.rateMapCap),
    uidCounter: new BoundedRateCounter(config.rateEntryTtlMs, config.rateMapCap),
  };
};

export const createApp = (options?: CreateAppOptions) => {
  const services = createServices(options);
  const app = express();
  const sttUpload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 12 * 1024 * 1024 },
  });

  app.disable('x-powered-by');
  app.use(express.json({ limit: '1mb' }));

  app.use(
    rateLimit({
      windowMs: 60_000,
      limit: services.config.globalRateLimitPerMin,
      standardHeaders: true,
      legacyHeaders: false,
      message: {
        ok: false,
        error: 'rate_limited',
        safeMessage: 'Too many requests. Please retry later.',
      },
    }),
  );

  app.use(createAuthMiddleware(services.config));

  app.get('/healthz', (_req: Request, res: Response) => {
    res.status(200).json({ ok: true });
  });

  const handleAction = async (req: Request, res: Response, forcedAction?: StoryAction): Promise<void> => {
    const route = req.path;
    const auditId = randomUUID();
    const fallbackRequestId =
      typeof req.body?.requestId === 'string' && req.body.requestId.trim().length > 0
        ? req.body.requestId
        : auditId;
    const uid = req.fairycraftAuth?.uid ?? 'anonymous';
    let action: StoryAction = forcedAction ?? 'generate';
    let storyId: string | undefined;
    let blocked = false;
    let blockReason: string | undefined;

    const saveAudit = async (clientRequestId?: string) => {
      await services.store.appendAudit({
        auditId,
        clientRequestId,
        uid,
        route,
        action,
        blocked,
        blockReason,
        storyId,
        createdAt: nowIso(),
      });
    };

    try {
      const payload = forcedAction
        ? {
            ...(req.body ?? {}),
            action: forcedAction,
          }
        : req.body;

      const parsed = storyRequestSchema.safeParse(payload);
      if (!parsed.success) {
        blocked = true;
        blockReason = 'invalid_request';
        await saveAudit(typeof payload?.requestId === 'string' ? payload.requestId : undefined);
        res.status(400).json(
          withDebug(
            services.config,
            {
              requestId: fallbackRequestId,
              ok: false,
              error: 'invalid_request',
              safeMessage: 'Request payload is invalid.',
            },
            {
              validationError: parsed.error.issues.map((issue) => ({ path: issue.path.join('.'), code: issue.code })),
            },
          ),
        );
        return;
      }

      const request = parsed.data as StoryRequest;
      action = request.action;
      const requestId = request.requestId ?? auditId;
      storyId = request.storyId;

      res.set('x-fairycraft-action', action);
      res.set('x-fairycraft-service', services.config.serviceName);
      res.set('x-fairycraft-rev', services.config.serviceRevision);
      res.set('x-k-revision', services.config.serviceRevision);

      const { policy, reason: policyReason } = await services.policyService.getRuntimePolicy();
      if (!policy) {
        if (action === 'illustrate') {
          await saveAudit(request.requestId);
          res.status(200).json(
            withDebug(
              services.config,
              {
                requestId,
                ok: true,
                image: placeholderImage(request.prompt),
              },
              { policyStatus: policyReason },
            ),
          );
          return;
        }

        blocked = true;
        blockReason = policyReason ?? 'policy_unavailable';
        await saveAudit(request.requestId);
        res.status(503).json(
          withDebug(
            services.config,
            {
              requestId,
              ok: false,
              error: 'policy_unavailable',
              safeMessage: 'Story generation is temporarily unavailable.',
            },
            { policyStatus: policyReason },
          ),
        );
        return;
      }

      if (jsonSizeKb(request) > policy.max_body_kb) {
        blocked = true;
        blockReason = 'body_too_large';
        await saveAudit(request.requestId);
        res.status(413).json({
          requestId,
          ok: false,
          error: 'body_too_large',
          safeMessage: 'Request is too large.',
        });
        return;
      }

      const candidateInput = [request.selection?.idea ?? '', request.prompt ?? ''].join(' ').trim();
      if (candidateInput.length > policy.max_input_chars) {
        blocked = true;
        blockReason = 'input_too_long';
        await saveAudit(request.requestId);
        res.status(400).json({
          requestId,
          ok: false,
          error: 'input_too_long',
          safeMessage: 'Input text exceeds allowed length.',
        });
        return;
      }

      const ipAllowed = services.ipCounter.consume(req.ip, policy.ip_rate_per_min);
      const uidAllowed = services.uidCounter.consume(uid, policy.uid_rate_per_min);
      if (!ipAllowed || !uidAllowed) {
        blocked = true;
        blockReason = 'rate_limited';
        await saveAudit(request.requestId);
        res.status(429).json({
          requestId,
          ok: false,
          error: 'rate_limited',
          safeMessage: 'Too many requests. Please retry later.',
        });
        return;
      }

      if ((action === 'generate' || action === 'continue') && !policy.enable_story_generation) {
        blocked = true;
        blockReason = 'story_generation_disabled';
        await saveAudit(request.requestId);
        res.status(503).json({
          requestId,
          ok: false,
          error: 'story_generation_disabled',
          safeMessage: 'Story generation is disabled by runtime policy.',
        });
        return;
      }

      if (services.config.geminiModel && !policy.model_allowlist.includes(services.config.geminiModel)) {
        blocked = true;
        blockReason = 'model_not_allowed';
        await saveAudit(request.requestId);
        res.status(503).json({
          requestId,
          ok: false,
          error: 'model_not_allowed',
          safeMessage: 'Current model is blocked by runtime policy.',
        });
        return;
      }

      if (action === 'generate' || action === 'continue') {
        const usage = await services.store.incrementDailyUsage(uid, isoDay(new Date()));
        if (usage > policy.daily_story_limit) {
          blocked = true;
          blockReason = 'daily_limit_reached';
          await saveAudit(request.requestId);
          res.status(429).json({
            requestId,
            ok: false,
            error: 'daily_limit_reached',
            safeMessage: 'Daily story limit reached.',
          });
          return;
        }
      }

      if (action === 'generate') {
        const generated = await runWithTimeout(
          services.engine.generate({ request, policy, uid }),
          policy.request_timeout_ms,
        );

        const createdAt = nowIso();
        const story: StorySession = {
          storyId: generated.storyId,
          uid,
          storyLang: request.storyLang,
          title: generated.title,
          chapters: [generated.chapter],
          createdAt,
          updatedAt: createdAt,
        };

        storyId = story.storyId;
        await services.store.saveStory(story);
        await saveAudit(request.requestId);

        res.status(200).json(
          withDebug(
            services.config,
            {
              requestId,
              ok: true,
              storyId: story.storyId,
              title: story.title,
              chapter: generated.chapter,
              image: generated.image,
            },
            { mode: services.config.mockEngine ? 'mock' : 'vertex' },
          ),
        );
        return;
      }

      if (action === 'continue') {
        if (!request.storyId) {
          blocked = true;
          blockReason = 'story_id_required';
          await saveAudit(request.requestId);
          res.status(400).json({
            requestId,
            ok: false,
            error: 'story_id_required',
            safeMessage: 'storyId is required for continue action.',
          });
          return;
        }

        const story = await services.store.getStory(request.storyId);
        if (!story) {
          blocked = true;
          blockReason = 'story_not_found';
          await saveAudit(request.requestId);
          res.status(404).json({
            requestId,
            ok: false,
            error: 'story_not_found',
            safeMessage: 'Story session not found.',
          });
          return;
        }

        const generated = await runWithTimeout(
          services.engine.continue({ request, policy, story }),
          policy.request_timeout_ms,
        );

        const updatedStory: StorySession = {
          ...story,
          chapters: [...story.chapters, generated.chapter],
          updatedAt: nowIso(),
        };
        await services.store.saveStory(updatedStory);
        await saveAudit(request.requestId);

        res.status(200).json(
          withDebug(
            services.config,
            {
              requestId,
              ok: true,
              storyId: updatedStory.storyId,
              title: updatedStory.title,
              chapter: generated.chapter,
              chapters: updatedStory.chapters,
            },
            { mode: services.config.mockEngine ? 'mock' : 'vertex' },
          ),
        );
        return;
      }

      if (!policy.enable_illustrations) {
        await saveAudit(request.requestId);
        res.status(200).json({
          requestId,
          ok: true,
          storyId: request.storyId,
          image: placeholderImage(request.prompt),
        });
        return;
      }

      const story = request.storyId ? await services.store.getStory(request.storyId) : null;

      try {
        const generated = await runWithTimeout(
          services.engine.illustrate({ request, policy, story }),
          policy.request_timeout_ms,
        );

        await saveAudit(request.requestId);
        res.status(200).json(
          withDebug(
            services.config,
            {
              requestId,
              ok: true,
              storyId: request.storyId,
              image: generated.image,
            },
            { mode: services.config.mockEngine ? 'mock' : 'vertex' },
          ),
        );
        return;
      } catch (error) {
        if (error instanceof EngineUnavailableError) {
          await saveAudit(request.requestId);
          res.status(200).json(
            withDebug(
              services.config,
              {
                requestId,
                ok: true,
                storyId: request.storyId,
                image: placeholderImage(request.prompt),
              },
              { engineError: error.code },
            ),
          );
          return;
        }
        throw error;
      }
    } catch (error) {
      blocked = true;
      blockReason = error instanceof Error ? error.message : 'internal_error';
      await saveAudit(typeof req.body?.requestId === 'string' ? req.body.requestId : undefined);

      res.status(503).json(
        withDebug(
          services.config,
          {
            requestId: fallbackRequestId,
            ok: false,
            error: error instanceof EngineUnavailableError ? 'upstream_unavailable' : 'internal_error',
            safeMessage:
              error instanceof EngineUnavailableError
                ? 'Story backend is temporarily unavailable.'
                : 'Service is temporarily unavailable.',
          },
          {
            reason: blockReason,
          },
        ),
      );
    }
  };

  app.post('/', async (req, res) => {
    await handleAction(req, res);
  });

  app.post('/v1/story/create', async (req, res) => {
    await handleAction(req, res, 'generate');
  });

  app.post('/v1/story/continue', async (req, res) => {
    await handleAction(req, res, 'continue');
  });

  app.post('/v1/story/illustrate', async (req, res) => {
    await handleAction(req, res, 'illustrate');
  });

  app.post('/v1/stt/transcribe', sttUpload.single('file'), async (req: Request, res: Response) => {
    const requestLanguage =
      typeof req.body?.language === 'string' && req.body.language.trim().length > 0
        ? req.body.language.trim()
        : 'auto';
    const responseFormat =
      typeof req.body?.responseFormat === 'string' && req.body.responseFormat.trim().length > 0
        ? req.body.responseFormat.trim()
        : 'json';
    const model =
      typeof req.body?.model === 'string' && req.body.model.trim().length > 0
        ? req.body.model.trim()
        : 'stt-flagship-v1';

    if (!services.ipCounter.consume(`stt:${req.ip}`, services.config.sttRateLimitPerMin)) {
      res.status(429).json({
        ok: false,
        error: 'rate_limited',
        safeMessage: 'Too many STT requests. Please retry later.',
      });
      return;
    }

    if (!services.config.voicemakerApiKey.trim()) {
      res.status(503).json({
        ok: false,
        error: 'stt_unavailable',
        safeMessage: 'Speech recognition service is not configured.',
      });
      return;
    }

    if (!req.file || req.file.size <= 0) {
      res.status(400).json({
        ok: false,
        error: 'audio_required',
        safeMessage: 'Audio file is required.',
      });
      return;
    }

    try {
      const formData = new FormData();
      formData.append('model', model);
      formData.append('language', requestLanguage);
      formData.append('responseFormat', responseFormat);
      formData.append('includeSubtitle', 'false');
      formData.append('tagAudioEvents', 'false');
      formData.append(
        'file',
        new Blob([new Uint8Array(req.file.buffer)], {
          type: req.file.mimetype || 'audio/wav',
        }),
        req.file.originalname || 'recording.wav',
      );

      const upstreamResponse = await fetch('https://developer.voicemaker.in/api/v1/speech-to-text', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${services.config.voicemakerApiKey}`,
        },
        body: formData,
      });

      const rawText = await upstreamResponse.text();
      let parsed: Record<string, unknown> = {};
      try {
        parsed = rawText.trim().length > 0 ? (JSON.parse(rawText) as Record<string, unknown>) : {};
      } catch (_error) {
        parsed = {};
      }

      if (!upstreamResponse.ok) {
        const message =
          typeof parsed.message === 'string'
            ? parsed.message
            : typeof parsed.error === 'string'
              ? parsed.error
              : 'Speech recognition request failed.';
        res.status(502).json({
          ok: false,
          error: 'stt_upstream_failed',
          safeMessage: message,
        });
        return;
      }

      const success = parsed.success === true;
      const isProcessing = parsed.isProcessing === true;
      const data =
        typeof parsed.data === 'object' && parsed.data !== null
          ? (parsed.data as Record<string, unknown>)
          : {};
      const generatedText =
        typeof data.generatedText === 'string' ? data.generatedText.trim() : '';
      const detectedLanguage =
        typeof data.language === 'string' ? data.language : requestLanguage;

      res.status(200).json({
        ok: success,
        isProcessing,
        text: generatedText,
        language: detectedLanguage,
        charge: data.charge,
        usedChars: parsed.usedChars,
        remainChars: parsed.remainChars,
        ...(services.config.isProduction ? {} : { raw: parsed }),
      });
    } catch (_error) {
      res.status(503).json({
        ok: false,
        error: 'stt_proxy_unavailable',
        safeMessage: 'Speech recognition service is temporarily unavailable.',
      });
    }
  });

  return { app, services };
};
