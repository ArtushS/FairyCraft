import type { AdminTestInput, StoryRequest } from '../types';
import type { StoreDoc, StoryStore } from './store';

interface PolicyScopeV1 {
  ageMin: number;
  ageMax: number;
  language: string;
  tier: string;
}

interface ContentRulesV1 {
  safeModeDefault: boolean;
  disallowViolence: boolean;
  disallowDrugs: boolean;
  disallowHate: boolean;
  disallowSexualContent: boolean;
  disallowReligiousPolitical: boolean;
  requireParentConfirmationForOlder: boolean;
  disallowScary: boolean;
  customBannedWords: string[];
}

interface PromptConstraintsV1 {
  maxTokensHint: number;
  maxCharsHint: number;
  enforceStructure: boolean;
  readingLevel: string;
}

interface ImageRulesV1 {
  allowImages: boolean;
  allowedImageStyles: string[];
}

export interface PolicyV1 {
  id: string;
  active: boolean;
  scope: PolicyScopeV1;
  contentRules: ContentRulesV1;
  promptConstraints: PromptConstraintsV1;
  imageRules: ImageRulesV1;
  versionStamp: string;
}

interface TemplateScopeV1 extends PolicyScopeV1 {}

interface TemplatePayloadV1 {
  system?: string;
  instructions: string;
  negative?: string;
}

export interface StyleTemplateV1 {
  id: string;
  active: boolean;
  type: 'story' | 'image';
  name: string;
  description: string;
  tags: string[];
  scopes: TemplateScopeV1[];
  template: TemplatePayloadV1;
}

interface TierLimitsV1 {
  storiesPerDay: number;
  imagesPerStory: number;
  maxStoryLength: string;
  maxContinuationDepth: number;
  allowVoiceInput: boolean;
  allowTTS: boolean;
  allowPrintOrder: boolean;
  allowToyOrder: boolean;
}

export interface TierV1 {
  id: string;
  active: boolean;
  limits: TierLimitsV1;
}

export interface EffectivePolicyBundle {
  policy: PolicyV1;
  templates: StyleTemplateV1[];
  tier: TierV1;
}

export interface PolicyDecision {
  status: 'ok' | 'blocked';
  reasons: string[];
}

interface PolicyDataBundle {
  policies: PolicyV1[];
  templates: StyleTemplateV1[];
  tiers: Map<string, TierV1>;
}

interface CachedPolicyData {
  expiresAt: number;
  bundle: PolicyDataBundle;
}

const asObject = (value: unknown): Record<string, unknown> => {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  return {};
};

const asBoolean = (value: unknown, fallback: boolean): boolean => {
  return typeof value === 'boolean' ? value : fallback;
};

const asNumber = (value: unknown, fallback: number): number => {
  return typeof value === 'number' && Number.isFinite(value) ? value : fallback;
};

const asString = (value: unknown, fallback: string): string => {
  return typeof value === 'string' && value.trim().length > 0 ? value.trim() : fallback;
};

const asStringArray = (value: unknown): string[] => {
  if (!Array.isArray(value)) {
    return [];
  }
  return value
    .map((item) => (typeof item === 'string' ? item.trim() : ''))
    .filter((item) => item.length > 0);
};

const defaultScope = (): PolicyScopeV1 => ({
  ageMin: 6,
  ageMax: 12,
  language: '*',
  tier: '*',
});

const defaultContentRules = (): ContentRulesV1 => ({
  safeModeDefault: true,
  disallowViolence: true,
  disallowDrugs: true,
  disallowHate: true,
  disallowSexualContent: true,
  disallowReligiousPolitical: true,
  requireParentConfirmationForOlder: true,
  disallowScary: true,
  customBannedWords: [],
});

const defaultPromptConstraints = (): PromptConstraintsV1 => ({
  maxTokensHint: 700,
  maxCharsHint: 4500,
  enforceStructure: true,
  readingLevel: 'simple',
});

const defaultImageRules = (): ImageRulesV1 => ({
  allowImages: true,
  allowedImageStyles: ['storybook-watercolor'],
});

