import 'package:shared_preferences/shared_preferences.dart';

import '../../tts/domain/tts_request.dart';
import '../domain/settings_model.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource(this._prefs);

  static const String keyReduceMotion = 'settings_reduce_motion';
  static const String keyLocale = 'settings_locale';
  static const String keyVoiceEnabled = 'settings_voice_enabled';
  static const String keyNarrationAutoplayEnabled =
      'settings_narration_autoplay_enabled';
  static const String keyMusicEnabled = 'settings_music_enabled';
  static const String keySoundEffectsEnabled = 'settings_sound_effects_enabled';
  static const String keyVoiceId = 'settings_voice_id';
  static const String keyVolume = 'settings_volume';
  static const String keySpeed = 'settings_speed';
  static const String keyIntensity = 'settings_intensity';
  static const String keyTtsLanguageMode = 'settings_tts_language_mode';
  static const String keyTtsPreferredGender = 'settings_tts_preferred_gender';
  static const String keyTtsQualityPreset = 'settings_tts_quality_preset';
  static const String keyVoiceInputLanguage = 'settings_stt_voice_language';
  static const String keySafeMode = 'settings_safe_mode';
  static const String keyDisableScaryContent = 'settings_disable_scary_content';
  static const String keyRequireParentConfirmationForOlder =
      'settings_require_parent_confirmation_for_older';

  static const String _legacyThemeModeKey = 'themeMode';
  static const String _legacyFontScaleKey = 'fontScale';
  static const String _legacyOnboardingCompletedKey = 'onboardingCompleted';

  final SharedPreferences _prefs;

  SettingsModel readModel() {
    return SettingsModel(
      reduceMotion:
          _prefs.getBool(keyReduceMotion) ??
          SettingsModel.defaults.reduceMotion,
      localeCode:
          _prefs.getString(keyLocale) ?? SettingsModel.defaults.localeCode,
      narrationEnabled:
          _prefs.getBool(keyVoiceEnabled) ??
          SettingsModel.defaults.narrationEnabled,
      narrationAutoplayEnabled:
          _prefs.getBool(keyNarrationAutoplayEnabled) ??
          SettingsModel.defaults.narrationAutoplayEnabled,
      musicEnabled:
          _prefs.getBool(keyMusicEnabled) ??
          SettingsModel.defaults.musicEnabled,
      soundEffectsEnabled:
          _prefs.getBool(keySoundEffectsEnabled) ??
          SettingsModel.defaults.soundEffectsEnabled,
      voiceInputLanguageCode: _normalizedVoiceInputLanguage(
        _prefs.getString(keyVoiceInputLanguage),
      ),
      ttsLanguageMode: _normalizedTtsLanguageMode(
        _prefs.getString(keyTtsLanguageMode),
      ),
      preferredGender: _normalizedPreferredGender(
        _prefs.getString(keyTtsPreferredGender),
      ),
      preferredVoiceId: _prefs.getString(keyVoiceId),
      ttsVolume:
          (_prefs.getDouble(keyVolume) ?? SettingsModel.defaults.ttsVolume)
              .clamp(0.0, 1.0),
      ttsSpeed: (_prefs.getDouble(keySpeed) ?? SettingsModel.defaults.ttsSpeed)
          .clamp(0.5, 1.5),
      ttsIntensity:
          (_prefs.getDouble(keyIntensity) ??
                  SettingsModel.defaults.ttsIntensity)
              .clamp(0.0, 1.5),
      ttsOutputQualityPreset: _normalizedQualityPreset(
        _prefs.getString(keyTtsQualityPreset),
      ),
      safeMode: _prefs.getBool(keySafeMode) ?? SettingsModel.defaults.safeMode,
      disableScaryContent:
          _prefs.getBool(keyDisableScaryContent) ??
          SettingsModel.defaults.disableScaryContent,
      requireParentConfirmationForOlder:
          _prefs.getBool(keyRequireParentConfirmationForOlder) ??
          SettingsModel.defaults.requireParentConfirmationForOlder,
    );
  }

  Future<void> writeReduceMotion(bool value) =>
      _prefs.setBool(keyReduceMotion, value);

  Future<void> writeLocaleCode(String value) =>
      _prefs.setString(keyLocale, value);

  Future<void> writeNarrationEnabled(bool value) =>
      _prefs.setBool(keyVoiceEnabled, value);

  Future<void> writeNarrationAutoplayEnabled(bool value) =>
      _prefs.setBool(keyNarrationAutoplayEnabled, value);

  Future<void> writeMusicEnabled(bool value) =>
      _prefs.setBool(keyMusicEnabled, value);

  Future<void> writeSoundEffectsEnabled(bool value) =>
      _prefs.setBool(keySoundEffectsEnabled, value);

  Future<void> writeVoiceInputLanguageCode(String value) => _prefs.setString(
    keyVoiceInputLanguage,
    _normalizedVoiceInputLanguage(value),
  );

  Future<void> writePreferredVoiceId(String? value) async {
    if (value == null || value.isEmpty) {
      await _prefs.remove(keyVoiceId);
      return;
    }
    await _prefs.setString(keyVoiceId, value);
  }

  Future<void> writeTtsVolume(double value) =>
      _prefs.setDouble(keyVolume, value.clamp(0.0, 1.0));

  Future<void> writeTtsSpeed(double value) =>
      _prefs.setDouble(keySpeed, value.clamp(0.5, 1.5));

  Future<void> writeTtsIntensity(double value) =>
      _prefs.setDouble(keyIntensity, value.clamp(0.0, 1.5));

  Future<void> writeTtsLanguageMode(String value) =>
      _prefs.setString(keyTtsLanguageMode, _normalizedTtsLanguageMode(value));

  Future<void> writePreferredGender(String value) => _prefs.setString(
    keyTtsPreferredGender,
    _normalizedPreferredGender(value),
  );

  Future<void> writeTtsOutputQualityPreset(String value) =>
      _prefs.setString(keyTtsQualityPreset, _normalizedQualityPreset(value));

  Future<void> writeSafeMode(bool value) => _prefs.setBool(keySafeMode, value);

  Future<void> writeDisableScaryContent(bool value) =>
      _prefs.setBool(keyDisableScaryContent, value);

  Future<void> writeRequireParentConfirmationForOlder(bool value) =>
      _prefs.setBool(keyRequireParentConfirmationForOlder, value);

  ThemeModePreference readThemeModePreference() {
    final raw =
        _prefs.getString(_legacyThemeModeKey) ??
        ThemeModePreference.system.name;
    return ThemeModePreference.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => ThemeModePreference.system,
    );
  }

  Future<void> writeThemeModePreference(ThemeModePreference mode) =>
      _prefs.setString(_legacyThemeModeKey, mode.name);

  FontScalePreference readFontScalePreference() {
    final raw =
        _prefs.getString(_legacyFontScaleKey) ??
        FontScalePreference.medium.name;
    return FontScalePreference.values.firstWhere(
      (item) => item.name == raw,
      orElse: () => FontScalePreference.medium,
    );
  }

  Future<void> writeFontScalePreference(FontScalePreference value) =>
      _prefs.setString(_legacyFontScaleKey, value.name);

  bool readOnboardingCompleted() =>
      _prefs.getBool(_legacyOnboardingCompletedKey) ?? false;

  Future<void> writeOnboardingCompleted(bool value) =>
      _prefs.setBool(_legacyOnboardingCompletedKey, value);

  static String _normalizedTtsLanguageMode(String? raw) {
    if (raw == null) {
      return SettingsModel.defaults.ttsLanguageMode;
    }
    return TtsLanguageMode.supported.contains(raw)
        ? raw
        : SettingsModel.defaults.ttsLanguageMode;
  }

  static String _normalizedPreferredGender(String? raw) {
    if (raw == null) {
      return SettingsModel.defaults.preferredGender;
    }
    return TtsGenderPreference.supported.contains(raw)
        ? raw
        : SettingsModel.defaults.preferredGender;
  }

  static String _normalizedQualityPreset(String? raw) {
    if (raw == null) {
      return SettingsModel.defaults.ttsOutputQualityPreset;
    }
    return TtsOutputQualityPreset.supported.contains(raw)
        ? raw
        : SettingsModel.defaults.ttsOutputQualityPreset;
  }

  static String _normalizedVoiceInputLanguage(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    switch (normalized) {
      case 'app':
      case 'hy':
      case 'ru':
      case 'en':
        return normalized!;
      default:
        return 'auto';
    }
  }
}

enum ThemeModePreference { system, light, dark }

enum FontScalePreference { small, medium, large }
