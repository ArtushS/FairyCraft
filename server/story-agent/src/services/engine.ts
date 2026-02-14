import { randomUUID } from 'node:crypto';

import type { AppConfig } from '../config';
import type { RuntimePolicy, StoryChapter, StoryRequest, StorySession } from '../types';

export class EngineUnavailableError extends Error {
  readonly code = 'upstream_unavailable';

  constructor(message = 'Upstream AI service is unavailable.') {
    super(message);
  }
}

export interface StoryEngine {
  generate(input: {
    request: StoryRequest;
    policy: RuntimePolicy;
    uid: string;
  }): Promise<{
    storyId: string;
    title: string;
    chapter: StoryChapter;
    image?: { disabled?: boolean; prompt?: string; url?: string };
  }>;
  continue(input: {
    request: StoryRequest;
    policy: RuntimePolicy;
    story: StorySession;
  }): Promise<{ chapter: StoryChapter }>;
  illustrate(input: {
    request: StoryRequest;
    policy: RuntimePolicy;
    story: StorySession | null;
  }): Promise<{ image: { disabled?: boolean; prompt?: string; url?: string } }>;
}

const clipped = (value: string, maxChars: number): string => {
  if (value.length <= maxChars) {
    return value;
  }
  return `${value.slice(0, Math.max(0, maxChars - 3))}...`;
};

export class MockStoryEngine implements StoryEngine {
  async generate(input: {
    request: StoryRequest;
    policy: RuntimePolicy;
    uid: string;
  }): Promise<{
    storyId: string;
    title: string;
    chapter: StoryChapter;
    image?: { disabled?: boolean; prompt?: string; url?: string };
  }> {
    const hero = input.request.selection?.hero ?? 'small stargazer';
    const location = input.request.selection?.location ?? 'moonlit forest';
    const storyType = input.request.selection?.storyType ?? 'friendship adventure';

    const title = `FairyCraft: ${hero} and the ${location}`;
    const chapter: StoryChapter = {
      index: 1,
      title: 'A Gentle Beginning',
      text: clipped(
        `${hero} started a ${storyType} in the ${location}. Every step brought kind choices, curiosity, and a little sparkle of courage.`,
        input.policy.max_output_chars,
      ),
      choices: [
        { id: 'follow_lights', label: 'Follow the glowing lights' },
        { id: 'ask_friend', label: 'Ask a forest friend for help' },
      ],
    };

    const image = input.request.image?.enabled
      ? {
          prompt: `Safe children illustration: ${hero} in ${location}, warm colors, storybook style.`,
          disabled: true,
        }
      : undefined;

    return {
      storyId: randomUUID(),
      title,
      chapter,
      image,
    };
  }

  async continue(input: {
    request: StoryRequest;
    policy: RuntimePolicy;
    story: StorySession;
  }): Promise<{ chapter: StoryChapter }> {
    const nextIndex = input.story.chapters.length + 1;
    const selectedChoice = input.request.choice?.id ?? 'gentle_step';

    const chapter: StoryChapter = {
      index: nextIndex,
      title: `Chapter ${nextIndex}`,
      text: clipped(
        `The friends chose "${selectedChoice}" and discovered a calm path where teamwork solved each puzzle with kindness.`,
        input.policy.max_output_chars,
      ),
      choices: [
        { id: `next_${nextIndex}_a`, label: 'Keep exploring together' },
        { id: `next_${nextIndex}_b`, label: 'Pause and make a safe plan' },
      ],
    };

    return { chapter };
  }

  async illustrate(input: {
    request: StoryRequest;
    policy: RuntimePolicy;
    story: StorySession | null;
  }): Promise<{ image: { disabled?: boolean; prompt?: string; url?: string } }> {
    const title = input.story?.title ?? 'FairyCraft Story';
    const prompt = input.request.prompt || `Safe children illustration for ${title}`;

    return {
      image: {
        disabled: true,
        prompt: clipped(prompt, input.policy.max_input_chars),
      },
    };
  }
}

export class VertexStoryEngine implements StoryEngine {
  constructor(private readonly config: AppConfig) {}

  private ensureConfigured(): void {
    if (!this.config.googleCloudProject || !this.config.vertexLocation || !this.config.geminiModel) {
      throw new EngineUnavailableError();
    }
  }

  async generate(input: {
    request: StoryRequest;
    policy: RuntimePolicy;
    uid: string;
  }): Promise<{
    storyId: string;
    title: string;
    chapter: StoryChapter;
    image?: { disabled?: boolean; prompt?: string; url?: string };
  }> {
    this.ensureConfigured();
    throw new EngineUnavailableError();
  }

  async continue(input: {
    request: StoryRequest;
    policy: RuntimePolicy;
    story: StorySession;
  }): Promise<{ chapter: StoryChapter }> {
    this.ensureConfigured();
    throw new EngineUnavailableError();
  }

  async illustrate(input: {
    request: StoryRequest;
    policy: RuntimePolicy;
    story: StorySession | null;
  }): Promise<{ image: { disabled?: boolean; prompt?: string; url?: string } }> {
    this.ensureConfigured();
    if (!this.config.vertexImageModel || !this.config.storageBucket) {
      return {
        image: {
          disabled: true,
          prompt: input.request.prompt ?? 'Illustration requested but image backend is not configured.',
        },
      };
    }
    return {
      image: {
        disabled: true,
        prompt: input.request.prompt ?? 'Illustration backend placeholder.',
      },
    };
  }
}
