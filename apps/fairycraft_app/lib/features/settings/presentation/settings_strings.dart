import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';

class SettingsStrings {
  const SettingsStrings._({
    required this.settingsTitle,
    required this.generalAccessibilityHeader,
    required this.reduceMotionTitle,
    required this.reduceMotionSubtitle,
    required this.languageHeader,
    required this.languageTitle,
    required this.voiceInputHelpTitle,
    required this.voiceInputLanguageTitle,
    required this.voiceInputLanguageAuto,
    required this.voiceInputLanguageApp,
    required this.voiceInputLanguageEnglish,
    required this.voiceInputLanguageRussian,
    required this.voiceInputLanguageArmenian,
    required this.defaultNarrationVoiceTitle,
    required this.defaultNarrationVoiceComingSoon,
    required this.audioHeader,
    required this.voiceNarrationTitle,
    required this.defaultNarrationVoiceSystemTitle,
    required this.defaultNarrationVoiceSystemSubtitle,
    required this.volumeTitle,
    required this.speedTitle,
    required this.intensityTitle,
    required this.testVoiceButton,
    required this.chooseVoiceSheetTitle,
    required this.noVoicesAvailable,
    required this.loadingVoices,
    required this.languageScreenTitle,
    required this.languageEnglish,
    required this.languageRussian,
    required this.languageArmenian,
    required this.voiceHelpScreenTitle,
    required this.voiceHelpDescription,
    required this.voiceHelpPointOne,
    required this.voiceHelpPointTwo,
    required this.voiceHelpPointThree,
    required this.testVoicePhrase,
    required this.systemDefaultLabel,
    required this.ttsLanguageModeTitle,
    required this.ttsLanguageModeAuto,
    required this.ttsLanguageModeFollowApp,
    required this.ttsLanguageModeEnglish,
    required this.ttsLanguageModeRussian,
    required this.ttsLanguageModeArmenian,
    required this.voiceGenderTitle,
    required this.voiceGenderAny,
    required this.voiceGenderFemale,
    required this.voiceGenderMale,
    required this.voiceQualityTitle,
    required this.voiceQualityDefault,
    required this.voiceQualityExpressive,
    required this.voiceQualityHighRes,
    required this.voiceQualityTurbo,
    required this.voiceQualityPro2,
    required this.voiceQualityPro1,
    required this.sectionAppearance,
    required this.sectionLanguage,
    required this.sectionAudio,
    required this.sectionParentalControl,
    required this.sectionDebug,
    required this.toggleAutoplayNarration,
    required this.toggleMusic,
    required this.toggleSoundEffects,
    required this.toggleSafeMode,
    required this.toggleDisableScaryContent,
    required this.toggleRequireParentConfirmationForOlder,
    required this.debugFirebaseSanityCheckTitle,
    required this.debugFirebaseSanityCheckSubtitle,
  });

  final String settingsTitle;
  final String generalAccessibilityHeader;
  final String reduceMotionTitle;
  final String reduceMotionSubtitle;
  final String languageHeader;
  final String languageTitle;
  final String voiceInputHelpTitle;
  final String voiceInputLanguageTitle;
  final String voiceInputLanguageAuto;
  final String voiceInputLanguageApp;
  final String voiceInputLanguageEnglish;
  final String voiceInputLanguageRussian;
  final String voiceInputLanguageArmenian;
  final String defaultNarrationVoiceTitle;
  final String defaultNarrationVoiceComingSoon;
  final String audioHeader;
  final String voiceNarrationTitle;
  final String defaultNarrationVoiceSystemTitle;
  final String defaultNarrationVoiceSystemSubtitle;
  final String volumeTitle;
  final String speedTitle;
  final String intensityTitle;
  final String testVoiceButton;
  final String chooseVoiceSheetTitle;
  final String noVoicesAvailable;
  final String loadingVoices;
  final String languageScreenTitle;
  final String languageEnglish;
  final String languageRussian;
  final String languageArmenian;
  final String voiceHelpScreenTitle;
  final String voiceHelpDescription;
  final String voiceHelpPointOne;
  final String voiceHelpPointTwo;
  final String voiceHelpPointThree;
  final String testVoicePhrase;
  final String systemDefaultLabel;
  final String ttsLanguageModeTitle;
  final String ttsLanguageModeAuto;
  final String ttsLanguageModeFollowApp;
  final String ttsLanguageModeEnglish;
  final String ttsLanguageModeRussian;
  final String ttsLanguageModeArmenian;
  final String voiceGenderTitle;
  final String voiceGenderAny;
  final String voiceGenderFemale;
  final String voiceGenderMale;
  final String voiceQualityTitle;
  final String voiceQualityDefault;
  final String voiceQualityExpressive;
  final String voiceQualityHighRes;
  final String voiceQualityTurbo;
  final String voiceQualityPro2;
  final String voiceQualityPro1;
  final String sectionAppearance;
  final String sectionLanguage;
  final String sectionAudio;
  final String sectionParentalControl;
  final String sectionDebug;
  final String toggleAutoplayNarration;
  final String toggleMusic;
  final String toggleSoundEffects;
  final String toggleSafeMode;
  final String toggleDisableScaryContent;
  final String toggleRequireParentConfirmationForOlder;
  final String debugFirebaseSanityCheckTitle;
  final String debugFirebaseSanityCheckSubtitle;

