// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FairyCraft';

  @override
  String get commonAccount => 'Account';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonPassword => 'Password';

  @override
  String get commonBackToLogin => 'Back to login';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonNotAvailable => 'Not available';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonLink => 'Link';

  @override
  String get commonUnlink => 'Unlink';

  @override
  String get commonStop => 'Stop';

  @override
  String get commonUpdate => 'Update';

  @override
  String get homeTagline => 'A calm place to create bedtime stories together.';

  @override
  String get homeCreateStoryTitle => 'Create Story';

  @override
  String get homeCreateStorySubtitle => 'Start a new adventure in one tap.';

  @override
  String get homeMyStoriesTitle => 'My Stories';

  @override
  String get homeMyStoriesSubtitle => 'Continue reading saved chapters.';

  @override
  String get homeStoryPreferences => 'Story Preferences';

  @override
  String get homeAccountTooltip => 'Account';

  @override
  String get homeSettingsTooltip => 'Settings';

  @override
  String get authLoginTitle => 'FairyCraft Login';

  @override
  String get authLoginButton => 'Login';

  @override
  String get authCreateAccountButton => 'Create account';

  @override
  String get authForgotPasswordButton => 'Forgot password';

  @override
  String authLoginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get authRegisterTitle => 'Create FairyCraft Account';

  @override
  String get authRegisterButton => 'Register';

  @override
  String authRegisterFailed(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get authResetPasswordTitle => 'Reset password';

  @override
  String get authSendResetEmailButton => 'Send reset email';

  @override
  String authResetEmailFailed(String error) {
    return 'Unable to send reset email: $error';
  }

  @override
  String get authResetSentTitle => 'Reset sent';

  @override
  String get authResetSentBody =>
      'If the email exists, reset instructions were sent.';

  @override
  String get authCheckingSession => 'Checking session...';

  @override
  String get authSessionSlow => 'Session check is taking longer than expected.';

  @override
  String get authChangePasswordTitle => 'Change password';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String get authPasswordUpdated => 'Password updated.';

  @override
  String authPasswordChangeFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get authProviderLinkTitle => 'Provider link';

  @override
  String get authLinkGoogleStub => 'Link Google (stub)';

  @override
  String get authLinkFacebookStub => 'Link Facebook (stub)';

  @override
  String authProviderLinkRequested(String provider) {
    return '$provider link request completed (stub for now).';
  }

  @override
  String authProviderLinkFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get accountTitle => 'Account';

  @override
  String get accountEmailLabel => 'Email';

  @override
  String get accountLinkedProviders => 'Linked providers';

  @override
  String get accountGoogle => 'Google';

  @override
  String get accountFacebook => 'Facebook';

  @override
  String get accountEmailPassword => 'Email & Password';

  @override
  String get accountLogout => 'Log out';

  @override
  String accountProviderUnlinked(String provider) {
    return '$provider was unlinked.';
  }

  @override
  String accountProviderLinkRequested(String provider) {
    return '$provider link requested.';
  }

  @override
  String get accountProviderUpdateFailed =>
      'Could not update provider. Please try again.';

  @override
  String get myStoriesTitle => 'My stories';

  @override
  String get myStoriesEmpty => 'No stories yet.';

  @override
  String myStoriesChaptersCount(int count) {
    return 'Chapters: $count';
  }

  @override
  String get onboardingWelcomeTitle => 'Welcome';

  @override
  String get onboardingHeroTitle => 'What is your hero called?';

  @override
  String get onboardingHeroDescription =>
      'The hero name appears across your stories and can be changed any time.';

  @override
  String get onboardingHeroNameLabel => 'Hero name';

  @override
  String get onboardingHeroNameHint => 'Luna, Aram, Mia...';

  @override
  String get onboardingAgeTitle => 'What age stories fit best?';

  @override
  String get onboardingAgeDescription =>
      'We use this to keep vocabulary and pacing comfortable.';

  @override
  String onboardingAgeYears(int age) {
    return '$age years';
  }

  @override
  String get onboardingFamilyTitle => 'Who is in your family?';

  @override
  String get onboardingFamilyDescription =>
      'Family mode helps include familiar characters in stories.';

  @override
  String get onboardingUseFamilyMode => 'Use family mode';

  @override
  String get onboardingIllustrationsTitle => 'Illustrations and creativity';

  @override
  String get onboardingIllustrationsDescription =>
      'Choose whether stories include images and how imaginative they feel.';

  @override
  String get onboardingAutoIllustrations => 'Auto-illustrations';

  @override
  String onboardingCreativityPercent(int percent) {
    return 'Creativity $percent%';
  }

  @override
  String get familyMom => 'Mom';

  @override
  String get familyDad => 'Dad';

  @override
  String get familySister => 'Sister';

  @override
  String get familyBrother => 'Brother';

  @override
  String get familyGrandma => 'Grandma';

  @override
  String get familyGrandpa => 'Grandpa';

  @override
  String get storyPreferencesTitle => 'Story Preferences';

  @override
  String get storyPreferencesCreativeControlTitle => 'Creative control center';

  @override
  String get storyPreferencesCreativeControlDescription =>
      'These preferences are saved automatically and used every time you create a story.';

  @override
  String get storyPreferencesCharacterSection => 'Character';

  @override
  String get storyPreferencesHeroNameLabel => 'Hero name';

  @override
  String get storyPreferencesHeroNameHint => 'Luna, Aram, Mila...';

  @override
  String get storyPreferencesAgeSection => 'Age';

  @override
  String storyPreferencesAgeYears(int age) {
    return '$age years';
  }

  @override
  String get storyPreferencesLengthSection => 'Length';

  @override
  String get storyPreferencesLengthShort => 'Short';

  @override
  String get storyPreferencesLengthMedium => 'Medium';

  @override
  String get storyPreferencesLengthLong => 'Long';

  @override
  String get storyPreferencesComplexitySection => 'Complexity';

  @override
  String get storyPreferencesComplexitySimple => 'Simple';

  @override
  String get storyPreferencesComplexityMedium => 'Medium';

  @override
  String get storyPreferencesComplexityComplex => 'Complex';

  @override
  String get storyPreferencesInteractivitySection => 'Interactivity';

  @override
  String get storyPreferencesInteractiveChoices => 'Use interactive choices';

  @override
  String get storyPreferencesFamilySection => 'Family';

  @override
  String get storyPreferencesIncludeFamilyMembers =>
      'Include family members in stories';

  @override
  String storyPreferencesFamilyMemberNameOptionalLabel(String member) {
    return '$member name (optional)';
  }

  @override
  String get storyPreferencesBrothersTitle => 'Brothers';

  @override
  String get storyPreferencesSistersTitle => 'Sisters';

  @override
  String get storyPreferencesNoBrothersAddedYet => 'No brothers added yet';

  @override
  String get storyPreferencesNoSistersAddedYet => 'No sisters added yet';

  @override
  String storyPreferencesBrotherNameOptionalLabel(int index) {
    return 'Brother $index name (optional)';
  }

  @override
  String storyPreferencesSisterNameOptionalLabel(int index) {
    return 'Sister $index name (optional)';
  }

  @override
  String get storyPreferencesAddBrotherButton => 'Add brother';

  @override
  String get storyPreferencesAddSisterButton => 'Add sister';

  @override
  String get storyPreferencesIllustrationsSection => 'Illustrations';

  @override
  String get storyPreferencesAddIllustrations =>
      'Add illustrations automatically';

  @override
  String get storyPreferencesCreativitySection => 'Creativity';

  @override
  String storyPreferencesCreativityPercent(int percent) {
    return '$percent%';
  }

  @override
  String get storyPreferencesResetButton => 'Reset Story Preferences';

  @override
  String get storySetupTitle => 'Create Story';

  @override
  String get storySetupPreferencesTooltip => 'Story Preferences';

  @override
  String get storySetupIdeaTitle => 'Tell us your story idea';

  @override
  String get storySetupIdeaHint => 'Type your idea or use voice...';

  @override
  String get storySetupFamilyMode => 'Family mode';

  @override
  String get storySetupFamilyModeSubtitle =>
      'Include family members in plot and characters.';

  @override
  String get storySetupHeroSection => 'Hero';

  @override
  String get storySetupLocationSection => 'Location';

  @override
  String get storySetupStyleSection => 'Style';

  @override
  String get storySetupGenerateButton => 'Generate';

  @override
  String get storySetupErrorNetwork =>
      'Could not reach the story service. Please check connection and try again.';

  @override
  String get storySetupErrorGeneric =>
      'Story creation was not completed. Please try again.';

  @override
  String get storyReaderNoStorySelected => 'No story selected.';

  @override
  String get storyReaderNoChapter => 'No chapter available yet.';

  @override
  String get storyReaderProgressTitle => 'Story progress';

  @override
  String get storyReaderComplete => 'Story complete';

  @override
  String storyReaderChapter(int index) {
    return 'Chapter $index';
  }

  @override
  String get storyReaderWhatNext => 'What happens next?';

  @override
  String get storyReaderTheEnd => 'The End';

  @override
  String get storyReaderCompleteDescription =>
      'This adventure is complete. You can start a new story anytime.';

  @override
  String get storyReaderIllustrations => 'Illustrations';

  @override
  String get storyReaderPromptHint => 'Describe the picture you want to see...';

  @override
  String get storyReaderGenerateImage => 'Generate image';

  @override
  String get storyReaderVoiceInput => 'Voice input';

  @override
  String get storyReaderUseRecognizedText => 'Use recognized text';

  @override
  String storyReaderLastPrompt(String prompt) {
    return 'Last prompt: $prompt';
  }

  @override
  String get storyReaderErrorNetwork =>
      'Connection is unstable. Please try again.';

  @override
  String get storyReaderErrorGeneric =>
      'Something went wrong. Please try again.';

  @override
  String get debugFirebaseTitle => 'Firebase debug';

  @override
  String debugFirebaseReady(String value) {
    return 'Firebase ready: $value';
  }

  @override
  String debugAppCheckAttempted(String value) {
    return 'AppCheck attempted: $value';
  }

  @override
  String debugBootstrapError(String value) {
    return 'Bootstrap error: $value';
  }

  @override
  String debugAuthService(String value) {
    return 'Auth service: $value';
  }

  @override
  String get voiceHelpTitle => 'Voice help';

  @override
  String get voiceHelpDescription =>
      'Use microphone to capture ideas for story setup or prompts.';

  @override
  String voiceHelpListening(String value) {
    return 'Listening: $value';
  }

  @override
  String voiceHelpLastText(String value) {
    return 'Last text: $value';
  }

  @override
  String get voiceHelpStartListening => 'Start listening';

  @override
  String get voiceHelpStop => 'Stop';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGeneralAccessibilityHeader => 'General / Accessibility';

  @override
  String get settingsReduceMotionTitle => 'Reduce motion';

  @override
  String get settingsReduceMotionSubtitle =>
      'Turn off to minimize transitions and movement effects.';

  @override
  String get settingsLanguageHeader => 'Language';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsVoiceInputHelpTitle => 'Voice input help';

  @override
  String get settingsVoiceInputLanguageTitle => 'Voice input language';

  @override
  String get settingsVoiceInputLanguageAuto => 'Auto';

  @override
  String get settingsVoiceInputLanguageApp => 'App language';

  @override
  String get settingsVoiceInputLanguageEnglish => 'English';

  @override
  String get settingsVoiceInputLanguageRussian => 'Russian';

  @override
  String get settingsVoiceInputLanguageArmenian => 'Armenian';

  @override
  String get settingsDefaultNarrationVoiceTitle => 'Default narration voice';

  @override
  String get settingsDefaultNarrationVoiceComingSoon => 'Coming soon';

  @override
  String get settingsAudioHeader => 'Audio';

  @override
  String get settingsVoiceNarrationTitle => 'Voice narration';

  @override
  String get settingsDefaultNarrationVoiceSystemTitle =>
      'Default narration voice';

  @override
  String get settingsDefaultNarrationVoiceSystemSubtitle =>
      'System default selector';

  @override
  String get settingsVolumeTitle => 'Volume';

  @override
  String get settingsSpeedTitle => 'Speed';

  @override
  String get settingsIntensityTitle => 'Intensity';

  @override
  String get settingsTestVoiceButton => 'Test voice';

  @override
  String get settingsChooseVoiceSheetTitle => 'Choose narration voice';

  @override
  String get settingsNoVoicesAvailable =>
      'No available voices for this language.';

  @override
  String get settingsLoadingVoices => 'Loading voices...';

  @override
  String get settingsLanguageScreenTitle => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageRussian => 'Russian';

  @override
  String get settingsLanguageArmenian => 'Armenian';

  @override
  String get settingsVoiceHelpScreenTitle => 'Voice input help';

  @override
  String get settingsVoiceHelpDescription =>
      'Use voice input to quickly capture ideas for stories.';

  @override
  String get settingsVoiceHelpPointOne =>
      'Speak clearly and keep the device near you.';

  @override
  String get settingsVoiceHelpPointTwo =>
      'Armenian, Russian, and English input are supported.';

  @override
  String get settingsVoiceHelpPointThree =>
      'You can edit recognized text before generating.';

  @override
  String get settingsTestVoicePhrase =>
      'Hello! This is how your narration voice sounds.';

  @override
  String get settingsSystemDefaultLabel => 'System default';

  @override
  String get settingsTtsLanguageModeTitle => 'Narration language';

  @override
  String get settingsTtsLanguageModeAuto => 'Auto detect';

  @override
  String get settingsTtsLanguageModeFollowApp => 'Follow app language';

  @override
  String get settingsTtsLanguageModeEnglish => 'English (US)';

  @override
  String get settingsTtsLanguageModeRussian => 'Russian';

  @override
  String get settingsTtsLanguageModeArmenian => 'Armenian';

  @override
  String get settingsVoiceGenderTitle => 'Preferred voice gender';

  @override
  String get settingsVoiceGenderAny => 'Any';

  @override
  String get settingsVoiceGenderFemale => 'Female';

  @override
  String get settingsVoiceGenderMale => 'Male';

  @override
  String get settingsVoiceQualityTitle => 'Voice quality preset';

  @override
  String get settingsVoiceQualityDefault => 'Default';

  @override
  String get settingsVoiceQualityExpressive => 'ProPlus Expressive';

  @override
  String get settingsVoiceQualityHighRes => 'ProPlus High-Res';

  @override
  String get settingsVoiceQualityTurbo => 'ProPlus Turbo';

  @override
  String get settingsVoiceQualityPro2 => 'Pro2';

  @override
  String get settingsVoiceQualityPro1 => 'Pro1';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsSectionAudio => 'Audio';

  @override
  String get settingsSectionParentalControl => 'Parental control';

  @override
  String get settingsSectionDebug => 'Debug';

  @override
  String get settingsToggleAutoplayNarration => 'Autoplay narration';

  @override
  String get settingsToggleMusic => 'Music';

  @override
  String get settingsToggleSoundEffects => 'Sound effects';

  @override
  String get settingsToggleSafeMode => 'Safe mode';

  @override
  String get settingsToggleDisableScaryContent => 'Disable scary content';

  @override
  String get settingsToggleRequireParentConfirmationForOlder =>
      'Require parent confirmation for older';

  @override
  String get settingsDebugFirebaseSanityCheckTitle => 'Firebase sanity check';

  @override
  String get settingsDebugFirebaseSanityCheckSubtitle =>
      'Inspect Firebase bootstrap, App Check and auth wiring.';

  @override
  String get ttsListenButton => 'Listen';

  @override
  String get ttsNarrationTitle => 'Narration';

  @override
  String get ttsVoiceGenderLabel => 'Voice gender';

  @override
  String get ttsVoiceLabel => 'Voice';

  @override
  String get ttsLanguageModeLabel => 'Language mode';

  @override
  String get ttsQualityPresetLabel => 'Quality';

  @override
  String get ttsVolumeLabel => 'Volume';

  @override
  String get ttsSpeedLabel => 'Speed';

  @override
  String get ttsIntensityLabel => 'Intensity';

  @override
  String get ttsPlayLabel => 'Play';

  @override
  String get ttsPauseLabel => 'Pause';

  @override
  String get ttsResumeLabel => 'Resume';

  @override
  String get ttsStopLabel => 'Stop';

  @override
  String get ttsPreparingAudioLabel => 'Preparing audio...';

  @override
  String ttsPreparingAudioChunks(int current, int total) {
    return 'Preparing audio... ($current/$total chunks)';
  }

  @override
  String get ttsPlayingLabel => 'Playing...';

  @override
  String get ttsPausedLabel => 'Paused';

  @override
  String get ttsCompletedLabel => 'Completed';

  @override
  String get ttsErrorNoVoices =>
      'No voices available for the selected filters.';

  @override
  String get ttsGenderAny => 'Any';

  @override
  String get ttsGenderFemale => 'Female';

  @override
  String get ttsGenderMale => 'Male';

  @override
  String get ttsLanguageAuto => 'Auto';

  @override
  String get ttsLanguageFollowApp => 'Follow app language';

  @override
  String get ttsLanguageEnglish => 'English (US)';

  @override
  String get ttsLanguageRussian => 'Russian';

  @override
  String get ttsLanguageArmenian => 'Armenian';

  @override
  String get ttsQualityDefault => 'Default';

  @override
  String get ttsQualityExpressive => 'ProPlus Expressive';

  @override
  String get ttsQualityHighRes => 'ProPlus High-Res';

  @override
  String get ttsQualityTurbo => 'ProPlus Turbo';

  @override
  String get ttsQualityPro2 => 'Pro2';

  @override
  String get ttsQualityPro1 => 'Pro1';

  @override
  String get ttsNarrationDisabled => 'Narration is disabled in Settings.';

  @override
  String get ttsErrorNarrationEmpty => 'Narration text is empty.';

  @override
  String get ttsErrorNoVoicesForLanguage =>
      'No voices available for this language.';

  @override
  String get ttsErrorSelectVoice => 'Unable to select a narration voice.';

  @override
  String get ttsErrorNoAudioChunks => 'No audio chunks were generated.';

  @override
  String get ttsErrorNetwork =>
      'Network connection is unstable. Please try again.';

  @override
  String get ttsErrorStart =>
      'Unable to start narration right now. Please try again.';

  @override
  String get sttRecordingTapToStop => 'Recording... Tap to stop';

  @override
  String get sttProcessingVoice => 'Processing voice...';

  @override
  String get sttTapMicToUseVoice => 'Tap mic to use voice input';

  @override
  String sttDetectedLanguage(String language) {
    return 'Detected language: $language';
  }

  @override
  String get sttStartRecordingTooltip => 'Start recording';

  @override
  String get sttStopRecordingTooltip => 'Stop recording';

  @override
  String get sttErrorPermissionRequired =>
      'Microphone permission is required for voice input.';

  @override
  String get sttErrorUnableStartRecording =>
      'Unable to start recording right now.';

  @override
  String get sttErrorAudioNotCreated => 'Recorded audio file was not created.';

  @override
  String get sttErrorAudioNotFound => 'Recorded audio file was not found.';

  @override
  String get sttErrorProcessingInProgress =>
      'Transcription in progress. Please try a shorter sample.';

  @override
  String get sttErrorNetwork =>
      'Network connection is unstable. Please try again.';

  @override
  String get sttErrorFailed => 'Voice transcription failed. Please try again.';

  @override
  String get sttErrorKeyMissing =>
      'Speech service is not configured on backend.';

  @override
  String get sttErrorProxyMissing =>
      'Story Agent URL is missing. Use --dart-define=STORY_AGENT_URL=<backend_url>.';

  @override
  String get sttErrorProxyInvalid => 'Story Agent URL is invalid.';

  @override
  String get storyRequestLogLangHeader => 'Request language';
}
