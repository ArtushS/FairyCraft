import { runtimePolicySchema } from '../schemas';
import type { RuntimePolicy } from '../types';
import type { StoryStore } from './store';

export const defaultRuntimePolicy: RuntimePolicy = {
  enable_story_generation: true,
  enable_illustrations: true,
  model_allowlist: ['gemini-2.0-flash'],
  max_output_tokens: 600,
  temperature: 0.6,
  max_input_chars: 4000,
  max_output_chars: 5000,
  daily_story_limit: 20,
  ip_rate_per_min: 60,
  uid_rate_per_min: 40,
  max_body_kb: 64,
  request_timeout_ms: 20000,
};

interface CachedPolicy {
  policy: RuntimePolicy | null;
  expiresAt: number;
  reason?: string;
}

export interface PolicyResult {
  policy: RuntimePolicy | null;
  reason?: string;
}

export class PolicyService {
  private cache: CachedPolicy | null = null;

  constructor(
    private readonly store: StoryStore,
    private readonly ttlMs: number,
  ) {}

  async getRuntimePolicy(): Promise<PolicyResult> {
    const now = Date.now();
    if (this.cache && this.cache.expiresAt > now) {
      return { policy: this.cache.policy, reason: this.cache.reason };
    }

    try {
      const raw = await this.store.getRuntimePolicy();
      if (!raw) {
        this.cache = { policy: null, expiresAt: now + this.ttlMs, reason: 'policy_missing' };
        return { policy: null, reason: 'policy_missing' };
      }

      const parsed = runtimePolicySchema.safeParse(raw);
      if (!parsed.success) {
        this.cache = { policy: null, expiresAt: now + this.ttlMs, reason: 'policy_invalid' };
        return { policy: null, reason: 'policy_invalid' };
      }

      this.cache = { policy: parsed.data, expiresAt: now + this.ttlMs };
      return { policy: parsed.data };
    } catch (error) {
      this.cache = { policy: null, expiresAt: now + this.ttlMs, reason: 'policy_unavailable' };
      return { policy: null, reason: 'policy_unavailable' };
    }
  }
}
