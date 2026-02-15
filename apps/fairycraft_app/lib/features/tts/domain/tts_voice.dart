enum TtsVoiceGender { female, male, unknown }

class TtsVoice {
  const TtsVoice({
    required this.voiceId,
    required this.name,
    required this.gender,
    required this.engine,
    required this.language,
    required this.country,
    required this.languageName,
  });

  final String voiceId;
  final String name;
  final TtsVoiceGender gender;
  final String engine;
  final String language;
  final String country;
  final String languageName;

  String get displayName {
    if (languageName.isEmpty) {
      return name;
    }
    return '$name ($languageName)';
  }

  bool matchesGenderPreference(String preference) {
    final normalized = preference.trim().toLowerCase();
    if (normalized == 'any') {
      return true;
    }
    if (normalized == 'female') {
      return gender == TtsVoiceGender.female;
    }
    if (normalized == 'male') {
      return gender == TtsVoiceGender.male;
    }
    return true;
  }

  static TtsVoiceGender parseGender(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized.contains('female')) {
      return TtsVoiceGender.female;
    }
    if (normalized.contains('male')) {
      return TtsVoiceGender.male;
    }
    return TtsVoiceGender.unknown;
  }
}
