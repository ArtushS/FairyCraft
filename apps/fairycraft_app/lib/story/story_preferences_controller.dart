import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StoryLengthPreference { short, medium, long }

enum StoryComplexityPreference { simple, medium, complex }

class StoryPreferencesController extends ChangeNotifier {
  StoryPreferencesController._(this._prefs);

  static const String memberMom = 'mom';
  static const String memberDad = 'dad';
  static const String memberSister = 'sister';
  static const String memberBrother = 'brother';
  static const String memberGrandma = 'grandma';
  static const String memberGrandpa = 'grandpa';

  static const List<String> familyMemberIds = <String>[
    memberMom,
    memberDad,
    memberSister,
    memberBrother,
    memberGrandma,
    memberGrandpa,
  ];

  static const String _heroNameKey = 'story_pref_hero_name';
  static const String _targetAgeKey = 'story_pref_target_age';
  static const String _lengthKey = 'story_pref_length';
  static const String _complexityKey = 'story_pref_complexity';
  static const String _interactiveKey = 'story_pref_interactive';
  static const String _familyModeKey = 'story_pref_family_mode';
  static const String _familyMembersKey = 'story_pref_family_members';
  static const String _illustrationsKey = 'story_pref_auto_illustrations';
  static const String _creativityKey = 'story_pref_creativity';

  final SharedPreferences _prefs;

  String _heroName = '';
  int _targetAge = 6;
  StoryLengthPreference _storyLength = StoryLengthPreference.medium;
  StoryComplexityPreference _storyComplexity = StoryComplexityPreference.medium;
  bool _interactiveChoices = true;
  bool _familyMode = true;
  List<String> _familyMembers = <String>[memberMom, memberDad];
  bool _autoIllustrations = true;
  double _creativity = 0.6;

  String get heroName => _heroName;
  int get targetAge => _targetAge;
  StoryLengthPreference get storyLength => _storyLength;
  StoryComplexityPreference get storyComplexity => _storyComplexity;
  bool get interactiveChoices => _interactiveChoices;
  bool get familyMode => _familyMode;
  List<String> get familyMembers => List<String>.unmodifiable(_familyMembers);
  bool get autoIllustrations => _autoIllustrations;
  double get creativity => _creativity;

  String get ageGroupCode {
    if (_targetAge <= 5) {
      return '3_5';
    }
    if (_targetAge <= 8) {
      return '6_8';
    }
    return '9_12';
  }

  String get storyLengthCode {
    switch (_storyLength) {
      case StoryLengthPreference.short:
        return 'short';
      case StoryLengthPreference.medium:
        return 'medium';
      case StoryLengthPreference.long:
        return 'long';
    }
  }

  String get complexityLabel {
    switch (_storyComplexity) {
      case StoryComplexityPreference.simple:
        return 'Simple';
      case StoryComplexityPreference.medium:
        return 'Medium';
      case StoryComplexityPreference.complex:
        return 'Complex';
    }
  }

