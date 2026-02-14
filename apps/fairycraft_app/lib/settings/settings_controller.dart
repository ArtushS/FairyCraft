import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FontScale {
  small,
  medium,
  large,
}

class SettingsController extends ChangeNotifier {
  SettingsController._(this._prefs);

  static const _themeModeKey = 'themeMode';
  static const _defaultLanguageCodeKey = 'defaultLanguageCode';
  static const _fontScaleKey = 'fontScale';
  static const _onboardingCompletedKey = 'onboardingCompleted';

  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  String _defaultLanguageCode = 'en';
  FontScale _fontScale = FontScale.medium;
  bool _onboardingCompleted = false;

  ThemeMode get themeMode => _themeMode;
  String get defaultLanguageCode => _defaultLanguageCode;
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
    final controller = SettingsController._(prefs);
    controller._themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == (prefs.getString(_themeModeKey) ?? ThemeMode.system.name),
      orElse: () => ThemeMode.system,
    );

    controller._defaultLanguageCode = prefs.getString(_defaultLanguageCodeKey) ?? 'en';
    controller._fontScale = FontScale.values.firstWhere(
      (mode) => mode.name == (prefs.getString(_fontScaleKey) ?? FontScale.medium.name),
      orElse: () => FontScale.medium,
    );
    controller._onboardingCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;

    return controller;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeModeKey, mode.name);
    notifyListeners();
  }

  Future<void> setDefaultLanguageCode(String code) async {
    _defaultLanguageCode = code;
    await _prefs.setString(_defaultLanguageCodeKey, code);
    notifyListeners();
  }

  Future<void> setFontScale(FontScale scale) async {
    _fontScale = scale;
    await _prefs.setString(_fontScaleKey, scale.name);
    notifyListeners();
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    _onboardingCompleted = completed;
    await _prefs.setBool(_onboardingCompletedKey, completed);
    notifyListeners();
  }
}
