import '../models/admin_policy_model.dart';
import '../models/style_template_model.dart';

class EffectivePolicyResolution {
  const EffectivePolicyResolution({
    required this.policy,
    required this.templates,
  });

  final AdminPolicyModel? policy;
  final List<StyleTemplateModel> templates;

  List<StyleTemplateModel> get storyTemplates =>
      templates.where((template) => template.type == 'story').toList(growable: false);
  List<StyleTemplateModel> get imageTemplates =>
      templates.where((template) => template.type == 'image').toList(growable: false);
}

class EffectivePolicyResolver {
  const EffectivePolicyResolver();

  EffectivePolicyResolution resolve({
    required List<AdminPolicyModel> policies,
    required List<StyleTemplateModel> templates,
    required int age,
    required String language,
    required String tier,
  }) {
    AdminPolicyModel? chosenPolicy;
    int chosenPolicyScore = -1;

    for (final policy in policies) {
      if (!policy.active) {
        continue;
      }
      if (!policy.scope.matches(age: age, languageCode: language, tierCode: tier)) {
        continue;
      }
      final score = policy.scope.specificityScore();
      if (score > chosenPolicyScore) {
        chosenPolicy = policy;
        chosenPolicyScore = score;
      }
    }

    final scoredTemplates = <_ScoredTemplate>[];
    for (final template in templates) {
      if (!template.active) {
        continue;
      }

      var maxScore = -1;
      for (final scope in template.scopes) {
        if (!scope.matches(age: age, languageCode: language, tierCode: tier)) {
          continue;
        }
        final score = scope.specificityScore();
        if (score > maxScore) {
          maxScore = score;
        }
      }

      if (maxScore >= 0) {
        scoredTemplates.add(_ScoredTemplate(template: template, score: maxScore));
      }
    }

    scoredTemplates.sort((a, b) => b.score.compareTo(a.score));

    return EffectivePolicyResolution(
      policy: chosenPolicy,
      templates: scoredTemplates.map((item) => item.template).toList(growable: false),
    );
  }
}

class _ScoredTemplate {
  const _ScoredTemplate({required this.template, required this.score});

  final StyleTemplateModel template;
  final int score;
}
