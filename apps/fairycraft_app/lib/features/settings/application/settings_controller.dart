import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/settings_local_datasource.dart';
import '../domain/settings_model.dart';

enum FontScale { small, medium, large }

class SettingsController extends ChangeNotifier {
  SettingsController._({
    required SettingsLocalDataSource localDataSource,
    required SettingsModel settings,
    required ThemeMode themeMode,
    required FontScale fontScale,
    required bool onboardingCompleted,
  }) : _localDataSource = localDataSource,
       _settings = settings,
       _themeMode = themeMode,
       _fontScale = fontScale,
       _onboardingCompleted = onboardingCompleted;

  final SettingsLocalDataSource _localDataSource;

  SettingsModel _settings;
  ThemeMode _themeMode;
  FontScale _fontScale;
  bool _onboardingCompleted;

  SettingsModel get model => _settings;

  bool get reduceMotion => _settings.reduceMotion;
  String get localeCode => _settings.localeCode;
  String get defaultLanguageCode => _settings.localeCode;

  bool get narrationEnabled => _settings.narrationEnabled;
  bool get voiceNarrationEnabled => _settings.narrationEnabled;
  String get voiceInputLanguageCode => _settings.voiceInputLanguageCode;
  String get ttsLanguageMode => _settings.ttsLanguageMode;
  String get preferredGender => _settings.preferredGender;
  String? get preferredVoiceId => _settings.preferredVoiceId;
  String? get selectedVoiceId => _settings.preferredVoiceId;
  double get ttsVolume => _settings.ttsVolume;
  double get volume => _settings.ttsVolume;
  double get ttsSpeed => _settings.ttsSpeed;
  double get speed => _settings.ttsSpeed;
  double get ttsIntensity => _settings.ttsIntensity;
  double get intensity => _settings.ttsIntensity;
  String get ttsOutputQualityPreset => _settings.ttsOutputQualityPreset;

  ThemeMode get themeMode => _themeMode;
  FontScale get fontScale => _fontScale;
  bool get onboardingCompleted => _onboardingCompleted;

  double get textScaleFactor {
    switch (_fontScale) {
      case FontScale.small:
        return 0.9;
      case FontScale.medium:
        return 1.0;
      case FontScale.large:
        return 1.15;
    }
  }

