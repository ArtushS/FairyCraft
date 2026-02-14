"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const supertest_1 = __importDefault(require("supertest"));
const vitest_1 = require("vitest");
const app_1 = require("../src/app");
const policy_1 = require("../src/services/policy");
const store_1 = require("../src/services/store");
const baseConfig = {
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
(0, vitest_1.describe)('story-agent', () => {
    (0, vitest_1.it)('GET /healthz returns ok', async () => {
        const { app } = (0, app_1.createApp)({ config: baseConfig, store: new store_1.InMemoryStoryStore(policy_1.defaultRuntimePolicy) });
        const response = await (0, supertest_1.default)(app).get('/healthz');
        (0, vitest_1.expect)(response.status).toBe(200);
        (0, vitest_1.expect)(response.body).toEqual({ ok: true });
    });
    (0, vitest_1.it)('POST /v1/story/create generates mock story', async () => {
        const { app } = (0, app_1.createApp)({ config: baseConfig, store: new store_1.InMemoryStoryStore(policy_1.defaultRuntimePolicy) });
        const response = await (0, supertest_1.default)(app).post('/v1/story/create').send({
            action: 'generate',
            requestId: 'client-1',
            storyLang: 'en',
            selection: { hero: 'Mila', location: 'sunny valley', storyType: 'adventure' },
            image: { enabled: true },
        });
        (0, vitest_1.expect)(response.status).toBe(200);
        (0, vitest_1.expect)(response.body.ok).toBe(true);
        (0, vitest_1.expect)(response.body.storyId).toBeTruthy();
        (0, vitest_1.expect)(response.body.chapter?.index).toBe(1);
    });
    (0, vitest_1.it)('POST /v1/story/continue continues mock story', async () => {
        const store = new store_1.InMemoryStoryStore(policy_1.defaultRuntimePolicy);
        const { app } = (0, app_1.createApp)({ config: baseConfig, store });
        const createResponse = await (0, supertest_1.default)(app).post('/v1/story/create').send({
            action: 'generate',
            requestId: 'client-2',
            storyLang: 'en',
            selection: { hero: 'Kai' },
        });
        const storyId = createResponse.body.storyId;
        const continueResponse = await (0, supertest_1.default)(app).post('/v1/story/continue').send({
            action: 'continue',
            requestId: 'client-3',
            storyLang: 'en',
            storyId,
            choice: { id: 'follow_lights' },
        });
        (0, vitest_1.expect)(continueResponse.status).toBe(200);
        (0, vitest_1.expect)(continueResponse.body.ok).toBe(true);
        (0, vitest_1.expect)(continueResponse.body.chapter?.index).toBe(2);
        (0, vitest_1.expect)(continueResponse.body.chapters?.length).toBe(2);
    });
    (0, vitest_1.it)('POST /v1/story/illustrate returns placeholder with 200', async () => {
        const { app } = (0, app_1.createApp)({ config: baseConfig, store: new store_1.InMemoryStoryStore(policy_1.defaultRuntimePolicy) });
        const response = await (0, supertest_1.default)(app).post('/v1/story/illustrate').send({
            action: 'illustrate',
            requestId: 'client-4',
            storyLang: 'en',
            prompt: 'A friendly dragon',
        });
        (0, vitest_1.expect)(response.status).toBe(200);
        (0, vitest_1.expect)(response.body.ok).toBe(true);
        (0, vitest_1.expect)(response.body.image?.disabled).toBe(true);
    });
    (0, vitest_1.it)('server generates auditId independent from client requestId', async () => {
        const store = new store_1.InMemoryStoryStore(policy_1.defaultRuntimePolicy);
        const { app } = (0, app_1.createApp)({ config: baseConfig, store });
        const clientRequestId = 'client-request-fixed';
        await (0, supertest_1.default)(app).post('/v1/story/create').send({
            action: 'generate',
            requestId: clientRequestId,
            storyLang: 'en',
        });
        const audits = store.listAudits();
        (0, vitest_1.expect)(audits.length).toBeGreaterThan(0);
        (0, vitest_1.expect)(audits[0].clientRequestId).toBe(clientRequestId);
        (0, vitest_1.expect)(audits[0].auditId).not.toBe(clientRequestId);
    });
});
