import { createHash, randomUUID } from 'node:crypto';
import type { IncomingMessage, Server as HttpServer } from 'node:http';

import express, { type Request, type Response } from 'express';
import rateLimit from 'express-rate-limit';
import multer from 'multer';

import { loadConfig, type AppConfig } from './config';
import { adminTestInputSchema, storyRequestSchema } from './schemas';
import { EngineUnavailableError, MockStoryEngine, VertexStoryEngine, type StoryEngine } from './services/engine';
import { createAuthMiddleware } from './middleware/auth';
import { defaultRuntimePolicy, PolicyService } from './services/policy';
import {
  buildComposedPayload,
  decisionForAdminInput,
  evaluatePolicyDecision,
  mapStoryRequestToAdminInput,
  PolicyV1Service,
} from './services/policyV1';
import { BoundedRateCounter } from './services/rateLimiter';
import { FirestoreStoryStore, InMemoryStoryStore, type StoryStore } from './services/store';
import {
  PerUserConcurrencyLimiter,
  VoicemakerHttpError,
  VoicemakerService,
} from './services/voicemaker';
import type {
  AdminTestInput,
  RuntimePolicy,
  StoryAction,
  StoryRequest,
  StoryResponse,
  StorySession,
} from './types';
import { attachTtsStreamProxy } from './ws/ttsStreamProxy';

interface AppServices {
  config: AppConfig;
  store: StoryStore;
  policyService: PolicyService;
  policyV1Service: PolicyV1Service;
  engine: StoryEngine;
  ipCounter: BoundedRateCounter;
  uidCounter: BoundedRateCounter;
  voicemakerService: VoicemakerService;
  ttsConcurrencyLimiter: PerUserConcurrencyLimiter;
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

const hashUserId = (uid: string): string =>
  createHash('sha256').update(uid, 'utf8').digest('hex').slice(0, 24);

const currentProvider = (config: AppConfig): 'gpt' | 'vertex' | 'mock' => {
  if (config.mockEngine) {
    return 'mock';
  }
  return config.geminiModel?.toLowerCase().includes('gpt') ? 'gpt' : 'vertex';
};

const trimForSummary = (value: string, maxLength = 120): string => {
  const clean = value.trim();
  if (clean.length <= maxLength) {
    return clean;
  }
  return `${clean.slice(0, maxLength)}...`;
};

const storyLengthRank = (value: string | undefined): number => {
  if (value === 'long') {
    return 3;
  }
  if (value === 'medium') {
    return 2;
  }
  return 1;
};

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
const MAX_PARALLEL_TTS_PER_USER = 3;

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
    policyV1Service: new PolicyV1Service(store, config.policyTtlMs),
    ipCounter: new BoundedRateCounter(config.rateEntryTtlMs, config.rateMapCap),
    uidCounter: new BoundedRateCounter(config.rateEntryTtlMs, config.rateMapCap),
    voicemakerService: new VoicemakerService(config.voicemakerApiKey),
    ttsConcurrencyLimiter: new PerUserConcurrencyLimiter(MAX_PARALLEL_TTS_PER_USER),
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

