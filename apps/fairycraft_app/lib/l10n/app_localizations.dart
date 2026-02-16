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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('hy'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'FairyCraft'**
  String get appName;

  /// No description provided for @commonAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get commonAccount;

  /// No description provided for @commonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// No description provided for @commonEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @commonPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// No description provided for @commonBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get commonBackToLogin;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get commonNotAvailable;

  /// No description provided for @commonLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get commonLink;

  /// No description provided for @commonUnlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get commonUnlink;

  /// No description provided for @commonStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get commonStop;

  /// No description provided for @commonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get commonUpdate;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'A calm place to create bedtime stories together.'**
  String get homeTagline;

  /// No description provided for @homeCreateStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Story'**
  String get homeCreateStoryTitle;

  /// No description provided for @homeCreateStorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new adventure in one tap.'**
  String get homeCreateStorySubtitle;

  /// No description provided for @homeMyStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Stories'**
  String get homeMyStoriesTitle;

  /// No description provided for @homeMyStoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue reading saved chapters.'**
  String get homeMyStoriesSubtitle;

  /// No description provided for @homeStoryPreferences.
  ///
  /// In en, this message translates to:
  /// **'Story Preferences'**
  String get homeStoryPreferences;

  /// No description provided for @homeAccountTooltip.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get homeAccountTooltip;

  /// No description provided for @homeSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsTooltip;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'FairyCraft Login'**
  String get authLoginTitle;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginButton;

  /// No description provided for @authCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountButton;

  /// No description provided for @authForgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get authForgotPasswordButton;

  /// No description provided for @authLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String authLoginFailed(String error);

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create FairyCraft Account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterButton;

  /// No description provided for @authRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String authRegisterFailed(String error);

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetPasswordTitle;

  /// No description provided for @authSendResetEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Send reset email'**
  String get authSendResetEmailButton;

  /// No description provided for @authResetEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to send reset email: {error}'**
  String authResetEmailFailed(String error);

  /// No description provided for @authResetSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset sent'**
  String get authResetSentTitle;

  /// No description provided for @authResetSentBody.
  ///
  /// In en, this message translates to:
  /// **'If the email exists, reset instructions were sent.'**
  String get authResetSentBody;

  /// No description provided for @authCheckingSession.
  ///
  /// In en, this message translates to:
  /// **'Checking session...'**
  String get authCheckingSession;

  /// No description provided for @authSessionSlow.
  ///
  /// In en, this message translates to:
  /// **'Session check is taking longer than expected.'**
  String get authSessionSlow;

  /// No description provided for @authChangePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get authChangePasswordTitle;

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPasswordLabel;

  /// No description provided for @authPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get authPasswordUpdated;

  /// No description provided for @authPasswordChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String authPasswordChangeFailed(String error);

  /// No description provided for @authProviderLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Provider link'**
  String get authProviderLinkTitle;

  /// No description provided for @authLinkGoogleStub.
  ///
  /// In en, this message translates to:
  /// **'Link Google (stub)'**
  String get authLinkGoogleStub;

  /// No description provided for @authLinkFacebookStub.
  ///
  /// In en, this message translates to:
  /// **'Link Facebook (stub)'**
  String get authLinkFacebookStub;

  /// No description provided for @authProviderLinkRequested.
  ///
  /// In en, this message translates to:
  /// **'{provider} link request completed (stub for now).'**
  String authProviderLinkRequested(String provider);

  /// No description provided for @authProviderLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String authProviderLinkFailed(String error);

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountEmailLabel;

  /// No description provided for @accountLinkedProviders.
  ///
  /// In en, this message translates to:
  /// **'Linked providers'**
  String get accountLinkedProviders;

  /// No description provided for @accountGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get accountGoogle;

  /// No description provided for @accountFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get accountFacebook;

  /// No description provided for @accountEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Email & Password'**
  String get accountEmailPassword;

  /// No description provided for @accountLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get accountLogout;

  /// No description provided for @accountProviderUnlinked.
  ///
  /// In en, this message translates to:
  /// **'{provider} was unlinked.'**
  String accountProviderUnlinked(String provider);

  /// No description provided for @accountProviderLinkRequested.
  ///
  /// In en, this message translates to:
  /// **'{provider} link requested.'**
  String accountProviderLinkRequested(String provider);

  /// No description provided for @accountProviderUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update provider. Please try again.'**
  String get accountProviderUpdateFailed;

  /// No description provided for @myStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'My stories'**
  String get myStoriesTitle;

  /// No description provided for @myStoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No stories yet.'**
  String get myStoriesEmpty;

  /// No description provided for @myStoriesChaptersCount.
  ///
  /// In en, this message translates to:
  /// **'Chapters: {count}'**
  String myStoriesChaptersCount(int count);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your hero called?'**
  String get onboardingHeroTitle;

  /// No description provided for @onboardingHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'The hero name appears across your stories and can be changed any time.'**
  String get onboardingHeroDescription;

  /// No description provided for @onboardingHeroNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Hero name'**
  String get onboardingHeroNameLabel;

  /// No description provided for @onboardingHeroNameHint.
  ///
  /// In en, this message translates to:
  /// **'Luna, Aram, Mia...'**
  String get onboardingHeroNameHint;

  /// No description provided for @onboardingAgeTitle.
  ///
  /// In en, this message translates to:
  /// **'What age stories fit best?'**
  String get onboardingAgeTitle;

  /// No description provided for @onboardingAgeDescription.
  ///
  /// In en, this message translates to:
  /// **'We use this to keep vocabulary and pacing comfortable.'**
  String get onboardingAgeDescription;

  /// No description provided for @onboardingAgeYears.
  ///
  /// In en, this message translates to:
  /// **'{age} years'**
  String onboardingAgeYears(int age);

  /// No description provided for @onboardingFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Who is in your family?'**
  String get onboardingFamilyTitle;

  /// No description provided for @onboardingFamilyDescription.
  ///
  /// In en, this message translates to:
  /// **'Family mode helps include familiar characters in stories.'**
  String get onboardingFamilyDescription;

  /// No description provided for @onboardingUseFamilyMode.
  ///
  /// In en, this message translates to:
  /// **'Use family mode'**
  String get onboardingUseFamilyMode;

  /// No description provided for @onboardingIllustrationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Illustrations and creativity'**
  String get onboardingIllustrationsTitle;

  /// No description provided for @onboardingIllustrationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose whether stories include images and how imaginative they feel.'**
  String get onboardingIllustrationsDescription;

  /// No description provided for @onboardingAutoIllustrations.
  ///
  /// In en, this message translates to:
  /// **'Auto-illustrations'**
  String get onboardingAutoIllustrations;

  /// No description provided for @onboardingCreativityPercent.
  ///
  /// In en, this message translates to:
  /// **'Creativity {percent}%'**
  String onboardingCreativityPercent(int percent);

  /// No description provided for @familyMom.
  ///
  /// In en, this message translates to:
  /// **'Mom'**
  String get familyMom;

  /// No description provided for @familyDad.
  ///
  /// In en, this message translates to:
  /// **'Dad'**
  String get familyDad;

  /// No description provided for @familySister.
  ///
  /// In en, this message translates to:
  /// **'Sister'**
  String get familySister;

  /// No description provided for @familyBrother.
  ///
  /// In en, this message translates to:
  /// **'Brother'**
  String get familyBrother;

  /// No description provided for @familyGrandma.
  ///
  /// In en, this message translates to:
  /// **'Grandma'**
  String get familyGrandma;

  /// No description provided for @familyGrandpa.
  ///
  /// In en, this message translates to:
  /// **'Grandpa'**
  String get familyGrandpa;

  /// No description provided for @storyPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Story Preferences'**
  String get storyPreferencesTitle;

  /// No description provided for @storyPreferencesCreativeControlTitle.
  ///
  /// In en, this message translates to:
  /// **'Creative control center'**
  String get storyPreferencesCreativeControlTitle;

  /// No description provided for @storyPreferencesCreativeControlDescription.
  ///
  /// In en, this message translates to:
  /// **'These preferences are saved automatically and used every time you create a story.'**
  String get storyPreferencesCreativeControlDescription;

  /// No description provided for @storyPreferencesCharacterSection.
  ///
  /// In en, this message translates to:
  /// **'Character'**
  String get storyPreferencesCharacterSection;

  /// No description provided for @storyPreferencesHeroNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Hero name'**
  String get storyPreferencesHeroNameLabel;

  /// No description provided for @storyPreferencesHeroNameHint.
  ///
  /// In en, this message translates to:
  /// **'Luna, Aram, Mila...'**
  String get storyPreferencesHeroNameHint;

  /// No description provided for @storyPreferencesAgeSection.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get storyPreferencesAgeSection;

  /// No description provided for @storyPreferencesAgeYears.
  ///
  /// In en, this message translates to:
  /// **'{age} years'**
  String storyPreferencesAgeYears(int age);

  /// No description provided for @storyPreferencesLengthSection.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get storyPreferencesLengthSection;

  /// No description provided for @storyPreferencesLengthShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get storyPreferencesLengthShort;

  /// No description provided for @storyPreferencesLengthMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get storyPreferencesLengthMedium;

  /// No description provided for @storyPreferencesLengthLong.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get storyPreferencesLengthLong;

  /// No description provided for @storyPreferencesComplexitySection.
  ///
  /// In en, this message translates to:
  /// **'Complexity'**
  String get storyPreferencesComplexitySection;

  /// No description provided for @storyPreferencesComplexitySimple.
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get storyPreferencesComplexitySimple;

  /// No description provided for @storyPreferencesComplexityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get storyPreferencesComplexityMedium;

  /// No description provided for @storyPreferencesComplexityComplex.
  ///
  /// In en, this message translates to:
  /// **'Complex'**
  String get storyPreferencesComplexityComplex;

  /// No description provided for @storyPreferencesInteractivitySection.
  ///
  /// In en, this message translates to:
  /// **'Interactivity'**
  String get storyPreferencesInteractivitySection;

  /// No description provided for @storyPreferencesInteractiveChoices.
  ///
  /// In en, this message translates to:
  /// **'Use interactive choices'**
  String get storyPreferencesInteractiveChoices;

  /// No description provided for @storyPreferencesFamilySection.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get storyPreferencesFamilySection;

  /// No description provided for @storyPreferencesIncludeFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'Include family members in stories'**
  String get storyPreferencesIncludeFamilyMembers;

  /// No description provided for @storyPreferencesIllustrationsSection.
  ///
  /// In en, this message translates to:
  /// **'Illustrations'**
  String get storyPreferencesIllustrationsSection;

  /// No description provided for @storyPreferencesAddIllustrations.
  ///
  /// In en, this message translates to:
  /// **'Add illustrations automatically'**
  String get storyPreferencesAddIllustrations;

  /// No description provided for @storyPreferencesCreativitySection.
  ///
  /// In en, this message translates to:
  /// **'Creativity'**
  String get storyPreferencesCreativitySection;

  /// No description provided for @storyPreferencesCreativityPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String storyPreferencesCreativityPercent(int percent);

  /// No description provided for @storyPreferencesResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Story Preferences'**
  String get storyPreferencesResetButton;

  /// No description provided for @storySetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Story'**
  String get storySetupTitle;

  /// No description provided for @storySetupPreferencesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Story Preferences'**
  String get storySetupPreferencesTooltip;

  /// No description provided for @storySetupIdeaTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us your story idea'**
  String get storySetupIdeaTitle;

  /// No description provided for @storySetupIdeaHint.
  ///
  /// In en, this message translates to:
  /// **'Type your idea or use voice...'**
  String get storySetupIdeaHint;

  /// No description provided for @storySetupFamilyMode.
  ///
  /// In en, this message translates to:
  /// **'Family mode'**
  String get storySetupFamilyMode;

  /// No description provided for @storySetupFamilyModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Include family members in plot and characters.'**
  String get storySetupFamilyModeSubtitle;

  /// No description provided for @storySetupHeroSection.
  ///
  /// In en, this message translates to:
  /// **'Hero'**
  String get storySetupHeroSection;

  /// No description provided for @storySetupLocationSection.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get storySetupLocationSection;

  /// No description provided for @storySetupStyleSection.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get storySetupStyleSection;

  /// No description provided for @storySetupGenerateButton.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get storySetupGenerateButton;

  /// No description provided for @storySetupErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the story service. Please check connection and try again.'**
  String get storySetupErrorNetwork;

  /// No description provided for @storySetupErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Story creation was not completed. Please try again.'**
  String get storySetupErrorGeneric;

  /// No description provided for @storyReaderNoStorySelected.
  ///
  /// In en, this message translates to:
  /// **'No story selected.'**
  String get storyReaderNoStorySelected;

  /// No description provided for @storyReaderNoChapter.
  ///
  /// In en, this message translates to:
  /// **'No chapter available yet.'**
  String get storyReaderNoChapter;

  /// No description provided for @storyReaderProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Story progress'**
  String get storyReaderProgressTitle;

  /// No description provided for @storyReaderComplete.
  ///
  /// In en, this message translates to:
  /// **'Story complete'**
  String get storyReaderComplete;

  /// No description provided for @storyReaderChapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter {index}'**
  String storyReaderChapter(int index);

  /// No description provided for @storyReaderWhatNext.
  ///
  /// In en, this message translates to:
  /// **'What happens next?'**
  String get storyReaderWhatNext;

  /// No description provided for @storyReaderTheEnd.
  ///
  /// In en, this message translates to:
  /// **'The End'**
  String get storyReaderTheEnd;

  /// No description provided for @storyReaderCompleteDescription.
  ///
  /// In en, this message translates to:
  /// **'This adventure is complete. You can start a new story anytime.'**
  String get storyReaderCompleteDescription;

  /// No description provided for @storyReaderIllustrations.
  ///
  /// In en, this message translates to:
  /// **'Illustrations'**
  String get storyReaderIllustrations;

  /// No description provided for @storyReaderPromptHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the picture you want to see...'**
  String get storyReaderPromptHint;

  /// No description provided for @storyReaderGenerateImage.
  ///
  /// In en, this message translates to:
  /// **'Generate image'**
  String get storyReaderGenerateImage;

  /// No description provided for @storyReaderVoiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get storyReaderVoiceInput;

  /// No description provided for @storyReaderUseRecognizedText.
  ///
  /// In en, this message translates to:
  /// **'Use recognized text'**
  String get storyReaderUseRecognizedText;

  /// No description provided for @storyReaderLastPrompt.
  ///
  /// In en, this message translates to:
  /// **'Last prompt: {prompt}'**
  String storyReaderLastPrompt(String prompt);

  /// No description provided for @storyReaderErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connection is unstable. Please try again.'**
  String get storyReaderErrorNetwork;

  /// No description provided for @storyReaderErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get storyReaderErrorGeneric;

  /// No description provided for @debugFirebaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Firebase debug'**
  String get debugFirebaseTitle;

  /// No description provided for @debugFirebaseReady.
  ///
  /// In en, this message translates to:
  /// **'Firebase ready: {value}'**
  String debugFirebaseReady(String value);

  /// No description provided for @debugAppCheckAttempted.
  ///
  /// In en, this message translates to:
  /// **'AppCheck attempted: {value}'**
  String debugAppCheckAttempted(String value);

  /// No description provided for @debugBootstrapError.
  ///
  /// In en, this message translates to:
  /// **'Bootstrap error: {value}'**
  String debugBootstrapError(String value);

  /// No description provided for @debugAuthService.
  ///
  /// In en, this message translates to:
  /// **'Auth service: {value}'**
  String debugAuthService(String value);

  /// No description provided for @voiceHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice help'**
  String get voiceHelpTitle;

  /// No description provided for @voiceHelpDescription.
  ///
  /// In en, this message translates to:
  /// **'Use microphone to capture ideas for story setup or prompts.'**
  String get voiceHelpDescription;

  /// No description provided for @voiceHelpListening.
  ///
  /// In en, this message translates to:
  /// **'Listening: {value}'**
  String voiceHelpListening(String value);

  /// No description provided for @voiceHelpLastText.
  ///
  /// In en, this message translates to:
  /// **'Last text: {value}'**
  String voiceHelpLastText(String value);

  /// No description provided for @voiceHelpStartListening.
  ///
  /// In en, this message translates to:
  /// **'Start listening'**
  String get voiceHelpStartListening;

  /// No description provided for @voiceHelpStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get voiceHelpStop;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGeneralAccessibilityHeader.
  ///
  /// In en, this message translates to:
  /// **'General / Accessibility'**
  String get settingsGeneralAccessibilityHeader;

  /// No description provided for @settingsReduceMotionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReduceMotionTitle;

  /// No description provided for @settingsReduceMotionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off to minimize transitions and movement effects.'**
  String get settingsReduceMotionSubtitle;

  /// No description provided for @settingsLanguageHeader.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageHeader;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsVoiceInputHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice input help'**
  String get settingsVoiceInputHelpTitle;

  /// No description provided for @settingsVoiceInputLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice input language'**
  String get settingsVoiceInputLanguageTitle;

  /// No description provided for @settingsVoiceInputLanguageAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get settingsVoiceInputLanguageAuto;

  /// No description provided for @settingsVoiceInputLanguageApp.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsVoiceInputLanguageApp;

  /// No description provided for @settingsVoiceInputLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsVoiceInputLanguageEnglish;

  /// No description provided for @settingsVoiceInputLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get settingsVoiceInputLanguageRussian;

  /// No description provided for @settingsVoiceInputLanguageArmenian.
  ///
  /// In en, this message translates to:
  /// **'Armenian'**
  String get settingsVoiceInputLanguageArmenian;

  /// No description provided for @settingsDefaultNarrationVoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Default narration voice'**
  String get settingsDefaultNarrationVoiceTitle;

  /// No description provided for @settingsDefaultNarrationVoiceComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get settingsDefaultNarrationVoiceComingSoon;

  /// No description provided for @settingsAudioHeader.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get settingsAudioHeader;

  /// No description provided for @settingsVoiceNarrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice narration'**
  String get settingsVoiceNarrationTitle;

  /// No description provided for @settingsDefaultNarrationVoiceSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Default narration voice'**
  String get settingsDefaultNarrationVoiceSystemTitle;

  /// No description provided for @settingsDefaultNarrationVoiceSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System default selector'**
  String get settingsDefaultNarrationVoiceSystemSubtitle;

  /// No description provided for @settingsVolumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get settingsVolumeTitle;

  /// No description provided for @settingsSpeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get settingsSpeedTitle;

  /// No description provided for @settingsIntensityTitle.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get settingsIntensityTitle;

  /// No description provided for @settingsTestVoiceButton.
  ///
  /// In en, this message translates to:
  /// **'Test voice'**
  String get settingsTestVoiceButton;

  /// No description provided for @settingsChooseVoiceSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose narration voice'**
  String get settingsChooseVoiceSheetTitle;

  /// No description provided for @settingsNoVoicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No available voices for this language.'**
  String get settingsNoVoicesAvailable;

  /// No description provided for @settingsLoadingVoices.
  ///
  /// In en, this message translates to:
  /// **'Loading voices...'**
  String get settingsLoadingVoices;

  /// No description provided for @settingsLanguageScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageScreenTitle;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get settingsLanguageRussian;

  /// No description provided for @settingsLanguageArmenian.
  ///
  /// In en, this message translates to:
  /// **'Armenian'**
  String get settingsLanguageArmenian;

  /// No description provided for @settingsVoiceHelpScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice input help'**
  String get settingsVoiceHelpScreenTitle;

  /// No description provided for @settingsVoiceHelpDescription.
  ///
  /// In en, this message translates to:
  /// **'Use voice input to quickly capture ideas for stories.'**
  String get settingsVoiceHelpDescription;

  /// No description provided for @settingsVoiceHelpPointOne.
  ///
  /// In en, this message translates to:
  /// **'Speak clearly and keep the device near you.'**
  String get settingsVoiceHelpPointOne;

  /// No description provided for @settingsVoiceHelpPointTwo.
  ///
  /// In en, this message translates to:
  /// **'Armenian, Russian, and English input are supported.'**
  String get settingsVoiceHelpPointTwo;

  /// No description provided for @settingsVoiceHelpPointThree.
  ///
  /// In en, this message translates to:
  /// **'You can edit recognized text before generating.'**
  String get settingsVoiceHelpPointThree;

  /// No description provided for @settingsTestVoicePhrase.
  ///
  /// In en, this message translates to:
  /// **'Hello! This is how your narration voice sounds.'**
  String get settingsTestVoicePhrase;

  /// No description provided for @settingsSystemDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsSystemDefaultLabel;

  /// No description provided for @settingsTtsLanguageModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Narration language'**
  String get settingsTtsLanguageModeTitle;

  /// No description provided for @settingsTtsLanguageModeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto detect'**
  String get settingsTtsLanguageModeAuto;

  /// No description provided for @settingsTtsLanguageModeFollowApp.
  ///
  /// In en, this message translates to:
  /// **'Follow app language'**
  String get settingsTtsLanguageModeFollowApp;

  /// No description provided for @settingsTtsLanguageModeEnglish.
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get settingsTtsLanguageModeEnglish;

  /// No description provided for @settingsTtsLanguageModeRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get settingsTtsLanguageModeRussian;

  /// No description provided for @settingsTtsLanguageModeArmenian.
  ///
  /// In en, this message translates to:
  /// **'Armenian'**
  String get settingsTtsLanguageModeArmenian;

  /// No description provided for @settingsVoiceGenderTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferred voice gender'**
  String get settingsVoiceGenderTitle;

  /// No description provided for @settingsVoiceGenderAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get settingsVoiceGenderAny;

  /// No description provided for @settingsVoiceGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get settingsVoiceGenderFemale;

  /// No description provided for @settingsVoiceGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get settingsVoiceGenderMale;

  /// No description provided for @settingsVoiceQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice quality preset'**
  String get settingsVoiceQualityTitle;

  /// No description provided for @settingsVoiceQualityDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settingsVoiceQualityDefault;

  /// No description provided for @settingsVoiceQualityExpressive.
  ///
  /// In en, this message translates to:
  /// **'ProPlus Expressive'**
  String get settingsVoiceQualityExpressive;

  /// No description provided for @settingsVoiceQualityHighRes.
  ///
  /// In en, this message translates to:
  /// **'ProPlus High-Res'**
  String get settingsVoiceQualityHighRes;

  /// No description provided for @settingsVoiceQualityTurbo.
  ///
  /// In en, this message translates to:
  /// **'ProPlus Turbo'**
  String get settingsVoiceQualityTurbo;

  /// No description provided for @settingsVoiceQualityPro2.
  ///
  /// In en, this message translates to:
  /// **'Pro2'**
  String get settingsVoiceQualityPro2;

  /// No description provided for @settingsVoiceQualityPro1.
  ///
  /// In en, this message translates to:
  /// **'Pro1'**
  String get settingsVoiceQualityPro1;

  /// No description provided for @ttsListenButton.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get ttsListenButton;

  /// No description provided for @ttsNarrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Narration'**
  String get ttsNarrationTitle;

  /// No description provided for @ttsVoiceGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice gender'**
  String get ttsVoiceGenderLabel;

  /// No description provided for @ttsVoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get ttsVoiceLabel;

  /// No description provided for @ttsLanguageModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Language mode'**
  String get ttsLanguageModeLabel;

  /// No description provided for @ttsQualityPresetLabel.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get ttsQualityPresetLabel;

  /// No description provided for @ttsVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get ttsVolumeLabel;

  /// No description provided for @ttsSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get ttsSpeedLabel;

  /// No description provided for @ttsIntensityLabel.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get ttsIntensityLabel;

  /// No description provided for @ttsPlayLabel.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get ttsPlayLabel;

  /// No description provided for @ttsPauseLabel.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get ttsPauseLabel;

  /// No description provided for @ttsResumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get ttsResumeLabel;

  /// No description provided for @ttsStopLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get ttsStopLabel;

  /// No description provided for @ttsPreparingAudioLabel.
  ///
  /// In en, this message translates to:
  /// **'Preparing audio...'**
  String get ttsPreparingAudioLabel;

  /// No description provided for @ttsPreparingAudioChunks.
  ///
  /// In en, this message translates to:
  /// **'Preparing audio... ({current}/{total} chunks)'**
  String ttsPreparingAudioChunks(int current, int total);

  /// No description provided for @ttsPlayingLabel.
  ///
  /// In en, this message translates to:
  /// **'Playing...'**
  String get ttsPlayingLabel;

  /// No description provided for @ttsPausedLabel.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get ttsPausedLabel;

  /// No description provided for @ttsCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ttsCompletedLabel;

  /// No description provided for @ttsErrorNoVoices.
  ///
  /// In en, this message translates to:
  /// **'No voices available for the selected filters.'**
  String get ttsErrorNoVoices;

  /// No description provided for @ttsGenderAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get ttsGenderAny;

  /// No description provided for @ttsGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get ttsGenderFemale;

  /// No description provided for @ttsGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get ttsGenderMale;

  /// No description provided for @ttsLanguageAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get ttsLanguageAuto;

  /// No description provided for @ttsLanguageFollowApp.
  ///
  /// In en, this message translates to:
  /// **'Follow app language'**
  String get ttsLanguageFollowApp;

  /// No description provided for @ttsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get ttsLanguageEnglish;

  /// No description provided for @ttsLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get ttsLanguageRussian;

  /// No description provided for @ttsLanguageArmenian.
  ///
  /// In en, this message translates to:
  /// **'Armenian'**
  String get ttsLanguageArmenian;

  /// No description provided for @ttsQualityDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get ttsQualityDefault;

  /// No description provided for @ttsQualityExpressive.
  ///
  /// In en, this message translates to:
  /// **'ProPlus Expressive'**
  String get ttsQualityExpressive;

  /// No description provided for @ttsQualityHighRes.
  ///
  /// In en, this message translates to:
  /// **'ProPlus High-Res'**
  String get ttsQualityHighRes;

  /// No description provided for @ttsQualityTurbo.
  ///
  /// In en, this message translates to:
  /// **'ProPlus Turbo'**
  String get ttsQualityTurbo;

  /// No description provided for @ttsQualityPro2.
  ///
  /// In en, this message translates to:
  /// **'Pro2'**
  String get ttsQualityPro2;

  /// No description provided for @ttsQualityPro1.
  ///
  /// In en, this message translates to:
  /// **'Pro1'**
  String get ttsQualityPro1;

  /// No description provided for @ttsNarrationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Narration is disabled in Settings.'**
  String get ttsNarrationDisabled;

  /// No description provided for @ttsErrorNarrationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Narration text is empty.'**
  String get ttsErrorNarrationEmpty;

  /// No description provided for @ttsErrorNoVoicesForLanguage.
  ///
  /// In en, this message translates to:
  /// **'No voices available for this language.'**
  String get ttsErrorNoVoicesForLanguage;

  /// No description provided for @ttsErrorSelectVoice.
  ///
  /// In en, this message translates to:
  /// **'Unable to select a narration voice.'**
  String get ttsErrorSelectVoice;

  /// No description provided for @ttsErrorNoAudioChunks.
  ///
  /// In en, this message translates to:
  /// **'No audio chunks were generated.'**
  String get ttsErrorNoAudioChunks;

  /// No description provided for @ttsErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network connection is unstable. Please try again.'**
  String get ttsErrorNetwork;

  /// No description provided for @ttsErrorStart.
  ///
  /// In en, this message translates to:
  /// **'Unable to start narration right now. Please try again.'**
  String get ttsErrorStart;

  /// No description provided for @sttRecordingTapToStop.
  ///
  /// In en, this message translates to:
  /// **'Recording... Tap to stop'**
  String get sttRecordingTapToStop;

  /// No description provided for @sttProcessingVoice.
  ///
  /// In en, this message translates to:
  /// **'Processing voice...'**
  String get sttProcessingVoice;

  /// No description provided for @sttTapMicToUseVoice.
  ///
  /// In en, this message translates to:
  /// **'Tap mic to use voice input'**
  String get sttTapMicToUseVoice;

  /// No description provided for @sttDetectedLanguage.
  ///
  /// In en, this message translates to:
  /// **'Detected language: {language}'**
  String sttDetectedLanguage(String language);

  /// No description provided for @sttStartRecordingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get sttStartRecordingTooltip;

  /// No description provided for @sttStopRecordingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get sttStopRecordingTooltip;

  /// No description provided for @sttErrorPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required for voice input.'**
  String get sttErrorPermissionRequired;

  /// No description provided for @sttErrorUnableStartRecording.
  ///
  /// In en, this message translates to:
  /// **'Unable to start recording right now.'**
  String get sttErrorUnableStartRecording;

  /// No description provided for @sttErrorAudioNotCreated.
  ///
  /// In en, this message translates to:
  /// **'Recorded audio file was not created.'**
  String get sttErrorAudioNotCreated;

  /// No description provided for @sttErrorAudioNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recorded audio file was not found.'**
  String get sttErrorAudioNotFound;

  /// No description provided for @sttErrorProcessingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Transcription in progress. Please try a shorter sample.'**
  String get sttErrorProcessingInProgress;

  /// No description provided for @sttErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network connection is unstable. Please try again.'**
  String get sttErrorNetwork;

  /// No description provided for @sttErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Voice transcription failed. Please try again.'**
  String get sttErrorFailed;

  /// No description provided for @sttErrorKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'Speech service is not configured on backend.'**
  String get sttErrorKeyMissing;

  /// No description provided for @sttErrorProxyMissing.
  ///
  /// In en, this message translates to:
  /// **'Story Agent URL is missing. Use --dart-define=STORY_AGENT_URL=<backend_url>.'**
  String get sttErrorProxyMissing;

  /// No description provided for @sttErrorProxyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Story Agent URL is invalid.'**
  String get sttErrorProxyInvalid;

  /// No description provided for @storyRequestLogLangHeader.
  ///
  /// In en, this message translates to:
  /// **'Request language'**
  String get storyRequestLogLangHeader;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hy', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hy':
      return AppLocalizationsHy();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