const defaultPolicy = (): PolicyV1 => ({
  id: 'default_policy',
  active: true,
  scope: defaultScope(),
  contentRules: defaultContentRules(),
  promptConstraints: defaultPromptConstraints(),
  imageRules: defaultImageRules(),
  versionStamp: 'v1',
});

const defaultTier = (tierId: string): TierV1 => {
  if (tierId === 'premium') {
    return {
      id: tierId,
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
    };
  }
  if (tierId === 'pro') {
    return {
      id: tierId,
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
    };
  }
  return {
    id: 'free',
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
  };
};

const parseScope = (raw: unknown): PolicyScopeV1 => {
  const object = asObject(raw);
  return {
    ageMin: Math.max(1, Math.min(18, Math.round(asNumber(object.ageMin, 6)))),
    ageMax: Math.max(1, Math.min(18, Math.round(asNumber(object.ageMax, 12)))),
    language: asString(object.language, '*'),
    tier: asString(object.tier, '*'),
  };
};

const parseContentRules = (raw: unknown): ContentRulesV1 => {
  const object = asObject(raw);
  return {
    safeModeDefault: asBoolean(object.safeModeDefault, true),
    disallowViolence: asBoolean(object.disallowViolence, true),
    disallowDrugs: asBoolean(object.disallowDrugs, true),
    disallowHate: asBoolean(object.disallowHate, true),
    disallowSexualContent: asBoolean(object.disallowSexualContent, true),
    disallowReligiousPolitical: asBoolean(object.disallowReligiousPolitical, true),
    requireParentConfirmationForOlder: asBoolean(object.requireParentConfirmationForOlder, true),
    disallowScary: asBoolean(object.disallowScary, true),
    customBannedWords: asStringArray(object.customBannedWords).map((word) => word.toLowerCase()),
  };
};

const parsePromptConstraints = (raw: unknown): PromptConstraintsV1 => {
  const object = asObject(raw);
  return {
    maxTokensHint: Math.round(asNumber(object.maxTokensHint, 700)),
    maxCharsHint: Math.round(asNumber(object.maxCharsHint, 4500)),
    enforceStructure: asBoolean(object.enforceStructure, true),
    readingLevel: asString(object.readingLevel, 'simple'),
  };
};

const parseImageRules = (raw: unknown): ImageRulesV1 => {
  const object = asObject(raw);
  const imageStyles = asStringArray(object.allowedImageStyles);
  return {
    allowImages: asBoolean(object.allowImages, true),
    allowedImageStyles:
      imageStyles.length > 0 ? imageStyles : ['storybook-watercolor'],
  };
};

const parsePolicyDoc = (doc: StoreDoc): PolicyV1 => {
  const object = asObject(doc.data);
  return {
    id: doc.id,
    active: asBoolean(object.active, true),
    scope: parseScope(object.scope),
    contentRules: parseContentRules(object.contentRules),
    promptConstraints: parsePromptConstraints(object.promptConstraints),
    imageRules: parseImageRules(object.imageRules),
    versionStamp: asString(object.versionStamp, 'v1'),
  };
};

const parseTemplateScopes = (raw: unknown): TemplateScopeV1[] => {
  if (!Array.isArray(raw)) {
    return [defaultScope()];
  }
  const scopes = raw.map((item) => parseScope(item));
  return scopes.length > 0 ? scopes : [defaultScope()];
};

const parseTemplateDoc = (doc: StoreDoc): StyleTemplateV1 => {
  const object = asObject(doc.data);
  const templateObject = asObject(object.template);
  const rawType = asString(object.type, 'story').toLowerCase();
  return {
    id: doc.id,
    active: asBoolean(object.active, true),
    type: rawType === 'image' ? 'image' : 'story',
    name: asString(object.name, doc.id),
    description: asString(object.description, ''),
    tags: asStringArray(object.tags),
    scopes: parseTemplateScopes(object.scopes),
    template: {
      system:
        typeof templateObject.system === 'string'
          ? templateObject.system
          : undefined,
      instructions: asString(
        templateObject.instructions,
        'Write a safe, age-appropriate story.',
      ),
      negative:
        typeof templateObject.negative === 'string'
          ? templateObject.negative
          : undefined,
    },
  };
};

