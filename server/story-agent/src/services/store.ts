import type { RuntimePolicy, StorySession, AuditRecord } from '../types';
import { getFirestore } from './firebaseAdmin';

export interface StoryStore {
  getStory(storyId: string): Promise<StorySession | null>;
  saveStory(story: StorySession): Promise<void>;
  appendAudit(record: AuditRecord): Promise<void>;
  incrementDailyUsage(uid: string, yyyymmdd: string): Promise<number>;
  getRuntimePolicy(): Promise<unknown | null>;
}

export class InMemoryStoryStore implements StoryStore {
  private readonly stories = new Map<string, StorySession>();
  private readonly audits = new Map<string, AuditRecord>();
  private readonly usage = new Map<string, number>();
  private policy: RuntimePolicy | null;

  constructor(initialPolicy: RuntimePolicy | null) {
    this.policy = initialPolicy;
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

  setRuntimePolicy(policy: RuntimePolicy): void {
    this.policy = policy;
  }

  listAudits(): AuditRecord[] {
    return [...this.audits.values()];
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
}