  static Future<StoryPreferencesController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final controller = StoryPreferencesController._(prefs);
    controller._heroName = prefs.getString(_heroNameKey) ?? '';
    controller._targetAge = (prefs.getInt(_targetAgeKey) ?? 6).clamp(3, 12);
    controller._storyLength = StoryLengthPreference.values.firstWhere(
      (item) =>
          item.name ==
          (prefs.getString(_lengthKey) ?? StoryLengthPreference.medium.name),
      orElse: () => StoryLengthPreference.medium,
    );
    controller._storyComplexity = StoryComplexityPreference.values.firstWhere(
      (item) =>
          item.name ==
          (prefs.getString(_complexityKey) ??
              StoryComplexityPreference.medium.name),
      orElse: () => StoryComplexityPreference.medium,
    );
    controller._interactiveChoices = prefs.getBool(_interactiveKey) ?? true;
    controller._familyMode = prefs.getBool(_familyModeKey) ?? true;
    final storedFamilyMembers =
        prefs.getStringList(_familyMembersKey) ??
        <String>[memberMom, memberDad];
    controller._familyMembers = _normalizeFamilyMembers(storedFamilyMembers);
    controller._autoIllustrations = prefs.getBool(_illustrationsKey) ?? true;
    controller._creativity = (prefs.getDouble(_creativityKey) ?? 0.6).clamp(
      0.0,
      1.0,
    );
    return controller;
  }

  Future<void> setHeroName(String value) async {
    _heroName = value.trim();
    await _prefs.setString(_heroNameKey, _heroName);
    notifyListeners();
  }

  Future<void> setTargetAge(int value) async {
    _targetAge = value.clamp(3, 12);
    await _prefs.setInt(_targetAgeKey, _targetAge);
    notifyListeners();
  }

  Future<void> setStoryLength(StoryLengthPreference value) async {
    _storyLength = value;
    await _prefs.setString(_lengthKey, value.name);
    notifyListeners();
  }

  Future<void> setStoryComplexity(StoryComplexityPreference value) async {
    _storyComplexity = value;
    await _prefs.setString(_complexityKey, value.name);
    notifyListeners();
  }

  Future<void> setInteractiveChoices(bool value) async {
    _interactiveChoices = value;
    await _prefs.setBool(_interactiveKey, value);
    notifyListeners();
  }

  Future<void> setFamilyMode(bool value) async {
    _familyMode = value;
    await _prefs.setBool(_familyModeKey, value);
    notifyListeners();
  }

  Future<void> setFamilyMembers(List<String> value) async {
    _familyMembers = _normalizeFamilyMembers(value);
    await _prefs.setStringList(_familyMembersKey, _familyMembers);
    notifyListeners();
  }

  Future<void> setAutoIllustrations(bool value) async {
    _autoIllustrations = value;
    await _prefs.setBool(_illustrationsKey, value);
    notifyListeners();
  }

  Future<void> setCreativity(double value) async {
    _creativity = value.clamp(0.0, 1.0);
    await _prefs.setDouble(_creativityKey, _creativity);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _heroName = '';
    _targetAge = 6;
    _storyLength = StoryLengthPreference.medium;
    _storyComplexity = StoryComplexityPreference.medium;
    _interactiveChoices = true;
    _familyMode = true;
    _familyMembers = <String>[memberMom, memberDad];
    _autoIllustrations = true;
    _creativity = 0.6;

    await _prefs.setString(_heroNameKey, _heroName);
    await _prefs.setInt(_targetAgeKey, _targetAge);
    await _prefs.setString(_lengthKey, _storyLength.name);
    await _prefs.setString(_complexityKey, _storyComplexity.name);
    await _prefs.setBool(_interactiveKey, _interactiveChoices);
    await _prefs.setBool(_familyModeKey, _familyMode);
    await _prefs.setStringList(_familyMembersKey, _familyMembers);
    await _prefs.setBool(_illustrationsKey, _autoIllustrations);
    await _prefs.setDouble(_creativityKey, _creativity);
    notifyListeners();
  }

  static List<String> _normalizeFamilyMembers(List<String> rawValues) {
    final normalized = <String>{};
    for (final raw in rawValues) {
      final value = raw.trim().toLowerCase();
      switch (value) {
        case memberMom:
          normalized.add(memberMom);
          break;
        case memberDad:
          normalized.add(memberDad);
          break;
        case memberSister:
          normalized.add(memberSister);
          break;
        case memberBrother:
          normalized.add(memberBrother);
          break;
        case memberGrandma:
          normalized.add(memberGrandma);
          break;
        case memberGrandpa:
          normalized.add(memberGrandpa);
          break;
      }
    }

    if (normalized.isEmpty) {
      normalized.addAll(<String>[memberMom, memberDad]);
    }
    return normalized.toList(growable: false);
  }
}
