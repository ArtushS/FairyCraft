import type {
  RuntimePolicy,
  StorySession,
  AuditRecord,
  GenerationLogRecord,
  TestRunRecord,
} from '../types';
import { getFirestore } from './firebaseAdmin';

export interface StoreDoc<T = Record<string, unknown>> {
  id: string;
  data: T;
}

export interface StoryStore {
  getStory(storyId: string): Promise<StorySession | null>;
  saveStory(story: StorySession): Promise<void>;
  appendAudit(record: AuditRecord): Promise<void>;
  incrementDailyUsage(uid: string, yyyymmdd: string): Promise<number>;
  getRuntimePolicy(): Promise<unknown | null>;
  listPoliciesV1(): Promise<StoreDoc[]>;
  listStyleTemplatesV1(): Promise<StoreDoc[]>;
  getSubscriptionTierV1(tierId: string): Promise<Record<string, unknown> | null>;
  appendGenerationLog(record: GenerationLogRecord): Promise<void>;
  appendTestRun(record: TestRunRecord): Promise<void>;
}

export class InMemoryStoryStore implements StoryStore {
  private readonly stories = new Map<string, StorySession>();
  private readonly audits = new Map<string, AuditRecord>();
  private readonly usage = new Map<string, number>();
  private readonly policiesV1 = new Map<string, Record<string, unknown>>();
  private readonly templatesV1 = new Map<string, Record<string, unknown>>();
  private readonly tiersV1 = new Map<string, Record<string, unknown>>();
  private readonly generationLogs = new Map<string, GenerationLogRecord>();
  private readonly testRuns = new Map<string, TestRunRecord>();
  private policy: RuntimePolicy | null;

  constructor(initialPolicy: RuntimePolicy | null) {
    this.policy = initialPolicy;
    this.seedAdminCollections();
  }

  async getStory(storyId: string): Promise<StorySession | null> {
    return this.stories.get(storyId) ?? null;
  }

  async saveStory(story: StorySession): Promise<void> {
    this.stories.set(story.storyId, story);
  }

  async appendAudit(record: AuditRecord): Promise<void> {
    this.audits.set(record.auditId, record);
  }

  async incrementDailyUsage(uid: string, yyyymmdd: string): Promise<number> {
    const key = `${uid}_${yyyymmdd}`;
    const next = (this.usage.get(key) ?? 0) + 1;
    this.usage.set(key, next);
    return next;
  }

  async getRuntimePolicy(): Promise<unknown | null> {
    return this.policy;
  }

  async listPoliciesV1(): Promise<StoreDoc[]> {
    return [...this.policiesV1.entries()].map(([id, data]) => ({ id, data }));
  }

  async listStyleTemplatesV1(): Promise<StoreDoc[]> {
    return [...this.templatesV1.entries()].map(([id, data]) => ({ id, data }));
  }

  async getSubscriptionTierV1(tierId: string): Promise<Record<string, unknown> | null> {
    return this.tiersV1.get(tierId) ?? null;
  }

  async appendGenerationLog(record: GenerationLogRecord): Promise<void> {
    this.generationLogs.set(record.logId, record);
  }

  async appendTestRun(record: TestRunRecord): Promise<void> {
    this.testRuns.set(record.runId, record);
  }

  setRuntimePolicy(policy: RuntimePolicy): void {
    this.policy = policy;
  }

  listAudits(): AuditRecord[] {
    return [...this.audits.values()];
  }

  private seedAdminCollections(): void {
    if (this.policiesV1.size === 0) {
      this.policiesV1.set('default_policy', {
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
          allowPersonalNames: true,
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
        versionStamp: 'v1',
        updatedAt: new Date().toISOString(),
      });
    }

    if (this.tiersV1.size === 0) {
      this.tiersV1.set('free', {
        active: true,
        limits: {
          storiesPerDay: 3,
          imagesPerStory: 1,
          maxStoryLength: 'short',
          maxContinuationDepth: 3,
          allowVoiceInput: false,
          allowTTS: false,
          allowPrintOrder: false,
          allowToyOrder: false,
        },
      });
      this.tiersV1.set('pro', {
        active: true,
        limits: {
          storiesPerDay: 10,
          imagesPerStory: 3,
          maxStoryLength: 'medium',
          maxContinuationDepth: 8,
          allowVoiceInput: true,
          allowTTS: true,
          allowPrintOrder: true,
          allowToyOrder: false,
        },
      });
      this.tiersV1.set('premium', {
        active: true,
        limits: {
          storiesPerDay: 30,
          imagesPerStory: 8,
          maxStoryLength: 'long',
          maxContinuationDepth: 16,
          allowVoiceInput: true,
          allowTTS: true,
          allowPrintOrder: true,
          allowToyOrder: true,
        },
      });
    }
  }
}

export class FirestoreStoryStore implements StoryStore {
  async getStory(storyId: string): Promise<StorySession | null> {
    const snapshot = await getFirestore().collection('stories').doc(storyId).get();
    return snapshot.exists ? (snapshot.data() as StorySession) : null;
  }

  async saveStory(story: StorySession): Promise<void> {
    await getFirestore().collection('stories').doc(story.storyId).set(story, { merge: true });
  }

  async appendAudit(record: AuditRecord): Promise<void> {
    await getFirestore().collection('story_audit').doc(record.auditId).set(record, { merge: false });
  }

  async incrementDailyUsage(uid: string, yyyymmdd: string): Promise<number> {
    const key = `${uid}_${yyyymmdd}`;
    const ref = getFirestore().collection('usage_daily').doc(key);

    const value = await getFirestore().runTransaction(async (transaction) => {
      const current = await transaction.get(ref);
      const nextCount = (current.data()?.count as number | undefined ?? 0) + 1;
      transaction.set(
        ref,
        {
          uid,
          date: yyyymmdd,
          count: nextCount,
          updatedAt: new Date().toISOString(),
        },
        { merge: true },
      );
      return nextCount;
    });

    return value;
  }

  async getRuntimePolicy(): Promise<unknown | null> {
    const snapshot = await getFirestore().collection('admin_policy').doc('runtime').get();
    return snapshot.exists ? snapshot.data() : null;
  }

  async listPoliciesV1(): Promise<StoreDoc[]> {
    const snapshot = await getFirestore().collection('policies_v1').get();
    return snapshot.docs.map((doc) => ({ id: doc.id, data: doc.data() }));
  }

  async listStyleTemplatesV1(): Promise<StoreDoc[]> {
    const snapshot = await getFirestore().collection('style_templates_v1').get();
    return snapshot.docs.map((doc) => ({ id: doc.id, data: doc.data() }));
  }

  async getSubscriptionTierV1(tierId: string): Promise<Record<string, unknown> | null> {
    const snapshot = await getFirestore().collection('subscription_tiers_v1').doc(tierId).get();
    return snapshot.exists ? (snapshot.data() as Record<string, unknown>) : null;
  }

  async appendGenerationLog(record: GenerationLogRecord): Promise<void> {
    await getFirestore().collection('generation_logs_v1').doc(record.logId).set(record, { merge: false });
  }

  async appendTestRun(record: TestRunRecord): Promise<void> {
    await getFirestore().collection('test_runs_v1').doc(record.runId).set(record, { merge: false });
  }
}
