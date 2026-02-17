import request from 'supertest';
import { describe, expect, it } from 'vitest';

import { createApp } from '../src/app';
import type { AppConfig } from '../src/config';
import { defaultRuntimePolicy } from '../src/services/policy';
import { buildComposedPayload, PolicyV1Service } from '../src/services/policyV1';
import { InMemoryStoryStore } from '../src/services/store';
import type { AdminTestInput } from '../src/types';

const baseConfig: AppConfig = {
  port: 8080,
  nodeEnv: 'test',
  isProduction: false,
  authRequired: false,
  appCheckRequired: false,
  mockEngine: true,
  storeDisabled: true,
  policyTtlMs: 60_000,
  requestTimeoutMs: 20_000,
  globalRateLimitPerMin: 500,
  rateEntryTtlMs: 120_000,
  rateMapCap: 1000,
  defaultPolicyModel: 'gemini-2.0-flash',
  serviceName: 'story-agent-test',
  serviceRevision: 'test-rev',
  configurationName: 'test-config',
  voicemakerApiKey: '',
  sttRateLimitPerMin: 30,
};

class MissingAllowPersonalNamesStore extends InMemoryStoryStore {
  constructor() {
    super(defaultRuntimePolicy);
  }

  override async listPoliciesV1() {
    return [
      {
        id: 'legacy_policy_without_allow_names',
        data: {
          active: true,
          scope: { ageMin: 3, ageMax: 12, language: '*', tier: '*' },
          contentRules: {
            safeModeDefault: true,
            disallowViolence: true,
            disallowDrugs: true,
            disallowHate: true,
            disallowSexualContent: true,
            disallowReligiousPolitical: true,
            requireParentConfirmationForOlder: true,
            disallowScary: true,
            customBannedWords: [],
          },
          promptConstraints: {
            maxTokensHint: 700,
            maxCharsHint: 4500,
            enforceStructure: true,
            readingLevel: 'simple',
          },
          imageRules: {
            allowImages: true,
            allowedImageStyles: ['storybook-watercolor'],
          },
          versionStamp: 'legacy-v1',
        },
      },
    ];
  }
}