const parseTierDoc = (tierId: string, data: Record<string, unknown> | null): TierV1 => {
  if (!data) {
    return defaultTier(tierId);
  }
  const object = asObject(data);
  const limits = asObject(object.limits);
  return {
    id: tierId,
    active: asBoolean(object.active, true),
    limits: {
      storiesPerDay: Math.max(1, Math.round(asNumber(limits.storiesPerDay, 3))),
      imagesPerStory: Math.max(0, Math.round(asNumber(limits.imagesPerStory, 1))),
      maxStoryLength: asString(limits.maxStoryLength, 'short'),
      maxContinuationDepth: Math.max(1, Math.round(asNumber(limits.maxContinuationDepth, 3))),
      allowVoiceInput: asBoolean(limits.allowVoiceInput, false),
      allowTTS: asBoolean(limits.allowTTS, false),
      allowPrintOrder: asBoolean(limits.allowPrintOrder, false),
      allowToyOrder: asBoolean(limits.allowToyOrder, false),
    },
  };
};

const scopeMatches = (scope: PolicyScopeV1, age: number, language: string, tier: string): boolean => {
  const ageMatch = age >= scope.ageMin && age <= scope.ageMax;
  const languageMatch = scope.language === '*' || scope.language === language;
  const tierMatch = scope.tier === '*' || scope.tier === tier;
  return ageMatch && languageMatch && tierMatch;
};

const scopeScore = (scope: PolicyScopeV1): number => {
  const range = Math.max(1, scope.ageMax - scope.ageMin + 1);
  const languageScore = scope.language === '*' ? 0 : 50;
  const tierScore = scope.tier === '*' ? 0 : 50;
  return languageScore + tierScore + (100 - Math.min(100, range));
};

const bannedKeywordSets = {
  violence: ['kill', 'murder', 'blood', 'gun', 'knife', 'weapon', 'fight'],
  drugs: ['drug', 'cocaine', 'heroin', 'alcohol', 'vodka', 'cigarette'],
  hate: ['hate', 'racist', 'nazi', 'terror'],
  sexual: ['sex', 'nude', 'explicit', 'porn'],
  religiousPolitical: ['politics', 'election', 'religion', 'church', 'party'],
  scary: ['horror', 'ghost', 'demon', 'nightmare', 'monster'],
  older: ['dating', 'kiss', 'war', 'battle'],
} as const;

const containsAny = (input: string, keywords: readonly string[]): boolean => {
  return keywords.some((keyword) => input.includes(keyword));
};

interface ParentControlFlags {
  safeMode: boolean;
  disableScaryContent: boolean;
  requireParentConfirmationForOlder: boolean;
}

const extractParentControlsFromStoryRequest = (request: StoryRequest): ParentControlFlags => {
  return {
    safeMode: request.parentalControls?.safeMode ?? true,
    disableScaryContent: request.parentalControls?.disableScaryContent ?? true,
    requireParentConfirmationForOlder:
      request.parentalControls?.requireParentConfirmationForOlder ?? true,
  };
};

const extractParentControlsFromAdminInput = (input: AdminTestInput): ParentControlFlags => {
  return {
    safeMode: input.parentalControls.safeMode,
    disableScaryContent: input.parentalControls.disableScaryContent,
    requireParentConfirmationForOlder:
      input.parentalControls.requireParentConfirmationForOlder,
  };
};

export class PolicyV1Service {
  private cache: CachedPolicyData | null = null;

  constructor(
    private readonly store: StoryStore,
    private readonly ttlMs: number,
  ) {}

