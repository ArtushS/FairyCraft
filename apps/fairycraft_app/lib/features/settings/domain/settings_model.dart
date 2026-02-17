import '../../tts/domain/tts_request.dart';

class SettingsModel {
  const SettingsModel({
    required this.reduceMotion,
    required this.localeCode,
    required this.narrationEnabled,
    required this.narrationAutoplayEnabled,
    required this.musicEnabled,
    required this.soundEffectsEnabled,
    required this.voiceInputLanguageCode,
    required this.ttsLanguageMode,
    required this.preferredGender,
    required this.preferredVoiceId,
    required this.ttsVolume,
    required this.ttsSpeed,
    required this.ttsIntensity,
    required this.ttsOutputQualityPreset,
    required this.safeMode,
    required this.disableScaryContent,
    required this.requireParentConfirmationForOlder,
  });

  static const SettingsModel defaults = SettingsModel(
    reduceMotion: true,
    localeCode: 'en',
    narrationEnabled: true,
    narrationAutoplayEnabled: true,
    musicEnabled: true,
    soundEffectsEnabled: true,
    voiceInputLanguageCode: 'app',
    ttsLanguageMode: TtsLanguageMode.followApp,
    preferredGender: TtsGenderPreference.any,
    preferredVoiceId: null,
    ttsVolume: 1.0,
    ttsSpeed: 0.6,
    ttsIntensity: 1.0,
    ttsOutputQualityPreset: TtsOutputQualityPreset.defaultPreset,
    safeMode: true,
    disableScaryContent: true,
    requireParentConfirmationForOlder: true,
  );

  final bool reduceMotion;
  final String localeCode;
  final bool narrationEnabled;
  final bool narrationAutoplayEnabled;
  final bool musicEnabled;
  final bool soundEffectsEnabled;
  final String voiceInputLanguageCode;
  final String ttsLanguageMode;
  final String preferredGender;
  final String? preferredVoiceId;
  final double ttsVolume;
  final double ttsSpeed;
  final double ttsIntensity;
  final String ttsOutputQualityPreset;
  final bool safeMode;
  final bool disableScaryContent;
  final bool requireParentConfirmationForOlder;

  SettingsModel copyWith({
    bool? reduceMotion,
    String? localeCode,
    bool? narrationEnabled,
    bool? narrationAutoplayEnabled,
    bool? musicEnabled,
    bool? soundEffectsEnabled,
    String? voiceInputLanguageCode,
    String? ttsLanguageMode,
    String? preferredGender,
    String? preferredVoiceId,
    bool clearPreferredVoiceId = false,
    double? ttsVolume,
    double? ttsSpeed,
    double? ttsIntensity,
    String? ttsOutputQualityPreset,
    bool? safeMode,
    bool? disableScaryContent,
    bool? requireParentConfirmationForOlder,
  }) {
    return SettingsModel(
      reduceMotion: reduceMotion ?? this.reduceMotion,
      localeCode: localeCode ?? this.localeCode,
      narrationEnabled: narrationEnabled ?? this.narrationEnabled,
      narrationAutoplayEnabled:
          narrationAutoplayEnabled ?? this.narrationAutoplayEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      voiceInputLanguageCode:
          voiceInputLanguageCode ?? this.voiceInputLanguageCode,
      ttsLanguageMode: ttsLanguageMode ?? this.ttsLanguageMode,
      preferredGender: preferredGender ?? this.preferredGender,
      preferredVoiceId: clearPreferredVoiceId
          ? null
          : (preferredVoiceId ?? this.preferredVoiceId),
      ttsVolume: ttsVolume ?? this.ttsVolume,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      ttsIntensity: ttsIntensity ?? this.ttsIntensity,
      ttsOutputQualityPreset:
          ttsOutputQualityPreset ?? this.ttsOutputQualityPreset,
      safeMode: safeMode ?? this.safeMode,
      disableScaryContent: disableScaryContent ?? this.disableScaryContent,
      requireParentConfirmationForOlder:
          requireParentConfirmationForOlder ??
          this.requireParentConfirmationForOlder,
    );
  }
}
