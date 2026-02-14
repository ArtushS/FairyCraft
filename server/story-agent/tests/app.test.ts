import request from 'supertest';
import { describe, expect, it } from 'vitest';

import { createApp } from '../src/app';
import type { AppConfig } from '../src/config';
import { defaultRuntimePolicy } from '../src/services/policy';
import { InMemoryStoryStore } from '../src/services/store';

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
};

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
});