  static SettingsStrings of(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsStrings._(
      settingsTitle: l10n.settingsTitle,
      generalAccessibilityHeader: l10n.settingsGeneralAccessibilityHeader,
      reduceMotionTitle: l10n.settingsReduceMotionTitle,
      reduceMotionSubtitle: l10n.settingsReduceMotionSubtitle,
      languageHeader: l10n.settingsLanguageHeader,
      languageTitle: l10n.settingsLanguageTitle,
      voiceInputHelpTitle: l10n.settingsVoiceInputHelpTitle,
      voiceInputLanguageTitle: l10n.settingsVoiceInputLanguageTitle,
      voiceInputLanguageAuto: l10n.settingsVoiceInputLanguageAuto,
      voiceInputLanguageApp: l10n.settingsVoiceInputLanguageApp,
      voiceInputLanguageEnglish: l10n.settingsVoiceInputLanguageEnglish,
      voiceInputLanguageRussian: l10n.settingsVoiceInputLanguageRussian,
      voiceInputLanguageArmenian: l10n.settingsVoiceInputLanguageArmenian,
      defaultNarrationVoiceTitle: l10n.settingsDefaultNarrationVoiceTitle,
      defaultNarrationVoiceComingSoon:
          l10n.settingsDefaultNarrationVoiceComingSoon,
      audioHeader: l10n.settingsAudioHeader,
      voiceNarrationTitle: l10n.settingsVoiceNarrationTitle,
      defaultNarrationVoiceSystemTitle:
          l10n.settingsDefaultNarrationVoiceSystemTitle,
      defaultNarrationVoiceSystemSubtitle:
          l10n.settingsDefaultNarrationVoiceSystemSubtitle,
      volumeTitle: l10n.settingsVolumeTitle,
      speedTitle: l10n.settingsSpeedTitle,
      intensityTitle: l10n.settingsIntensityTitle,
      testVoiceButton: l10n.settingsTestVoiceButton,
      chooseVoiceSheetTitle: l10n.settingsChooseVoiceSheetTitle,
      noVoicesAvailable: l10n.settingsNoVoicesAvailable,
      loadingVoices: l10n.settingsLoadingVoices,
      languageScreenTitle: l10n.settingsLanguageScreenTitle,
      languageEnglish: l10n.settingsLanguageEnglish,
      languageRussian: l10n.settingsLanguageRussian,
      languageArmenian: l10n.settingsLanguageArmenian,
      voiceHelpScreenTitle: l10n.settingsVoiceHelpScreenTitle,
      voiceHelpDescription: l10n.settingsVoiceHelpDescription,
      voiceHelpPointOne: l10n.settingsVoiceHelpPointOne,
      voiceHelpPointTwo: l10n.settingsVoiceHelpPointTwo,
      voiceHelpPointThree: l10n.settingsVoiceHelpPointThree,
      testVoicePhrase: l10n.settingsTestVoicePhrase,
      systemDefaultLabel: l10n.settingsSystemDefaultLabel,
      ttsLanguageModeTitle: l10n.settingsTtsLanguageModeTitle,
      ttsLanguageModeAuto: l10n.settingsTtsLanguageModeAuto,
      ttsLanguageModeFollowApp: l10n.settingsTtsLanguageModeFollowApp,
      ttsLanguageModeEnglish: l10n.settingsTtsLanguageModeEnglish,
      ttsLanguageModeRussian: l10n.settingsTtsLanguageModeRussian,
      ttsLanguageModeArmenian: l10n.settingsTtsLanguageModeArmenian,
      voiceGenderTitle: l10n.settingsVoiceGenderTitle,
      voiceGenderAny: l10n.settingsVoiceGenderAny,
      voiceGenderFemale: l10n.settingsVoiceGenderFemale,
      voiceGenderMale: l10n.settingsVoiceGenderMale,
      voiceQualityTitle: l10n.settingsVoiceQualityTitle,
      voiceQualityDefault: l10n.settingsVoiceQualityDefault,
      voiceQualityExpressive: l10n.settingsVoiceQualityExpressive,
      voiceQualityHighRes: l10n.settingsVoiceQualityHighRes,
      voiceQualityTurbo: l10n.settingsVoiceQualityTurbo,
      voiceQualityPro2: l10n.settingsVoiceQualityPro2,
      voiceQualityPro1: l10n.settingsVoiceQualityPro1,
      sectionAppearance: l10n.settingsSectionAppearance,
      sectionLanguage: l10n.settingsSectionLanguage,
      sectionAudio: l10n.settingsSectionAudio,
      sectionParentalControl: l10n.settingsSectionParentalControl,
      sectionDebug: l10n.settingsSectionDebug,
      toggleAutoplayNarration: l10n.settingsToggleAutoplayNarration,
      toggleMusic: l10n.settingsToggleMusic,
      toggleSoundEffects: l10n.settingsToggleSoundEffects,
      toggleSafeMode: l10n.settingsToggleSafeMode,
      toggleDisableScaryContent: l10n.settingsToggleDisableScaryContent,
      toggleRequireParentConfirmationForOlder:
          l10n.settingsToggleRequireParentConfirmationForOlder,
      debugFirebaseSanityCheckTitle: l10n.settingsDebugFirebaseSanityCheckTitle,
      debugFirebaseSanityCheckSubtitle:
          l10n.settingsDebugFirebaseSanityCheckSubtitle,
    );
  }
}
