// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Armenian (`hy`).
class AppLocalizationsHy extends AppLocalizations {
  AppLocalizationsHy([String locale = 'hy']) : super(locale);

  @override
  String policiesLanguageFilterLabel(String value) {
    return 'Լեզու՝ $value';
  }

  @override
  String policiesTierFilterLabel(String value) {
    return 'Սեզոն: $value';
  }

  @override
  String get policiesAgeRangeFilter => 'Տարիքի զտիչ';

  @override
  String get policiesNewPolicy => 'Նոր քաղաքականություն';

  @override
  String get commonReload => 'Թարմացնել';

  @override
  String get policiesBackfillInProgress => 'Լցվում է...';

  @override
  String get policiesBackfillButton => 'Լցնել allowPersonalNames';

  @override
  String policiesBackfillSummary(int scanned, int updated, int skipped) {
    return 'Ավելացված է։ Սքանավորված: $scanned, թարմացված: $updated, բաց թողնված: $skipped.';
  }

  @override
  String get policiesDeletePolicyTitle => 'Ջնջել քաղաքականությունը';

  @override
  String policiesDeletePolicyConfirm(String id) {
    return 'Ջնջել քաղաքականությունը «$id»? Այս գործողությունը չի վերադարձվու։';
  }

  @override
  String get commonCancel => 'Չեղարկել';

  @override
  String get commonDelete => 'Ջնջել';

  @override
  String get policiesColumnActive => 'Ակտիվ';

  @override
  String get policiesColumnPolicyId => 'Քաղաքականություն ID';

  @override
  String get policiesColumnScope => 'Սկոպ';

  @override
  String get policiesColumnReadingLevel => 'Կարդալու մակարդակ';

  @override
  String get policiesColumnVersionStamp => 'Տողագրություն';

  @override
  String get policiesColumnActions => 'Գործողություններ';

  @override
  String get commonEdit => 'Խմբագրել';

  @override
  String get commonSave => 'Պահպանել';

  @override
  String get commonAdd => 'Ավելացնել';

  @override
  String get commonRemove => 'Հեռացնել';

  @override
  String get testConsoleTitle => 'Գործառնական կոնսոլ ինժեներ';

  @override
  String get testConsoleDescription => 'Տեղային ստուգում, шлюз dry-run և test_runs_v1-ի պահպանություն.';

  @override
  String get tcAgeLabel => 'Տարիք';

  @override
  String get tcTierLabel => 'Ծառայության տեսակը';

  @override
  String get tcLanguageLabel => 'Լեզու';

  @override
  String get tcHeroTypeLabel => 'Դեմքի տեսակը';

  @override
  String get tcHeroAgeLabel => 'Գլխավոր հերոսի տարիքը';

  @override
  String get tcStoryIdeaLabel => 'Ստորի գաղափար';

  @override
  String get tcLocationLabel => 'Գետկոց';

  @override
  String get tcGenreLabel => ' janr';

  @override
  String get tcLengthLabel => 'Երկարությունը';

  @override
  String get tcComplexityLabel => 'Բարդությունը';

  @override
  String get tcCreativityLabel => 'Էջարդյունք';

  @override
  String get tcFamilyMembersLabel => 'Ընտանեկան անդամներ (dad:1,mom:1,grandma:1)';

  @override
  String get tcFamilyNamesTitle => 'Ընտանեկան անուններ (ըստ ցանկության)';

  @override
  String get tcMomNameLabel => 'Մայրիկի անունը';

  @override
  String get tcDadNameLabel => 'Ասիկի անունը';

  @override
  String get tcGrandmaNameLabel => 'Տատիկի անունը';

  @override
  String get tcGrandpaNameLabel => 'ՓՓյակի անունը';

  @override
  String get tcBrothersNamesTitle => 'Ուղղասերների անուններ (ըստ ցանկության)';

  @override
  String get tcSistersNamesTitle => 'Քույրերի անուններ (ըստ ցանկության)';

  @override
  String get tcAddBrotherButton => 'Ավելացնել եղբոր';

  @override
  String get tcAddSisterButton => 'Ավելացնել քույր';

  @override
  String get tcBrotherLabel => 'Եղբայր';

  @override
  String get tcSisterLabel => 'Քույր';

  @override
  String tcIndexedName(String prefix, int index) {
    return '$prefix $index անուն';
  }

  @override
  String get tcRemoveTooltip => 'Հեռացնել';

  @override
  String get tcIllustrationsEnabled => 'Նկարագրություններ միացված են';

  @override
  String get tcSafeMode => 'Ապահով ռեժիմ';

  @override
  String get tcDisableScary => 'Արգելել վախկոտ բովանդակությունը';

  @override
  String get tcRequireParentConfirmation => 'Պահանջել ծնողի հաստատում';

  @override
  String get tcRunButton => 'Կատարել dry-run';

