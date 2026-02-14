import { z } from 'zod';

export const actionSchema = z.enum(['generate', 'continue', 'illustrate']);

export const storyRequestSchema = z
  .object({
    requestId: z.string().min(1).max(128).optional(),
    action: actionSchema,
    storyLang: z.enum(['ru', 'en', 'hy']),
    ageGroup: z.enum(['3_5', '6_8', '9_12']).optional(),
    storyLength: z.enum(['short', 'medium', 'long']).optional(),
    creativityLevel: z.number().min(0).max(1).optional(),
    selection: z
      .object({
        hero: z.string().max(120).optional(),
        location: z.string().max(120).optional(),
        storyType: z.string().max(120).optional(),
        idea: z.string().max(4000).optional(),
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
    image: z
      .object({
        enabled: z.boolean(),
      })
      .strict()
      .optional(),
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