  const handleAdminDryRun = async (req: Request, res: Response): Promise<void> => {
    if (services.config.authRequired && req.fairycraftAuth?.isAdmin !== true) {
      res.status(403).json({
        ok: false,
        error: 'admin_required',
        safeMessage: 'Admin privileges are required for this endpoint.',
      });
      return;
    }

    const parsed = adminTestInputSchema.safeParse(req.body ?? {});
    if (!parsed.success) {
      res.status(400).json({
        ok: false,
        error: 'invalid_request',
        safeMessage: 'Admin dry-run payload is invalid.',
        issues: parsed.error.issues.map((issue) => ({
          path: issue.path.join('.'),
          code: issue.code,
        })),
      });
      return;
    }

    const input = parsed.data as AdminTestInput;
    const resolution = await services.policyV1Service.resolveForAdminInput(input);
    const decision = decisionForAdminInput(resolution.policy, input);
    const provider = currentProvider(services.config);
    const composedPayload = buildComposedPayload({
      input,
      resolution,
      provider,
    });

    const payload = {
      ok: decision.status === 'ok',
      decision,
      effectivePolicyId: resolution.policy.id,
      templateIds: resolution.templates.map((template) => template.id),
      composedPayload,
    };

    const runRecord = {
      runId: randomUUID(),
      createdAt: nowIso(),
      adminUid: req.fairycraftAuth?.uid ?? 'anonymous',
      inputPayload: input as unknown as Record<string, unknown>,
      composedPayload: composedPayload as Record<string, unknown>,
      response: payload as unknown as Record<string, unknown>,
      status: decision.status === 'blocked' ? 'blocked' : 'ok',
    } as const;

    try {
      await services.store.appendTestRun(runRecord);
    } catch (error) {
      console.warn('Failed to persist test run log', error);
    }

    res.status(200).json(payload);
  };

