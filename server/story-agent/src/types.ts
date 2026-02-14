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
  storyLength?: StoryLength;
  creativityLevel?: number;
  selection?: StorySelection;
  storyId?: string;
  choice?: {
    id: string;
    payload?: Record<string, unknown>;
  };
  prompt?: string;
  image?: {
    enabled: boolean;
  };
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