  private async loadDataBundle(): Promise<PolicyDataBundle> {
    const now = Date.now();
    if (this.cache && this.cache.expiresAt > now) {
      return this.cache.bundle;
    }

    const policyDocs = await this.store.listPoliciesV1();
    const templateDocs = await this.store.listStyleTemplatesV1();
    const tierIds = ['free', 'pro', 'premium'];
    const tierDocs = await Promise.all(
      tierIds.map(async (tierId) => [tierId, await this.store.getSubscriptionTierV1(tierId)] as const),
    );

    const parsedPolicies = policyDocs.map(parsePolicyDoc).filter((policy) => policy.active);
    const parsedTemplates = templateDocs
      .map(parseTemplateDoc)
      .filter((template) => template.active);
    const parsedTiers = new Map<string, TierV1>(
      tierDocs.map(([tierId, data]) => [tierId, parseTierDoc(tierId, data)]),
    );

    const bundle: PolicyDataBundle = {
      policies: parsedPolicies.length > 0 ? parsedPolicies : [defaultPolicy()],
      templates: parsedTemplates,
      tiers: parsedTiers,
    };

    this.cache = {
      expiresAt: now + this.ttlMs,
      bundle,
    };
    return bundle;
  }

  async resolveForStoryRequest(request: StoryRequest): Promise<EffectivePolicyBundle> {
    const input = mapStoryRequestToAdminInput(request);
    return this.resolveForAdminInput(input);
  }

  async resolveForAdminInput(input: AdminTestInput): Promise<EffectivePolicyBundle> {
    const bundle = await this.loadDataBundle();
    const normalizedLanguage = input.language.toLowerCase();
    const normalizedTier = input.tier.toLowerCase();

    let selectedPolicy = bundle.policies[0];
    let selectedScore = -1;
    for (const policy of bundle.policies) {
      if (!scopeMatches(policy.scope, input.age, normalizedLanguage, normalizedTier)) {
        continue;
      }
      const score = scopeScore(policy.scope);
      if (score > selectedScore) {
        selectedPolicy = policy;
        selectedScore = score;
      }
    }

    const templateScores = bundle.templates
      .map((template) => {
        let bestScore = -1;
        for (const scope of template.scopes) {
          if (!scopeMatches(scope, input.age, normalizedLanguage, normalizedTier)) {
            continue;
          }
          const score = scopeScore(scope);
          if (score > bestScore) {
            bestScore = score;
          }
        }
        return { template, score: bestScore };
      })
      .filter((item) => item.score >= 0)
      .sort((a, b) => b.score - a.score)
      .map((item) => item.template);

    const tier = bundle.tiers.get(normalizedTier) ?? defaultTier(normalizedTier);

    return {
      policy: selectedPolicy,
      templates: templateScores,
      tier,
    };
  }
}

export const mapStoryRequestToAdminInput = (request: StoryRequest): AdminTestInput => {
  const ageByGroup = request.ageGroup === '3_5' ? 4 : request.ageGroup === '6_8' ? 7 : request.ageGroup === '9_12' ? 10 : 8;
  const language = request.storyLang ?? 'en';
  return {
    age: request.age ?? ageByGroup,
    tier: request.tier ?? 'free',
    language,
    storyIdea: request.selection?.idea ?? request.prompt ?? '',
    heroType: request.heroType ?? request.selection?.hero ?? 'boy',
    heroAge: request.heroAge ?? request.age ?? ageByGroup,
    location: request.location ?? request.selection?.location ?? '',
    genre: request.genre ?? request.selection?.storyType ?? 'adventure',
    length: request.storyLength ?? 'short',
    complexity: request.complexity ?? 'normal',
    illustrationsEnabled: request.illustrationsEnabled ?? request.image?.enabled ?? true,
    familyMembers: request.familyMembers ?? {},
    creativity: request.creativity ?? 'normal',
    parentalControls: extractParentControlsFromStoryRequest(request),
  };
};

interface DecisionInput {
  policy: PolicyV1;
  sourceText: string;
  parentControls: ParentControlFlags;
}

