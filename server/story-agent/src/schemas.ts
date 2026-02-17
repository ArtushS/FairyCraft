import { z } from 'zod';

export const actionSchema = z.enum(['generate', 'continue', 'illustrate']);
const storyLanguageSchema = z.enum(['ru', 'en', 'hy']);

export const storyRequestSchema = z
  .object({
    requestId: z.string().min(1).max(128).optional(),
    action: actionSchema,
    storyLang: storyLanguageSchema.optional(),
    language: storyLanguageSchema.optional(),
    ageGroup: z.enum(['3_5', '6_8', '9_12']).optional(),
    age: z.number().int().min(1).max(18).optional(),
    tier: z.string().min(1).max(32).optional(),
    storyLength: z.enum(['short', 'medium', 'long']).optional(),
    creativityLevel: z.number().min(0).max(1).optional(),
    complexity: z.enum(['simple', 'normal']).optional(),
    creativity: z.enum(['low', 'normal', 'high']).optional(),
    selection: z
      .object({
        hero: z.string().max(120).optional(),
        location: z.string().max(120).optional(),
        storyType: z.string().max(120).optional(),
        idea: z.string().max(4000).optional(),
      })
      .strict()
      .optional(),
    heroType: z.string().max(120).optional(),
    heroAge: z.number().int().min(1).max(18).optional(),
    location: z.string().max(120).optional(),
    genre: z.string().max(120).optional(),
    familyMembers: z.record(z.string(), z.number().int().min(0).max(10)).optional(),
    familyNames: z.record(z.string(), z.string().max(80)).optional(),
    brothers: z.array(z.string().max(80)).max(10).optional(),
    sisters: z.array(z.string().max(80)).max(10).optional(),
    parentalControls: z
      .object({
        safeMode: z.boolean().optional(),
        disableScaryContent: z.boolean().optional(),
        requireParentConfirmationForOlder: z.boolean().optional(),
      })
      .strict()
      .optional(),
    storyId: z.string().min(1).max(128).optional(),
    choice: z
      .object({
        id: z.string().min(1).max(120),
        payload: z.record(z.string(), z.unknown()).optional(),
      })
      .strict()
      .optional(),
    prompt: z.string().max(4000).optional(),
    illustrationsEnabled: z.boolean().optional(),
    image: z
      .object({
        enabled: z.boolean(),
      })
      .strict()
      .optional(),
  })
  .strict()
  .transform((request) => {
    const { language, ...rest } = request;
    return {
      ...rest,
      storyLang: request.storyLang ?? language ?? 'en',
    };
  });

export const adminTestInputSchema = z
  .object({
    age: z.number().int().min(1).max(18),
    tier: z.string().min(1).max(32),
    language: storyLanguageSchema,
    storyIdea: z.string().max(4000),
    heroType: z.string().max(120),
    heroAge: z.number().int().min(1).max(18),
    location: z.string().max(120),
    genre: z.string().max(120),
    length: z.enum(['short', 'medium', 'long']),
    complexity: z.enum(['simple', 'normal']),
    illustrationsEnabled: z.boolean(),
    familyMembers: z.record(z.string(), z.number().int().min(0).max(10)),
    familyNames: z.record(z.string(), z.string().max(80)).optional(),
    brothers: z.array(z.string().max(80)).max(10).optional(),
    sisters: z.array(z.string().max(80)).max(10).optional(),
    creativity: z.enum(['low', 'normal', 'high']),
    parentalControls: z
      .object({
        safeMode: z.boolean(),
        disableScaryContent: z.boolean(),
        requireParentConfirmationForOlder: z.boolean(),
      })
      .strict(),
  })
  .strict();

export const runtimePolicySchema = z
  .object({
    enable_story_generation: z.boolean(),
    enable_illustrations: z.boolean(),
    model_allowlist: z.array(z.string().min(1)).min(1),
    max_output_tokens: z.number().int().min(64).max(8192),
    temperature: z.number().min(0).max(1),
    max_input_chars: z.number().int().min(64).max(64000),
    max_output_chars: z.number().int().min(128).max(64000),
    daily_story_limit: z.number().int().min(1).max(500),
    ip_rate_per_min: z.number().int().min(1).max(1000),
    uid_rate_per_min: z.number().int().min(1).max(1000),
    max_body_kb: z.number().int().min(1).max(2048),
    request_timeout_ms: z.number().int().min(1000).max(120000),
  })
  .strict();