  static Future<SettingsController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final localDataSource = SettingsLocalDataSource(prefs);
    final settings = localDataSource.readModel();
    return SettingsController._(
      localDataSource: localDataSource,
      settings: settings,
      themeMode: _mapThemeModePreferenceToThemeMode(
        localDataSource.readThemeModePreference(),
      ),
      fontScale: _mapFontScalePreferenceToFontScale(
        localDataSource.readFontScalePreference(),
      ),
      onboardingCompleted: localDataSource.readOnboardingCompleted(),
    );
  }

  Future<void> setReduceMotion(bool value) async {
    _settings = _settings.copyWith(reduceMotion: value);
    notifyListeners();
    await _localDataSource.writeReduceMotion(value);
  }

  Future<void> setLocaleCode(String value) async {
    _settings = _settings.copyWith(localeCode: value);
    notifyListeners();
    await _localDataSource.writeLocaleCode(value);
  }

  Future<void> setDefaultLanguageCode(String code) => setLocaleCode(code);

  Future<void> setNarrationEnabled(bool value) async {
    _settings = _settings.copyWith(narrationEnabled: value);
    notifyListeners();
    await _localDataSource.writeNarrationEnabled(value);
  }

  Future<void> setVoiceNarrationEnabled(bool value) =>
      setNarrationEnabled(value);

  Future<void> setVoiceInputLanguageCode(String value) async {
    _settings = _settings.copyWith(voiceInputLanguageCode: value);
    notifyListeners();
    await _localDataSource.writeVoiceInputLanguageCode(value);
  }

  Future<void> setTtsLanguageMode(String value) async {
    _settings = _settings.copyWith(ttsLanguageMode: value);
    notifyListeners();
    await _localDataSource.writeTtsLanguageMode(value);
  }

  Future<void> setPreferredGender(String value) async {
    _settings = _settings.copyWith(preferredGender: value);
    notifyListeners();
    await _localDataSource.writePreferredGender(value);
  }

  Future<void> setPreferredVoiceId(String? value) async {
    _settings = _settings.copyWith(
      preferredVoiceId: value,
      clearPreferredVoiceId: value == null || value.isEmpty,
    );
    notifyListeners();
    await _localDataSource.writePreferredVoiceId(value);
  }

  Future<void> setSelectedVoiceId(String? value) => setPreferredVoiceId(value);

  Future<void> setTtsVolume(double value, {bool persist = true}) async {
    final normalized = value.clamp(0.0, 1.0);
    _settings = _settings.copyWith(ttsVolume: normalized);
    notifyListeners();
    if (persist) {
      await _localDataSource.writeTtsVolume(normalized);
    }
  }

  Future<void> setVolume(double value, {bool persist = true}) =>
      setTtsVolume(value, persist: persist);

  Future<void> setTtsSpeed(double value, {bool persist = true}) async {
    final normalized = value.clamp(0.5, 1.5);
    _settings = _settings.copyWith(ttsSpeed: normalized);
    notifyListeners();
    if (persist) {
      await _localDataSource.writeTtsSpeed(normalized);
    }
  }

  Future<void> setSpeed(double value, {bool persist = true}) =>
      setTtsSpeed(value, persist: persist);

  Future<void> setTtsIntensity(double value, {bool persist = true}) async {
    final normalized = value.clamp(0.0, 1.5);
    _settings = _settings.copyWith(ttsIntensity: normalized);
    notifyListeners();
    if (persist) {
      await _localDataSource.writeTtsIntensity(normalized);
    }
  }

  Future<void> setIntensity(double value, {bool persist = true}) =>
      setTtsIntensity(value, persist: persist);

  Future<void> setTtsOutputQualityPreset(String value) async {
    _settings = _settings.copyWith(ttsOutputQualityPreset: value);
    notifyListeners();
    await _localDataSource.writeTtsOutputQualityPreset(value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _localDataSource.writeThemeModePreference(
      _mapThemeModeToThemeModePreference(mode),
    );
  }

  Future<void> setFontScale(FontScale scale) async {
    _fontScale = scale;
    notifyListeners();
    await _localDataSource.writeFontScalePreference(
      _mapFontScaleToFontScalePreference(scale),
    );
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    _onboardingCompleted = completed;
    notifyListeners();
    await _localDataSource.writeOnboardingCompleted(completed);
  }

  static ThemeMode _mapThemeModePreferenceToThemeMode(
    ThemeModePreference mode,
  ) {
    switch (mode) {
      case ThemeModePreference.light:
        return ThemeMode.light;
      case ThemeModePreference.dark:
        return ThemeMode.dark;
      case ThemeModePreference.system:
        return ThemeMode.system;
    }
  }

  static ThemeModePreference _mapThemeModeToThemeModePreference(
    ThemeMode mode,
  ) {
    switch (mode) {
      case ThemeMode.light:
        return ThemeModePreference.light;
      case ThemeMode.dark:
        return ThemeModePreference.dark;
      case ThemeMode.system:
        return ThemeModePreference.system;
    }
  }

  static FontScale _mapFontScalePreferenceToFontScale(
    FontScalePreference scale,
  ) {
    switch (scale) {
      case FontScalePreference.small:
        return FontScale.small;
      case FontScalePreference.medium:
        return FontScale.medium;
      case FontScalePreference.large:
        return FontScale.large;
    }
  }

  static FontScalePreference _mapFontScaleToFontScalePreference(
    FontScale scale,
  ) {
    switch (scale) {
      case FontScale.small:
        return FontScalePreference.small;
      case FontScale.medium:
        return FontScalePreference.medium;
      case FontScale.large:
        return FontScalePreference.large;
    }
  }
}
