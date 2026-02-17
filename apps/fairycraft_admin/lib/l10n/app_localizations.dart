import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hy.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hy'),
    Locale('ru')
  ];

  /// No description provided for @policiesLanguageFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Language: {value}'**
  String policiesLanguageFilterLabel(String value);

  /// No description provided for @policiesTierFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Tier: {value}'**
  String policiesTierFilterLabel(String value);

  /// No description provided for @policiesAgeRangeFilter.
  ///
  /// In en, this message translates to:
  /// **'Age range filter'**
  String get policiesAgeRangeFilter;

  /// No description provided for @policiesNewPolicy.
  ///
  /// In en, this message translates to:
  /// **'New Policy'**
  String get policiesNewPolicy;

  /// No description provided for @commonReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get commonReload;

  /// No description provided for @policiesBackfillInProgress.
  ///
  /// In en, this message translates to:
  /// **'Backfilling...'**
  String get policiesBackfillInProgress;

  /// No description provided for @policiesBackfillButton.
  ///
  /// In en, this message translates to:
  /// **'Backfill allowPersonalNames'**
  String get policiesBackfillButton;

  /// No description provided for @policiesBackfillSummary.
  ///
  /// In en, this message translates to:
  /// **'Backfill completed. Scanned: {scanned}, updated: {updated}, skipped: {skipped}.'**
  String policiesBackfillSummary(int scanned, int updated, int skipped);

  /// No description provided for @policiesDeletePolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Policy'**
  String get policiesDeletePolicyTitle;

  /// No description provided for @policiesDeletePolicyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete policy \"{id}\"? This action cannot be undone.'**
  String policiesDeletePolicyConfirm(String id);

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @policiesColumnActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get policiesColumnActive;

  /// No description provided for @policiesColumnPolicyId.
  ///
  /// In en, this message translates to:
  /// **'Policy ID'**
  String get policiesColumnPolicyId;

  /// No description provided for @policiesColumnScope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get policiesColumnScope;

  /// No description provided for @policiesColumnReadingLevel.
  ///
  /// In en, this message translates to:
  /// **'Reading Level'**
  String get policiesColumnReadingLevel;

  /// No description provided for @policiesColumnVersionStamp.
  ///
  /// In en, this message translates to:
  /// **'Version Stamp'**
  String get policiesColumnVersionStamp;

  /// No description provided for @policiesColumnActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get policiesColumnActions;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @testConsoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent Test Console'**
  String get testConsoleTitle;

  /// No description provided for @testConsoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Runs local effective policy resolution, calls gateway dry-run, and stores test_runs_v1.'**
  String get testConsoleDescription;

  /// No description provided for @tcAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get tcAgeLabel;

  /// No description provided for @tcTierLabel.
  ///
  /// In en, this message translates to:
  /// **'Tier'**
  String get tcTierLabel;

  /// No description provided for @tcLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get tcLanguageLabel;

  /// No description provided for @tcHeroTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Hero type'**
  String get tcHeroTypeLabel;

  /// No description provided for @tcHeroAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Hero age'**
  String get tcHeroAgeLabel;

  /// No description provided for @tcStoryIdeaLabel.
  ///
  /// In en, this message translates to:
  /// **'Story idea'**
  String get tcStoryIdeaLabel;

  /// No description provided for @tcLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get tcLocationLabel;

  /// No description provided for @tcGenreLabel.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get tcGenreLabel;

  /// No description provided for @tcLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get tcLengthLabel;

  /// No description provided for @tcComplexityLabel.
  ///
  /// In en, this message translates to:
  /// **'Complexity'**
  String get tcComplexityLabel;

  /// No description provided for @tcCreativityLabel.
  ///
  /// In en, this message translates to:
  /// **'Creativity'**
  String get tcCreativityLabel;

  /// No description provided for @tcFamilyMembersLabel.
  ///
  /// In en, this message translates to:
  /// **'Family members (dad:1,mom:1,grandma:1)'**
  String get tcFamilyMembersLabel;

  /// No description provided for @tcFamilyNamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Family names (optional)'**
  String get tcFamilyNamesTitle;

  /// No description provided for @tcMomNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Mom name'**
  String get tcMomNameLabel;

  /// No description provided for @tcDadNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Dad name'**
  String get tcDadNameLabel;

  /// No description provided for @tcGrandmaNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Grandma name'**
  String get tcGrandmaNameLabel;

  /// No description provided for @tcGrandpaNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Grandpa name'**
  String get tcGrandpaNameLabel;

  /// No description provided for @tcBrothersNamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Brothers names (optional)'**
  String get tcBrothersNamesTitle;

  /// No description provided for @tcSistersNamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sisters names (optional)'**
  String get tcSistersNamesTitle;

  /// No description provided for @tcAddBrotherButton.
  ///
  /// In en, this message translates to:
  /// **'Add brother'**
  String get tcAddBrotherButton;

  /// No description provided for @tcAddSisterButton.
  ///
  /// In en, this message translates to:
  /// **'Add sister'**
  String get tcAddSisterButton;

  /// No description provided for @tcBrotherLabel.
  ///
  /// In en, this message translates to:
  /// **'Brother'**
  String get tcBrotherLabel;

  /// No description provided for @tcSisterLabel.
  ///
  /// In en, this message translates to:
  /// **'Sister'**
  String get tcSisterLabel;

  /// No description provided for @tcIndexedName.
  ///
  /// In en, this message translates to:
  /// **'{prefix} {index} name'**
  String tcIndexedName(String prefix, int index);

  /// No description provided for @tcRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get tcRemoveTooltip;

  /// No description provided for @tcIllustrationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Illustrations enabled'**
  String get tcIllustrationsEnabled;

  /// No description provided for @tcSafeMode.
  ///
  /// In en, this message translates to:
  /// **'Safe mode'**
  String get tcSafeMode;

  /// No description provided for @tcDisableScary.
  ///
  /// In en, this message translates to:
  /// **'Disable scary content'**
  String get tcDisableScary;

  /// No description provided for @tcRequireParentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Require parent confirmation for older'**
  String get tcRequireParentConfirmation;

  /// No description provided for @tcRunButton.
  ///
  /// In en, this message translates to:
  /// **'Run dry-run through gateway'**
  String get tcRunButton;

  /// No description provided for @tcRunning.
  ///
  /// In en, this message translates to:
  /// **'Running...'**
  String get tcRunning;

  /// No description provided for @tcEffectivePolicyHeader.
  ///
  /// In en, this message translates to:
  /// **'Effective Policy: {id}'**
  String tcEffectivePolicyHeader(String id);

  /// No description provided for @tcTemplatesMatched.
  ///
  /// In en, this message translates to:
  /// **'Templates matched: {count}'**
  String tcTemplatesMatched(int count);

  /// No description provided for @tcCardEffectivePolicy.
  ///
  /// In en, this message translates to:
  /// **'Effective Policy + Template Selection'**
  String get tcCardEffectivePolicy;

  /// No description provided for @tcCardComposedPayload.
  ///
  /// In en, this message translates to:
  /// **'Composed Payload'**
  String get tcCardComposedPayload;

  /// No description provided for @tcCardGatewayResponse.
  ///
  /// In en, this message translates to:
  /// **'Gateway Response'**
  String get tcCardGatewayResponse;

  /// No description provided for @templatesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name/tag/description'**
  String get templatesSearchHint;

  /// No description provided for @templatesTypeFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Type: {value}'**
  String templatesTypeFilterLabel(String value);

  /// No description provided for @templatesNewTemplate.
  ///
  /// In en, this message translates to:
  /// **'New Template'**
  String get templatesNewTemplate;

  /// No description provided for @templatesColumnActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get templatesColumnActive;

  /// No description provided for @templatesColumnName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get templatesColumnName;

  /// No description provided for @templatesColumnType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get templatesColumnType;

  /// No description provided for @templatesColumnTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get templatesColumnTags;

  /// No description provided for @templatesColumnScopes.
  ///
  /// In en, this message translates to:
  /// **'Scopes'**
  String get templatesColumnScopes;

  /// No description provided for @templatesColumnActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get templatesColumnActions;

  /// No description provided for @templatesEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Template: {id}'**
  String templatesEditorTitle(String id);

  /// No description provided for @templatesTemplateTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Template type'**
  String get templatesTemplateTypeLabel;

  /// No description provided for @templatesDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get templatesDescriptionLabel;

  /// No description provided for @templatesTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags (comma/newline separated)'**
  String get templatesTagsLabel;

  /// No description provided for @templatesScopesHeader.
  ///
  /// In en, this message translates to:
  /// **'Scopes'**
  String get templatesScopesHeader;

  /// No description provided for @templatesAddScopeButton.
  ///
  /// In en, this message translates to:
  /// **'Add scope'**
  String get templatesAddScopeButton;

  /// No description provided for @templatesTemplateBody.
  ///
  /// In en, this message translates to:
  /// **'Template Body'**
  String get templatesTemplateBody;

  /// No description provided for @templatesSystemPromptLabel.
  ///
  /// In en, this message translates to:
  /// **'System prompt (optional)'**
  String get templatesSystemPromptLabel;

  /// No description provided for @templatesInstructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get templatesInstructionsLabel;

  /// No description provided for @templatesNegativePromptLabel.
  ///
  /// In en, this message translates to:
  /// **'Negative prompt (optional)'**
  String get templatesNegativePromptLabel;

  /// No description provided for @policyAgeMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Age min'**
  String get policyAgeMinLabel;

  /// No description provided for @policyAgeMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Age max'**
  String get policyAgeMaxLabel;

  /// No description provided for @policyScopeLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get policyScopeLanguageLabel;

  /// No description provided for @policyScopeTierLabel.
  ///
  /// In en, this message translates to:
  /// **'Tier'**
  String get policyScopeTierLabel;

  /// No description provided for @templatesArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive Template'**
  String get templatesArchiveTitle;

  /// No description provided for @templatesArchiveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete template \"{name}\"? This action cannot be undone.'**
  String templatesArchiveConfirm(String name);

  /// No description provided for @policyEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Policy: {id}'**
  String policyEditorTitle(String id);

  /// No description provided for @policyActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get policyActive;

  /// No description provided for @policyScope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get policyScope;

  /// No description provided for @policyContentRules.
  ///
  /// In en, this message translates to:
  /// **'Content Rules'**
  String get policyContentRules;

  /// No description provided for @policySafeModeDefault.
  ///
  /// In en, this message translates to:
  /// **'Safe mode default'**
  String get policySafeModeDefault;

  /// No description provided for @policyDisallowViolence.
  ///
  /// In en, this message translates to:
  /// **'Disallow violence'**
  String get policyDisallowViolence;

  /// No description provided for @policyDisallowDrugs.
  ///
  /// In en, this message translates to:
  /// **'Disallow drugs'**
  String get policyDisallowDrugs;

  /// No description provided for @policyDisallowHate.
  ///
  /// In en, this message translates to:
  /// **'Disallow hate'**
  String get policyDisallowHate;

  /// No description provided for @policyDisallowSexualContent.
  ///
  /// In en, this message translates to:
  /// **'Disallow sexual content'**
  String get policyDisallowSexualContent;

  /// No description provided for @policyDisallowReligiousPolitical.
  ///
  /// In en, this message translates to:
  /// **'Disallow religious/political'**
  String get policyDisallowReligiousPolitical;

  /// No description provided for @policyParentConfirmationForOlder.
  ///
  /// In en, this message translates to:
  /// **'Parent confirmation for older'**
  String get policyParentConfirmationForOlder;

  /// No description provided for @policyDisallowScary.
  ///
  /// In en, this message translates to:
  /// **'Disallow scary content'**
  String get policyDisallowScary;

  /// No description provided for @policyAllowPersonalNames.
  ///
  /// In en, this message translates to:
  /// **'Allow personal names'**
  String get policyAllowPersonalNames;

  /// No description provided for @policyCustomBannedWords.
  ///
  /// In en, this message translates to:
  /// **'Custom banned words (comma/newline separated)'**
  String get policyCustomBannedWords;

  /// No description provided for @policyPromptConstraints.
  ///
  /// In en, this message translates to:
  /// **'Prompt Constraints'**
  String get policyPromptConstraints;

  /// No description provided for @policyMaxTokensHint.
  ///
  /// In en, this message translates to:
  /// **'Max tokens hint'**
  String get policyMaxTokensHint;

  /// No description provided for @policyMaxCharsHint.
  ///
  /// In en, this message translates to:
  /// **'Max chars hint'**
  String get policyMaxCharsHint;

  /// No description provided for @policyReadingLevel.
  ///
  /// In en, this message translates to:
  /// **'Reading level (simple|normal)'**
  String get policyReadingLevel;

  /// No description provided for @policyEnforceStructure.
  ///
  /// In en, this message translates to:
  /// **'Enforce structure'**
  String get policyEnforceStructure;

  /// No description provided for @policyImageRules.
  ///
  /// In en, this message translates to:
  /// **'Image Rules'**
  String get policyImageRules;

  /// No description provided for @policyAllowImages.
  ///
  /// In en, this message translates to:
  /// **'Allow images'**
  String get policyAllowImages;

  /// No description provided for @policyAllowedImageStyles.
  ///
  /// In en, this message translates to:
  /// **'Allowed image styles (comma/newline separated)'**
  String get policyAllowedImageStyles;

  /// No description provided for @policyVersionStamp.
  ///
  /// In en, this message translates to:
  /// **'Version stamp'**
  String get policyVersionStamp;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hy', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hy': return AppLocalizationsHy();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