  const handleAction = async (req: Request, res: Response, forcedAction?: StoryAction): Promise<void> => {
    const route = req.path;
    const auditId = randomUUID();
    const startedAtMs = Date.now();
    const fallbackRequestId =
      typeof req.body?.requestId === 'string' && req.body.requestId.trim().length > 0
        ? req.body.requestId
        : auditId;
    const uid = req.fairycraftAuth?.uid ?? 'anonymous';
    let action: StoryAction = forcedAction ?? 'generate';
    let storyId: string | undefined;
    let blocked = false;
    let blockReason: string | undefined;
    let generationStatus: 'ok' | 'blocked' | 'error' = 'error';
    let generationErrorCode: string | undefined;
    let generationErrorMessage: string | undefined;
    let effectivePolicyId = 'default_policy';
    let templateIdsUsed: string[] = [];
    let requestTier = 'free';
    let requestLanguage = 'en';
    let requestAge = 8;
    let requestSummary: Record<string, unknown> = {};
    const provider = currentProvider(services.config);

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

    const saveGenerationLog = async (): Promise<void> => {
      const logRecord = {
        logId: randomUUID(),
        createdAt: nowIso(),
        userIdHash: hashUserId(uid),
        tier: requestTier,
        language: requestLanguage,
        age: requestAge,
        requestSummary,
        effectivePolicyId,
        templateIdsUsed,
        status: generationStatus,
        provider,
        latencyMs: Date.now() - startedAtMs,
        errorCode: generationErrorCode,
        errorMessage: generationErrorMessage,
      };

      try {
        await services.store.appendGenerationLog(logRecord);
      } catch (error) {
        console.warn('Failed to persist generation log', error);
      }
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
        generationStatus = 'blocked';
        generationErrorCode = 'invalid_request';
        generationErrorMessage = 'Request payload is invalid.';
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

      const adminInput = mapStoryRequestToAdminInput(request);
      requestTier = adminInput.tier;
      requestLanguage = adminInput.language;
      requestAge = adminInput.age;
      requestSummary = {
        action,
        age: adminInput.age,
        tier: adminInput.tier,
        language: adminInput.language,
        storyLength: adminInput.length,
        complexity: adminInput.complexity,
        creativity: adminInput.creativity,
        heroType: adminInput.heroType,
        genre: adminInput.genre,
        location: trimForSummary(adminInput.location, 64),
        ideaSample: trimForSummary(adminInput.storyIdea, 180),
      };

      const effectiveBundle = await services.policyV1Service.resolveForStoryRequest(request);
      effectivePolicyId = effectiveBundle.policy.id;
      templateIdsUsed = effectiveBundle.templates.map((template) => template.id);

      const policyDecision = evaluatePolicyDecision({
        policy: effectiveBundle.policy,
        sourceText: adminInput.storyIdea,
        parentControls: adminInput.parentalControls,
      });
      if (policyDecision.status === 'blocked') {
        blocked = true;
        blockReason = 'policy_blocked';
        generationStatus = 'blocked';
        generationErrorCode = 'policy_blocked';
        generationErrorMessage = policyDecision.reasons.join(', ');
        await saveAudit(request.requestId);
        res.status(403).json({
          requestId,
          ok: false,
          error: 'policy_blocked',
          safeMessage: 'Request is blocked by safety policy.',
          reasons: policyDecision.reasons,
        });
        return;
      }

      if (storyLengthRank(request.storyLength) > storyLengthRank(effectiveBundle.tier.limits.maxStoryLength)) {
        blocked = true;
        blockReason = 'tier_length_limit';
        generationStatus = 'blocked';
        generationErrorCode = 'tier_length_limit';
        generationErrorMessage = `Allowed max length for tier is ${effectiveBundle.tier.limits.maxStoryLength}`;
        await saveAudit(request.requestId);
        res.status(403).json({
          requestId,
          ok: false,
          error: 'tier_length_limit',
          safeMessage: `Tier limit allows up to ${effectiveBundle.tier.limits.maxStoryLength} stories.`,
        });
        return;
      }

      const { policy, reason: policyReason } = await services.policyService.getRuntimePolicy();
      if (!policy) {
        if (action === 'illustrate') {
          generationStatus = 'ok';
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
        generationStatus = 'blocked';
        generationErrorCode = 'policy_unavailable';
        generationErrorMessage = policyReason ?? 'policy_unavailable';
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
        generationStatus = 'blocked';
        generationErrorCode = 'body_too_large';
        generationErrorMessage = 'Request body exceeds max size.';
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
        generationStatus = 'blocked';
        generationErrorCode = 'input_too_long';
        generationErrorMessage = 'Input text exceeds allowed length.';
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
        generationStatus = 'blocked';
        generationErrorCode = 'rate_limited';
        generationErrorMessage = 'Rate limit exceeded.';
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
        generationStatus = 'blocked';
        generationErrorCode = 'story_generation_disabled';
        generationErrorMessage = 'Story generation disabled by runtime policy.';
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
        generationStatus = 'blocked';
        generationErrorCode = 'model_not_allowed';
        generationErrorMessage = 'Current model is blocked by runtime policy.';
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
        const effectiveDailyLimit = Math.min(
          policy.daily_story_limit,
          effectiveBundle.tier.limits.storiesPerDay,
        );
        const usage = await services.store.incrementDailyUsage(uid, isoDay(new Date()));
        if (usage > effectiveDailyLimit) {
          blocked = true;
          blockReason = 'daily_limit_reached';
          generationStatus = 'blocked';
          generationErrorCode = 'daily_limit_reached';
          generationErrorMessage = `Daily limit reached (${effectiveDailyLimit}).`;
          await saveAudit(request.requestId);
          res.status(429).json({
            requestId,
            ok: false,
            error: 'daily_limit_reached',
            safeMessage: 'Daily story limit reached for current subscription tier.',
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
        generationStatus = 'ok';

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
          generationStatus = 'blocked';
          generationErrorCode = 'story_id_required';
          generationErrorMessage = 'storyId is required for continue action.';
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
          generationStatus = 'blocked';
          generationErrorCode = 'story_not_found';
          generationErrorMessage = 'Story session not found.';
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
        generationStatus = 'ok';

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

      if (
        !policy.enable_illustrations ||
        !effectiveBundle.policy.imageRules.allowImages ||
        !adminInput.illustrationsEnabled ||
        effectiveBundle.tier.limits.imagesPerStory <= 0
      ) {
        generationStatus = 'ok';
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
        generationStatus = 'ok';
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
          generationStatus = 'ok';
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
      generationStatus = 'error';
      generationErrorCode = error instanceof EngineUnavailableError ? 'upstream_unavailable' : 'internal_error';
      generationErrorMessage = error instanceof Error ? error.message : 'internal_error';
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
    } finally {
      await saveGenerationLog();
    }
  };

  app.post('/', async (req, res) => {
    await handleAction(req, res);
  });

  app.post('/v1/admin/dry-run', async (req: Request, res: Response) => {
    await handleAdminDryRun(req, res);
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

  const resolveRequestUserKey = (req: Request): string => {
    const uid = req.fairycraftAuth?.uid?.trim();
    if (uid) {
      return `uid:${uid}`;
    }
    return `ip:${req.ip || 'unknown'}`;
  };

  const resolveUpgradeUserKey = (request: IncomingMessage): string => {
    const claimedUser =
      typeof request.headers['x-fairycraft-user'] === 'string'
        ? request.headers['x-fairycraft-user'].trim()
        : '';
    if (claimedUser) {
      return `uid:${claimedUser}`;
    }

    const forwardedHeader = request.headers['x-forwarded-for'];
    const forwardedIp =
      typeof forwardedHeader === 'string'
        ? forwardedHeader.split(',')[0]?.trim()
        : Array.isArray(forwardedHeader)
          ? forwardedHeader[0]?.trim()
          : '';
    const socketIp = request.socket.remoteAddress?.trim() ?? '';
    return `ip:${forwardedIp || socketIp || 'unknown'}`;
  };

  const handleStt = async (req: Request, res: Response): Promise<void> => {
    if (!services.ipCounter.consume(`stt:${req.ip}`, services.config.sttRateLimitPerMin)) {
      res.status(429).json({
        ok: false,
        error: 'rate_limited',
        safeMessage: 'Too many STT requests. Please retry later.',
      });
      return;
    }

    try {
      const input = services.voicemakerService.normalizeSttRequest(req.body ?? {});
      const response = await services.voicemakerService.transcribeAudio(req.file, input);

      console.info(
        `[voicemaker:stt] user=${resolveRequestUserKey(req)} usedChars=${response.usedChars ?? 0} status=${response.status}`,
      );

      res.status(200).json({
        ok: response.status !== 'failed',
        generatedText: response.generatedText,
        status: response.status,
        taskId: response.taskId,
        detectedLanguage: response.detectedLanguage,
        usedChars: response.usedChars,
        remainChars: response.remainChars,
      });
    } catch (error) {
      if (error instanceof VoicemakerHttpError) {
        res.status(error.statusCode).json({
          ok: false,
          error: error.errorCode,
          safeMessage: error.safeMessage,
        });
        return;
      }

      if (error instanceof Error && error.message === 'VOICEMAKER_API_KEY missing') {
        res.status(503).json({
          ok: false,
          error: 'stt_unavailable',
          safeMessage: 'Speech recognition service is not configured.',
        });
        return;
      }

      res.status(503).json({
        ok: false,
        error: 'stt_proxy_unavailable',
        safeMessage: 'Speech recognition service is temporarily unavailable.',
      });
    }
  };

  const handleTts = async (req: Request, res: Response): Promise<void> => {
    const userKey = resolveRequestUserKey(req);
    if (!services.ttsConcurrencyLimiter.tryAcquire(userKey)) {
      res.status(429).json({
        ok: false,
        error: 'tts_parallel_limit_reached',
        safeMessage: 'Too many concurrent narration requests. Please wait for current audio generation to finish.',
      });
      return;
    }

    try {
      const normalizedRequest = services.voicemakerService.normalizeTtsRequest(req.body ?? {});
      const generated = await services.voicemakerService.generateTtsAudio(normalizedRequest);
      const usedChars = generated.usedChars ?? normalizedRequest.text.length;
      const remainChars = generated.remainChars;
      console.info(`[voicemaker:tts] user=${userKey} usedChars=${usedChars}`);

      if (normalizedRequest.returnBase64) {
        res.status(200).json({
          ok: true,
          audioBase64: generated.audioBuffer.toString('base64'),
          mimeType: generated.mimeType,
          usedChars,
          remainChars,
        });
        return;
      }

      res.status(200);
      res.set('Content-Type', generated.mimeType || 'audio/mpeg');
      res.set('Content-Length', String(generated.audioBuffer.length));
      res.set('X-Used-Chars', String(usedChars));
      if (remainChars != null) {
        res.set('X-Remain-Chars', String(remainChars));
      }
      res.send(generated.audioBuffer);
    } catch (error) {
      if (error instanceof VoicemakerHttpError) {
        res.status(error.statusCode).json({
          ok: false,
          error: error.errorCode,
          safeMessage: error.safeMessage,
        });
        return;
      }

      if (error instanceof Error && error.message === 'VOICEMAKER_API_KEY missing') {
        res.status(503).json({
          ok: false,
          error: 'tts_unavailable',
          safeMessage: 'TTS service is not configured.',
        });
        return;
      }

      res.status(503).json({
        ok: false,
        error: 'tts_proxy_unavailable',
        safeMessage: 'TTS provider is temporarily unavailable.',
      });
    } finally {
      services.ttsConcurrencyLimiter.release(userKey);
    }
  };

  const handleListVoices = async (languageCode: string, res: Response): Promise<void> => {
    try {
      const response = await services.voicemakerService.listVoices(languageCode);
      res.status(200).json({
        ok: true,
        language: languageCode,
        cached: response.cached,
        voices: response.voices,
      });
    } catch (error) {
      if (error instanceof VoicemakerHttpError) {
        res.status(error.statusCode).json({
          ok: false,
          error: error.errorCode,
          safeMessage: error.safeMessage,
        });
        return;
      }

      if (error instanceof Error && error.message === 'VOICEMAKER_API_KEY missing') {
        res.status(503).json({
          ok: false,
          error: 'tts_unavailable',
          safeMessage: 'TTS service is not configured.',
        });
        return;
      }

      console.error('[voicemaker:voices] unexpected error', error);
      res.status(503).json({
        ok: false,
        error: 'tts_proxy_unavailable',
        safeMessage: 'Failed to load voices.',
      });
    }
  };

  app.get('/v1/tts/stream', (_req: Request, res: Response) => {
    res.status(426).json({
      ok: false,
      error: 'upgrade_required',
      safeMessage: 'Use WebSocket protocol for this endpoint.',
    });
  });

  app.post('/v1/stt', sttUpload.single('file'), async (req: Request, res: Response) => {
    await handleStt(req, res);
  });

  app.post('/v1/stt/transcribe', sttUpload.single('file'), async (req: Request, res: Response) => {
    await handleStt(req, res);
  });

  app.post('/v1/tts', async (req: Request, res: Response) => {
    await handleTts(req, res);
  });

  app.post('/v1/tts/voicemaker', async (req: Request, res: Response) => {
    await handleTts(req, res);
  });

  app.get('/v1/tts/voices', async (req: Request, res: Response) => {
    const languageCode =
      typeof req.query.language === 'string' && req.query.language.trim().length > 0
        ? req.query.language.trim()
        : 'en-US';
    await handleListVoices(languageCode, res);
  });

  app.post('/v1/tts/voicemaker/voices', async (req: Request, res: Response) => {
    const languageCode =
      typeof req.body?.language === 'string' && req.body.language.trim().length > 0
        ? req.body.language.trim()
        : typeof req.body?.languageCode === 'string' && req.body.languageCode.trim().length > 0
          ? req.body.languageCode.trim()
          : 'en-US';
    await handleListVoices(languageCode, res);
  });

  const attachVoicemakerTtsStreamProxy = (server: HttpServer): void => {
    attachTtsStreamProxy({
      server,
      voicemakerService: services.voicemakerService,
      limiter: services.ttsConcurrencyLimiter,
      resolveUserKey: resolveUpgradeUserKey,
      onError: (message, error) => {
        console.error(`[voicemaker:stream] ${message}`, error);
      },
    });
  };

  return { app, services, attachVoicemakerTtsStreamProxy };
};
