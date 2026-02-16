export type StoryAction = 'generate' | 'continue' | 'illustrate';

export type StoryLang = 'ru' | 'en' | 'hy';

export type AgeGroup = '3_5' | '6_8' | '9_12';

export type StoryLength = 'short' | 'medium' | 'long';

export interface StoryChoice {
  id: string;
  label: string;
  payload?: Record<string, unknown>;
}

export interface StoryChapter {
  index: number;
  title?: string;
  text: string;
  choices: StoryChoice[];
}

export interface StorySelection {
  hero?: string;
  location?: string;
  storyType?: string;
  idea?: string;
}

export interface StoryRequest {
  requestId?: string;
  action: StoryAction;
  storyLang: StoryLang;
  ageGroup?: AgeGroup;
  age?: number;
  tier?: string;
  storyLength?: StoryLength;
  creativityLevel?: number;
  complexity?: 'simple' | 'normal';
  creativity?: 'low' | 'normal' | 'high';
  selection?: StorySelection;
  heroType?: string;
  heroAge?: number;
  location?: string;
  genre?: string;
  familyMembers?: Record<string, number>;
  parentalControls?: {
    safeMode?: boolean;
    disableScaryContent?: boolean;
    requireParentConfirmationForOlder?: boolean;
  };
  storyId?: string;
  choice?: {
    id: string;
    payload?: Record<string, unknown>;
  };
  prompt?: string;
  image?: {
    enabled: boolean;
  };
  illustrationsEnabled?: boolean;
}

export interface StoryResponse {
  requestId: string;
  ok: boolean;
  error?: string;
  safeMessage?: string;
  storyId?: string;
  title?: string;
  chapter?: StoryChapter;
  chapters?: StoryChapter[];
  image?: {
    url?: string;
    base64?: string;
    disabled?: boolean;
    prompt?: string;
  };
  debug?: Record<string, unknown>;
}

export interface RuntimePolicy {
  enable_story_generation: boolean;
  enable_illustrations: boolean;
  model_allowlist: string[];
  max_output_tokens: number;
  temperature: number;
  max_input_chars: number;
  max_output_chars: number;
  daily_story_limit: number;
  ip_rate_per_min: number;
  uid_rate_per_min: number;
  max_body_kb: number;
  request_timeout_ms: number;
}

export interface StorySession {
  storyId: string;
  uid: string;
  storyLang: StoryLang;
  title: string;
  chapters: StoryChapter[];
  createdAt: string;
  updatedAt: string;
}

export interface AuditRecord {
  auditId: string;
  clientRequestId?: string;
  uid: string;
  route: string;
  action: StoryAction;
  blocked: boolean;
  blockReason?: string;
  storyId?: string;
  createdAt: string;
}

export interface AdminTestInput {
  age: number;
  tier: string;
  language: StoryLang | string;
  storyIdea: string;
  heroType: string;
  heroAge: number;
  location: string;
  genre: string;
  length: StoryLength | string;
  complexity: 'simple' | 'normal' | string;
  illustrationsEnabled: boolean;
  familyMembers: Record<string, number>;
  creativity: 'low' | 'normal' | 'high' | string;
  parentalControls: {
    safeMode: boolean;
    disableScaryContent: boolean;
    requireParentConfirmationForOlder: boolean;
  };
}

export interface GenerationLogRecord {
  logId: string;
  createdAt: string;
  userIdHash: string;
  tier: string;
  language: string;
  age: number;
  requestSummary: Record<string, unknown>;
  effectivePolicyId: string;
  templateIdsUsed: string[];
  status: 'ok' | 'blocked' | 'error';
  provider: 'gpt' | 'vertex' | 'mock';
  latencyMs: number;
  errorCode?: string;
  errorMessage?: string;
}

export interface TestRunRecord {
  runId: string;
  createdAt: string;
  adminUid: string;
  inputPayload: Record<string, unknown>;
  composedPayload: Record<string, unknown>;
  response: Record<string, unknown>;
  status: 'ok' | 'blocked' | 'error';
}
