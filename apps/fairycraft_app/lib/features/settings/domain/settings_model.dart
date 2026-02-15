import '../../tts/domain/tts_request.dart';

class SettingsModel {
  const SettingsModel({
    required this.reduceMotion,
    required this.localeCode,
    required this.narrationEnabled,
    required this.voiceInputLanguageCode,
    required this.ttsLanguageMode,
    required this.preferredGender,
    required this.preferredVoiceId,
    required this.ttsVolume,
    required this.ttsSpeed,
    required this.ttsIntensity,
    required this.ttsOutputQualityPreset,
  });

  static const SettingsModel defaults = SettingsModel(
    reduceMotion: true,
    localeCode: 'en',
    narrationEnabled: true,
    voiceInputLanguageCode: 'app',
    ttsLanguageMode: TtsLanguageMode.followApp,
    preferredGender: TtsGenderPreference.any,
    preferredVoiceId: null,
    ttsVolume: 1.0,
    ttsSpeed: 0.6,
    ttsIntensity: 1.0,
    ttsOutputQualityPreset: TtsOutputQualityPreset.defaultPreset,
  );

  final bool reduceMotion;
  final String localeCode;
  final bool narrationEnabled;
  final String voiceInputLanguageCode;
  final String ttsLanguageMode;
  final String preferredGender;
  final String? preferredVoiceId;
  final double ttsVolume;
  final double ttsSpeed;
  final double ttsIntensity;
  final String ttsOutputQualityPreset;

  SettingsModel copyWith({
    bool? reduceMotion,
    String? localeCode,
    bool? narrationEnabled,
    String? voiceInputLanguageCode,
    String? ttsLanguageMode,
    String? preferredGender,
    String? preferredVoiceId,
    bool clearPreferredVoiceId = false,
    double? ttsVolume,
    double? ttsSpeed,
    double? ttsIntensity,
    String? ttsOutputQualityPreset,
  }) {
    return SettingsModel(
      reduceMotion: reduceMotion ?? this.reduceMotion,
      localeCode: localeCode ?? this.localeCode,
      narrationEnabled: narrationEnabled ?? this.narrationEnabled,
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
    );
  }
}
