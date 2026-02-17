// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String policiesLanguageFilterLabel(String value) {
    return 'Language: $value';
  }

  @override
  String policiesTierFilterLabel(String value) {
    return 'Tier: $value';
  }

  @override
  String get policiesAgeRangeFilter => 'Age range filter';

  @override
  String get policiesNewPolicy => 'New Policy';

  @override
  String get commonReload => 'Reload';

  @override
  String get policiesBackfillInProgress => 'Backfilling...';

  @override
  String get policiesBackfillButton => 'Backfill allowPersonalNames';

  @override
  String policiesBackfillSummary(int scanned, int updated, int skipped) {
    return 'Backfill completed. Scanned: $scanned, updated: $updated, skipped: $skipped.';
  }

  @override
  String get policiesDeletePolicyTitle => 'Delete Policy';

  @override
  String policiesDeletePolicyConfirm(String id) {
    return 'Delete policy \"$id\"? This action cannot be undone.';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get policiesColumnActive => 'Active';

  @override
  String get policiesColumnPolicyId => 'Policy ID';

  @override
  String get policiesColumnScope => 'Scope';

  @override
  String get policiesColumnReadingLevel => 'Reading Level';

  @override
  String get policiesColumnVersionStamp => 'Version Stamp';

  @override
  String get policiesColumnActions => 'Actions';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSave => 'Save';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonRemove => 'Remove';

  @override
  String get testConsoleTitle => 'Agent Test Console';

  @override
  String get testConsoleDescription => 'Runs local effective policy resolution, calls gateway dry-run, and stores test_runs_v1.';

  @override
  String get tcAgeLabel => 'Age';

  @override
  String get tcTierLabel => 'Tier';

  @override
  String get tcLanguageLabel => 'Language';

  @override
  String get tcHeroTypeLabel => 'Hero type';

  @override
  String get tcHeroAgeLabel => 'Hero age';

  @override
  String get tcStoryIdeaLabel => 'Story idea';

  @override
  String get tcLocationLabel => 'Location';

  @override
  String get tcGenreLabel => 'Genre';

  @override
  String get tcLengthLabel => 'Length';

  @override
  String get tcComplexityLabel => 'Complexity';

  @override
  String get tcCreativityLabel => 'Creativity';

  @override
  String get tcFamilyMembersLabel => 'Family members (dad:1,mom:1,grandma:1)';

  @override
  String get tcFamilyNamesTitle => 'Family names (optional)';

  @override
  String get tcMomNameLabel => 'Mom name';

  @override
  String get tcDadNameLabel => 'Dad name';

  @override
  String get tcGrandmaNameLabel => 'Grandma name';

  @override
  String get tcGrandpaNameLabel => 'Grandpa name';

  @override
  String get tcBrothersNamesTitle => 'Brothers names (optional)';

  @override
  String get tcSistersNamesTitle => 'Sisters names (optional)';

  @override
  String get tcAddBrotherButton => 'Add brother';

  @override
  String get tcAddSisterButton => 'Add sister';

  @override
  String get tcBrotherLabel => 'Brother';

  @override
  String get tcSisterLabel => 'Sister';

  @override
  String tcIndexedName(String prefix, int index) {
    return '$prefix $index name';
  }

  @override
  String get tcRemoveTooltip => 'Remove';

  @override
  String get tcIllustrationsEnabled => 'Illustrations enabled';

  @override
  String get tcSafeMode => 'Safe mode';

  @override
  String get tcDisableScary => 'Disable scary content';

  @override
  String get tcRequireParentConfirmation => 'Require parent confirmation for older';

  @override
  String get tcRunButton => 'Run dry-run through gateway';

  @override
  String get tcRunning => 'Running...';

  @override
  String tcEffectivePolicyHeader(String id) {
    return 'Effective Policy: $id';
  }

  @override
  String tcTemplatesMatched(int count) {
    return 'Templates matched: $count';
  }

  @override
  String get tcCardEffectivePolicy => 'Effective Policy + Template Selection';

  @override
  String get tcCardComposedPayload => 'Composed Payload';

  @override
  String get tcCardGatewayResponse => 'Gateway Response';

  @override
  String get templatesSearchHint => 'Search by name/tag/description';

  @override
  String templatesTypeFilterLabel(String value) {
    return 'Type: $value';
  }

  @override
  String get templatesNewTemplate => 'New Template';

  @override
  String get templatesColumnActive => 'Active';

  @override
  String get templatesColumnName => 'Name';

  @override
  String get templatesColumnType => 'Type';

  @override
  String get templatesColumnTags => 'Tags';

  @override
  String get templatesColumnScopes => 'Scopes';

  @override
  String get templatesColumnActions => 'Actions';

  @override
  String templatesEditorTitle(String id) {
    return 'Template: $id';
  }

  @override
  String get templatesTemplateTypeLabel => 'Template type';

  @override
  String get templatesDescriptionLabel => 'Description';

  @override
  String get templatesTagsLabel => 'Tags (comma/newline separated)';

  @override
  String get templatesScopesHeader => 'Scopes';

  @override
  String get templatesAddScopeButton => 'Add scope';

  @override
  String get templatesTemplateBody => 'Template Body';

  @override
  String get templatesSystemPromptLabel => 'System prompt (optional)';

  @override
  String get templatesInstructionsLabel => 'Instructions';

  @override
  String get templatesNegativePromptLabel => 'Negative prompt (optional)';

  @override
  String get policyAgeMinLabel => 'Age min';

  @override
  String get policyAgeMaxLabel => 'Age max';

  @override
  String get policyScopeLanguageLabel => 'Language';

  @override
  String get policyScopeTierLabel => 'Tier';

  @override
  String get templatesArchiveTitle => 'Archive Template';

  @override
  String templatesArchiveConfirm(String name) {
    return 'Delete template \"$name\"? This action cannot be undone.';
  }

  @override
  String policyEditorTitle(String id) {
    return 'Edit Policy: $id';
  }

  @override
  String get policyActive => 'Active';

  @override
  String get policyScope => 'Scope';

  @override
  String get policyContentRules => 'Content Rules';

  @override
  String get policySafeModeDefault => 'Safe mode default';

  @override
  String get policyDisallowViolence => 'Disallow violence';

  @override
  String get policyDisallowDrugs => 'Disallow drugs';

  @override
  String get policyDisallowHate => 'Disallow hate';

  @override
  String get policyDisallowSexualContent => 'Disallow sexual content';

  @override
  String get policyDisallowReligiousPolitical => 'Disallow religious/political';

  @override
  String get policyParentConfirmationForOlder => 'Parent confirmation for older';

  @override
  String get policyDisallowScary => 'Disallow scary content';

  @override
  String get policyAllowPersonalNames => 'Allow personal names';

  @override
  String get policyCustomBannedWords => 'Custom banned words (comma/newline separated)';

  @override
  String get policyPromptConstraints => 'Prompt Constraints';

  @override
  String get policyMaxTokensHint => 'Max tokens hint';

  @override
  String get policyMaxCharsHint => 'Max chars hint';

  @override
  String get policyReadingLevel => 'Reading level (simple|normal)';

  @override
  String get policyEnforceStructure => 'Enforce structure';

  @override
  String get policyImageRules => 'Image Rules';

  @override
  String get policyAllowImages => 'Allow images';

  @override
  String get policyAllowedImageStyles => 'Allowed image styles (comma/newline separated)';

  @override
  String get policyVersionStamp => 'Version stamp';
}