  @override
  String get tcRunning => 'Աշխատում...';

  @override
  String tcEffectivePolicyHeader(String id) {
    return 'Արդյունավետ քաղաքականություն: $id';
  }

  @override
  String tcTemplatesMatched(int count) {
    return 'Պատասխանող տեմպլեյթներ: $count';
  }

  @override
  String get tcCardEffectivePolicy => 'Արդյունավետ քաղաքականություն + ընտրություն';

  @override
  String get tcCardComposedPayload => 'Սահմանված payload';

  @override
  String get tcCardGatewayResponse => 'Շնորհի պատասխան';

  @override
  String get templatesSearchHint => 'Փնտրեք անունով/թեգով/քննարկմամբ';

  @override
  String templatesTypeFilterLabel(String value) {
    return 'Տեսակ: $value';
  }

  @override
  String get templatesNewTemplate => 'Նոր տեմպլեյթ';

  @override
  String get templatesColumnActive => 'Ակտիվ';

  @override
  String get templatesColumnName => 'Անուն';

  @override
  String get templatesColumnType => 'Տեսակ';

  @override
  String get templatesColumnTags => 'Թեգեր';

  @override
  String get templatesColumnScopes => 'Հավաքածուներ';

  @override
  String get templatesColumnActions => 'Գործողություններ';

  @override
  String templatesEditorTitle(String id) {
    return 'Տեմպլեյթ: $id';
  }

  @override
  String get templatesTemplateTypeLabel => 'Տեմպլեյթի տեսակ';

  @override
  String get templatesDescriptionLabel => 'Նկարագրություն';

  @override
  String get templatesTagsLabel => 'Թեգեր (կոմա/նոր տող)';

  @override
  String get templatesScopesHeader => 'Հավաքածուներ';

  @override
  String get templatesAddScopeButton => 'Ավելացնել հավաքածու';

  @override
  String get templatesTemplateBody => 'Տեմպլեյթի մարմին';

  @override
  String get templatesSystemPromptLabel => 'Համակարգային հուշում (ըստ ցանկության)';

  @override
  String get templatesInstructionsLabel => 'Հրահանգներ';

  @override
  String get templatesNegativePromptLabel => 'Բացասական հուշում (ըստ ցանկության)';

  @override
  String get policyAgeMinLabel => 'Նվազ. տարիք';

  @override
  String get policyAgeMaxLabel => 'Առավ. տարիք';

  @override
  String get policyScopeLanguageLabel => 'Լեզու';

  @override
  String get policyScopeTierLabel => 'Սեզոն';

  @override
  String get templatesArchiveTitle => 'Արկիվացում';

  @override
  String templatesArchiveConfirm(String name) {
    return 'Ջնջել տեմպլեյթը \"$name\"? Սա անվերադարձ գործողություն է.';
  }

  @override
  String policyEditorTitle(String id) {
    return 'Խմբագրել քաղաքականությունը: $id';
  }

  @override
  String get policyActive => 'Ակտիվ';

  @override
  String get policyScope => 'Սկոպ';

  @override
  String get policyContentRules => 'Բովանդակության կանոններ';

  @override
  String get policySafeModeDefault => 'Ամբողջական ռեժիմ ըստ լռության';

  @override
  String get policyDisallowViolence => 'արգելել բռնությունը';

  @override
  String get policyDisallowDrugs => 'արգելել թմրանյութերը';

  @override
  String get policyDisallowHate => 'արգելել ատելությունը';

  @override
  String get policyDisallowSexualContent => 'արգելել սեռական բովանդակությունը';

  @override
  String get policyDisallowReligiousPolitical => 'արգելել կրոնական/քաղաքական';

  @override
  String get policyParentConfirmationForOlder => 'Ծնողական հաստատում մեծերի համար';

  @override
  String get policyDisallowScary => 'Արգելել վախենալու բովանդակությունը';

  @override
  String get policyAllowPersonalNames => 'Թույլատրել անձնական անուններ';

  @override
  String get policyCustomBannedWords => 'Անհրաժեշտ արգելված բառեր (կոմա/նոր տող)';

  @override
  String get policyPromptConstraints => 'Պռոմտի սահմանափակումներ';

  @override
  String get policyMaxTokensHint => 'Մաքս տոկենների ենթադրություն';

  @override
  String get policyMaxCharsHint => 'Մաքս նիշերի ենթադրություն';

  @override
  String get policyReadingLevel => 'Կարդալու մակարդակը (simple|normal)';

  @override
  String get policyEnforceStructure => 'Պահանջել կառուցվածք';

  @override
  String get policyImageRules => 'Նկարի կանոններ';

  @override
  String get policyAllowImages => 'Թույլատրել նկարներ';

  @override
  String get policyAllowedImageStyles => 'Թույլատրելի ոճեր (կոմա/նոր տող)';

  @override
  String get policyVersionStamp => 'Տարբերակ';
}