export const evaluatePolicyDecision = ({
  policy,
  sourceText,
  parentControls,
}: DecisionInput): PolicyDecision => {
  const text = sourceText.toLowerCase();
  const reasons = new Set<string>();
  const rules = policy.contentRules;
  const safeModeEnabled = parentControls.safeMode || rules.safeModeDefault;

  for (const bannedWord of rules.customBannedWords) {
    if (bannedWord && text.includes(bannedWord.toLowerCase())) {
      reasons.add(`banned_word:${bannedWord}`);
    }
  }

  if (safeModeEnabled && rules.disallowViolence && containsAny(text, bannedKeywordSets.violence)) {
    reasons.add('violence_detected');
  }
  if (safeModeEnabled && rules.disallowDrugs && containsAny(text, bannedKeywordSets.drugs)) {
    reasons.add('drug_reference_detected');
  }
  if (safeModeEnabled && rules.disallowHate && containsAny(text, bannedKeywordSets.hate)) {
    reasons.add('hate_content_detected');
  }
  if (safeModeEnabled && rules.disallowSexualContent && containsAny(text, bannedKeywordSets.sexual)) {
    reasons.add('sexual_content_detected');
  }
  if (safeModeEnabled && rules.disallowReligiousPolitical && containsAny(text, bannedKeywordSets.religiousPolitical)) {
    reasons.add('religious_or_political_content_detected');
  }
  if ((safeModeEnabled || parentControls.disableScaryContent) && rules.disallowScary && containsAny(text, bannedKeywordSets.scary)) {
    reasons.add('scary_content_detected');
  }
  if (
    rules.requireParentConfirmationForOlder &&
    !parentControls.requireParentConfirmationForOlder &&
    containsAny(text, bannedKeywordSets.older)
  ) {
    reasons.add('parent_confirmation_required');
  }

  return {
    status: reasons.size > 0 ? 'blocked' : 'ok',
    reasons: [...reasons],
  };
};

interface PayloadBuildOptions {
  input: AdminTestInput;
  resolution: EffectivePolicyBundle;
  provider: 'gpt' | 'vertex' | 'mock';
}

export const buildComposedPayload = ({
  input,
  resolution,
  provider,
}: PayloadBuildOptions): Record<string, unknown> => {
  const storyTemplates = resolution.templates.filter((template) => template.type === 'story');
  const imageTemplates = resolution.templates.filter((template) => template.type === 'image');
  const combinedInstructions = storyTemplates
    .map((template) => template.template.instructions)
    .join('\n\n')
    .trim();
  const combinedNegative = imageTemplates
    .map((template) => template.template.negative)
    .filter((value): value is string => typeof value === 'string' && value.trim().length > 0)
    .join('\n')
    .trim();

  return {
    provider,
    request: input,
    effectivePolicyId: resolution.policy.id,
    templateIds: resolution.templates.map((template) => template.id),
    modelHints: {
      maxTokensHint: resolution.policy.promptConstraints.maxTokensHint,
      maxCharsHint: resolution.policy.promptConstraints.maxCharsHint,
      readingLevel: resolution.policy.promptConstraints.readingLevel,
      enforceStructure: resolution.policy.promptConstraints.enforceStructure,
    },
    imageRules: resolution.policy.imageRules,
    tierLimits: resolution.tier.limits,
    prompt: {
      system:
        storyTemplates
          .map((template) => template.template.system)
          .filter((value): value is string => typeof value === 'string' && value.trim().length > 0)
          .join('\n\n') || undefined,
      instructions: combinedInstructions,
      negative: combinedNegative || undefined,
      userSummary: [
        `Language: ${input.language}`,
        `Age: ${input.age}`,
        `Tier: ${input.tier}`,
        `Hero: ${input.heroType} (${input.heroAge})`,
        `Genre: ${input.genre}`,
        `Length: ${input.length}`,
        `Complexity: ${input.complexity}`,
        `Creativity: ${input.creativity}`,
        `Location: ${input.location}`,
        `Idea: ${input.storyIdea}`,
      ].join('\n'),
    },
  };
};

export const decisionForAdminInput = (policy: PolicyV1, input: AdminTestInput): PolicyDecision => {
  return evaluatePolicyDecision({
    policy,
    sourceText: input.storyIdea,
    parentControls: extractParentControlsFromAdminInput(input),
  });
};
