import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';

class TtsStrings {
  const TtsStrings._({
    required this.listenButton,
    required this.narrationTitle,
    required this.voiceGenderLabel,
    required this.voiceLabel,
    required this.languageModeLabel,
    required this.qualityPresetLabel,
    required this.volumeLabel,
    required this.speedLabel,
    required this.intensityLabel,
    required this.playLabel,
    required this.pauseLabel,
    required this.resumeLabel,
    required this.stopLabel,
    required this.preparingAudioLabel,
    required this.playingLabel,
    required this.pausedLabel,
    required this.completedLabel,
    required this.errorNoVoices,
    required this.genderAny,
    required this.genderFemale,
    required this.genderMale,
    required this.languageAuto,
    required this.languageFollowApp,
    required this.languageEnglish,
    required this.languageRussian,
    required this.languageArmenian,
    required this.qualityDefault,
    required this.qualityExpressive,
    required this.qualityHighRes,
    required this.qualityTurbo,
    required this.qualityPro2,
    required this.qualityPro1,
    required this.narrationDisabled,
  });

  final String listenButton;
  final String narrationTitle;
  final String voiceGenderLabel;
  final String voiceLabel;
  final String languageModeLabel;
  final String qualityPresetLabel;
  final String volumeLabel;
  final String speedLabel;
  final String intensityLabel;
  final String playLabel;
  final String pauseLabel;
  final String resumeLabel;
  final String stopLabel;
  final String preparingAudioLabel;
  final String playingLabel;
  final String pausedLabel;
  final String completedLabel;
  final String errorNoVoices;
  final String genderAny;
  final String genderFemale;
  final String genderMale;
  final String languageAuto;
  final String languageFollowApp;
  final String languageEnglish;
  final String languageRussian;
  final String languageArmenian;
  final String qualityDefault;
  final String qualityExpressive;
  final String qualityHighRes;
  final String qualityTurbo;
  final String qualityPro2;
  final String qualityPro1;
  final String narrationDisabled;

  static TtsStrings of(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TtsStrings._(
      listenButton: l10n.ttsListenButton,
      narrationTitle: l10n.ttsNarrationTitle,
      voiceGenderLabel: l10n.ttsVoiceGenderLabel,
      voiceLabel: l10n.ttsVoiceLabel,
      languageModeLabel: l10n.ttsLanguageModeLabel,
      qualityPresetLabel: l10n.ttsQualityPresetLabel,
      volumeLabel: l10n.ttsVolumeLabel,
      speedLabel: l10n.ttsSpeedLabel,
      intensityLabel: l10n.ttsIntensityLabel,
      playLabel: l10n.ttsPlayLabel,
      pauseLabel: l10n.ttsPauseLabel,
      resumeLabel: l10n.ttsResumeLabel,
      stopLabel: l10n.ttsStopLabel,
      preparingAudioLabel: l10n.ttsPreparingAudioLabel,
      playingLabel: l10n.ttsPlayingLabel,
      pausedLabel: l10n.ttsPausedLabel,
      completedLabel: l10n.ttsCompletedLabel,
      errorNoVoices: l10n.ttsErrorNoVoices,
      genderAny: l10n.ttsGenderAny,
      genderFemale: l10n.ttsGenderFemale,
      genderMale: l10n.ttsGenderMale,
      languageAuto: l10n.ttsLanguageAuto,
      languageFollowApp: l10n.ttsLanguageFollowApp,
      languageEnglish: l10n.ttsLanguageEnglish,
      languageRussian: l10n.ttsLanguageRussian,
      languageArmenian: l10n.ttsLanguageArmenian,
      qualityDefault: l10n.ttsQualityDefault,
      qualityExpressive: l10n.ttsQualityExpressive,
      qualityHighRes: l10n.ttsQualityHighRes,
      qualityTurbo: l10n.ttsQualityTurbo,
      qualityPro2: l10n.ttsQualityPro2,
      qualityPro1: l10n.ttsQualityPro1,
      narrationDisabled: l10n.ttsNarrationDisabled,
    );
  }
}