describe('story-agent', () => {
  it('GET /healthz returns ok', async () => {
    const { app } = createApp({ config: baseConfig, store: new InMemoryStoryStore(defaultRuntimePolicy) });
    const response = await request(app).get('/healthz');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ ok: true });
  });

  it('POST /v1/story/create generates mock story', async () => {
    const { app } = createApp({ config: baseConfig, store: new InMemoryStoryStore(defaultRuntimePolicy) });
    const response = await request(app).post('/v1/story/create').send({
      action: 'generate',
      requestId: 'client-1',
      storyLang: 'en',
      selection: { hero: 'Mila', location: 'sunny valley', storyType: 'adventure' },
      image: { enabled: true },
    });

    expect(response.status).toBe(200);
    expect(response.body.ok).toBe(true);
    expect(response.body.storyId).toBeTruthy();
    expect(response.body.chapter?.index).toBe(1);
  });

  it('POST /v1/story/continue continues mock story', async () => {
    const store = new InMemoryStoryStore(defaultRuntimePolicy);
    const { app } = createApp({ config: baseConfig, store });

    const createResponse = await request(app).post('/v1/story/create').send({
      action: 'generate',
      requestId: 'client-2',
      storyLang: 'en',
      selection: { hero: 'Kai' },
    });

    const storyId = createResponse.body.storyId as string;

    const continueResponse = await request(app).post('/v1/story/continue').send({
      action: 'continue',
      requestId: 'client-3',
      storyLang: 'en',
      storyId,
      choice: { id: 'follow_lights' },
    });

    expect(continueResponse.status).toBe(200);
    expect(continueResponse.body.ok).toBe(true);
    expect(continueResponse.body.chapter?.index).toBe(2);
    expect(continueResponse.body.chapters?.length).toBe(2);
  });

  it('POST /v1/story/illustrate returns placeholder with 200', async () => {
    const { app } = createApp({ config: baseConfig, store: new InMemoryStoryStore(defaultRuntimePolicy) });

    const response = await request(app).post('/v1/story/illustrate').send({
      action: 'illustrate',
      requestId: 'client-4',
      storyLang: 'en',
      prompt: 'A friendly dragon',
    });

    expect(response.status).toBe(200);
    expect(response.body.ok).toBe(true);
    expect(response.body.image?.disabled).toBe(true);
  });

  it('POST /v1/admin/dry-run returns composed payload and decision', async () => {
    const { app } = createApp({ config: baseConfig, store: new InMemoryStoryStore(defaultRuntimePolicy) });
    const response = await request(app).post('/v1/admin/dry-run').send({
      age: 8,
      tier: 'free',
      language: 'en',
      storyIdea: 'A kind dragon helps children find a lost kite.',
      heroType: 'boy',
      heroAge: 8,
      location: 'park',
      genre: 'adventure',
      length: 'short',
      complexity: 'simple',
      illustrationsEnabled: true,
      familyMembers: { mom: 1, dad: 1 },
      creativity: 'normal',
      parentalControls: {
        safeMode: true,
        disableScaryContent: true,
        requireParentConfirmationForOlder: true,
      },
    });

    expect(response.status).toBe(200);
    expect(response.body.ok).toBe(true);
    expect(response.body.decision?.status).toBe('ok');
    expect(response.body.composedPayload).toBeTruthy();
  });

  it('POST /v1/admin/dry-run accepts family names and sibling lists', async () => {
    const { app } = createApp({ config: baseConfig, store: new InMemoryStoryStore(defaultRuntimePolicy) });
    const response = await request(app).post('/v1/admin/dry-run').send({
      age: 8,
      tier: 'free',
      language: 'en',
      storyIdea: 'A child explores a magical forest.',
      heroType: 'girl',
      heroAge: 8,
      location: 'forest',
      genre: 'adventure',
      length: 'short',
      complexity: 'simple',
      illustrationsEnabled: true,
      familyMembers: { mom: 1, dad: 1, brother: 1 },
      familyNames: { mom: 'Anna' },
      brothers: ['Tom'],
      sisters: ['Lia'],
      creativity: 'normal',
      parentalControls: {
        safeMode: true,
        disableScaryContent: true,
        requireParentConfirmationForOlder: true,
      },
    });

    expect(response.status).toBe(200);
    expect(response.body.ok).toBe(true);
  });

  it('defaults allowPersonalNames=true when field is missing in policy doc', async () => {
    const service = new PolicyV1Service(
      new MissingAllowPersonalNamesStore(),
      60_000,
    );
    const input: AdminTestInput = {
      age: 8,
      tier: 'free',
      language: 'en',
      storyIdea: 'A child explores a magical forest.',
      heroType: 'girl',
      heroAge: 8,
      location: 'forest',
      genre: 'adventure',
      length: 'short',
      complexity: 'simple',
      illustrationsEnabled: true,
      familyMembers: { mom: 1, dad: 1 },
      creativity: 'normal',
      parentalControls: {
        safeMode: true,
        disableScaryContent: true,
        requireParentConfirmationForOlder: true,
      },
    };

    const resolved = await service.resolveForAdminInput(input);
    expect(resolved.policy.contentRules.allowPersonalNames).toBe(true);
  });

  it('composed payload includes names only when allowPersonalNames=true', async () => {
    const service = new PolicyV1Service(
      new InMemoryStoryStore(defaultRuntimePolicy),
      60_000,
    );
    const input: AdminTestInput = {
      age: 8,
      tier: 'free',
      language: 'en',
      storyIdea: 'A family picnic near a lake.',
      heroType: 'boy',
      heroAge: 8,
      location: 'lake',
      genre: 'adventure',
      length: 'short',
      complexity: 'simple',
      illustrationsEnabled: true,
      familyMembers: { mom: 1, dad: 1, brother: 1, sister: 1 },
      familyNames: { mom: 'Anna' },
      brothers: ['Tom'],
      sisters: ['Lia'],
      creativity: 'normal',
      parentalControls: {
        safeMode: true,
        disableScaryContent: true,
        requireParentConfirmationForOlder: true,
      },
    };

    const resolved = await service.resolveForAdminInput(input);
    const withNames = buildComposedPayload({
      input,
      resolution: resolved,
      provider: 'mock',
    });
    const withNamesSummary = String(
      (withNames.prompt as Record<string, unknown>).userSummary,
    );

    expect(withNamesSummary).toContain('Family roles: mom Anna, dad');
    expect(withNamesSummary).toContain('Brothers: Tom');
    expect(withNamesSummary).toContain('Sisters: Lia');

    const withoutNames = buildComposedPayload({
      input,
      resolution: {
        ...resolved,
        policy: {
          ...resolved.policy,
          contentRules: {
            ...resolved.policy.contentRules,
            allowPersonalNames: false,
          },
        },
      },
      provider: 'mock',
    });
    const withoutNamesSummary = String(
      (withoutNames.prompt as Record<string, unknown>).userSummary,
    );

    expect(withoutNamesSummary).toContain('Family roles: mom, dad');
    expect(withoutNamesSummary).toContain('Brothers count: 1');
    expect(withoutNamesSummary).toContain('Sisters count: 1');
    expect(withoutNamesSummary).not.toContain('Anna');
    expect(withoutNamesSummary).not.toContain('Tom');
    expect(withoutNamesSummary).not.toContain('Lia');
  });

  it('POST /v1/story/create is blocked by policy when banned content is present', async () => {
    const { app } = createApp({ config: baseConfig, store: new InMemoryStoryStore(defaultRuntimePolicy) });
    const response = await request(app).post('/v1/story/create').send({
      action: 'generate',
      requestId: 'blocked-1',
      storyLang: 'en',
      selection: { idea: 'A child plans a murder mystery with real blood.' },
      image: { enabled: true },
    });

    expect(response.status).toBe(403);
    expect(response.body.ok).toBe(false);
    expect(response.body.error).toBe('policy_blocked');
  });

  it('generation logs keep requestSummary sanitized from personal names', async () => {
    const store = new InMemoryStoryStore(defaultRuntimePolicy);
    const { app } = createApp({ config: baseConfig, store });

    const response = await request(app).post('/v1/story/create').send({
      action: 'generate',
      requestId: 'client-sanitized-1',
      storyLang: 'en',
      selection: {
        hero: 'Mila',
        idea: 'A quiet evening story.',
      },
      familyMembers: { mom: 1, brother: 1 },
      familyNames: { mom: 'Anna' },
      brothers: ['Tom'],
      image: { enabled: true },
    });

    expect(response.status).toBe(200);

    const logs = store.listGenerationLogs();
    expect(logs.length).toBeGreaterThan(0);

    const summary = logs[0].requestSummary as Record<string, unknown>;
    expect(summary.hasFamilyNames).toBe(true);
    expect(summary.brothersCount).toBe(1);
    expect(summary.sistersCount).toBe(0);

    const serializedSummary = JSON.stringify(summary);
    expect(serializedSummary).not.toContain('Anna');
    expect(serializedSummary).not.toContain('Tom');
    expect(serializedSummary).not.toContain('Mila');
  });

  it('server generates auditId independent from client requestId', async () => {
    const store = new InMemoryStoryStore(defaultRuntimePolicy);
    const { app } = createApp({ config: baseConfig, store });

    const clientRequestId = 'client-request-fixed';
    await request(app).post('/v1/story/create').send({
      action: 'generate',
      requestId: clientRequestId,
      storyLang: 'en',
    });

    const audits = store.listAudits();
    expect(audits.length).toBeGreaterThan(0);
    expect(audits[0].clientRequestId).toBe(clientRequestId);
    expect(audits[0].auditId).not.toBe(clientRequestId);
  });

  it('POST /v1/tts validates empty text', async () => {
    const { app } = createApp({ config: baseConfig, store: new InMemoryStoryStore(defaultRuntimePolicy) });
    const response = await request(app).post('/v1/tts').send({
      text: '   ',
    });

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('invalid_tts_request');
  });

  it('POST /v1/tts returns unavailable when voicemaker key is missing', async () => {
    const { app } = createApp({ config: baseConfig, store: new InMemoryStoryStore(defaultRuntimePolicy) });
    const response = await request(app).post('/v1/tts').send({
      text: 'Hello world',
      voiceId: 'ai3-Jony',
      languageCode: 'en-US',
      speed: 0,
      pitch: 0,
      volume: 0,
    });

    expect(response.status).toBe(503);
    expect(response.body.error).toBe('tts_unavailable');
  });

  it('POST /v1/stt returns audio_required without file', async () => {
    const { app } = createApp({ config: baseConfig, store: new InMemoryStoryStore(defaultRuntimePolicy) });
    const response = await request(app).post('/v1/stt').field('language', 'auto');

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('audio_required');
  });

  it('GET /v1/tts/voices returns unavailable when voicemaker key is missing', async () => {
    const { app } = createApp({ config: baseConfig, store: new InMemoryStoryStore(defaultRuntimePolicy) });
    const response = await request(app).get('/v1/tts/voices?language=en-US');

    expect(response.status).toBe(503);
    expect(response.body.error).toBe('tts_unavailable');
  });
});
