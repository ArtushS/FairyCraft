class TtsMode {
  const TtsMode._();

  static const String proxy = 'proxy';
  static const String direct = 'direct';
}

class TtsLanguageMode {
  const TtsLanguageMode._();

  static const String auto = 'auto';
  static const String followApp = 'app';
  static const String englishUs = 'en-US';
  static const String russianRu = 'ru-RU';
  static const String armenianAm = 'hy-AM';

  static const List<String> supported = <String>[
    auto,
    followApp,
    englishUs,
    russianRu,
    armenianAm,
  ];
}

class TtsGenderPreference {
  const TtsGenderPreference._();

  static const String any = 'any';
  static const String female = 'female';
  static const String male = 'male';

  static const List<String> supported = <String>[any, female, male];
}

class TtsOutputQualityPreset {
  const TtsOutputQualityPreset._();

  static const String expressive = 'expressive';
  static const String highres = 'highres';
  static const String turbo = 'turbo';
  static const String pro2 = 'pro2';
  static const String pro1 = 'pro1';
  static const String defaultPreset = 'default';

  static const List<String> supported = <String>[
    expressive,
    highres,
    turbo,
    pro2,
    pro1,
    defaultPreset,
  ];
}

class TtsRequest {
  const TtsRequest({
    required this.voiceId,
    required this.languageCode,
    required this.text,
    required this.outputFormat,
    required this.sampleRate,
    required this.speed,
    required this.intensity,
    required this.volume,
    required this.qualityPreset,
  });

  final String voiceId;
  final String languageCode;
  final String text;
  final String outputFormat;
  final String sampleRate;
  final double speed;
  final double intensity;
  final double volume;
  final String qualityPreset;

  TtsRequest copyWith({
    String? voiceId,
    String? languageCode,
    String? text,
    String? outputFormat,
    String? sampleRate,
    double? speed,
    double? intensity,
    double? volume,
    String? qualityPreset,
  }) {
    return TtsRequest(
      voiceId: voiceId ?? this.voiceId,
      languageCode: languageCode ?? this.languageCode,
      text: text ?? this.text,
      outputFormat: outputFormat ?? this.outputFormat,
      sampleRate: sampleRate ?? this.sampleRate,
      speed: speed ?? this.speed,
      intensity: intensity ?? this.intensity,
      volume: volume ?? this.volume,
      qualityPreset: qualityPreset ?? this.qualityPreset,
    );
  }

  String get masterSpeed {
    return ((speed - 1.0) * 10).round().clamp(-10, 10).toString();
  }

  String get masterPitch {
    return ((intensity - 1.0) * 10).round().clamp(-10, 10).toString();
  }

  Map<String, dynamic> toVoicemakerPayload() {
    return <String, dynamic>{
      'VoiceId': voiceId,
      'LanguageCode': languageCode,
      'Text': text,
      'OutputFormat': outputFormat,
      'SampleRate': sampleRate,
      'MasterVolume': '0',
      'MasterSpeed': masterSpeed,
      'MasterPitch': masterPitch,
    };
  }
}

String resolveNarrationLanguageCode({
  required String languageMode,
  required String text,
  String appLocaleCode = 'en',
}) {
  final normalizedMode = languageMode.trim();
  if (normalizedMode == TtsLanguageMode.followApp) {
    return _mapAppLocaleToTtsLanguageCode(appLocaleCode);
  }
  if (normalizedMode == TtsLanguageMode.englishUs ||
      normalizedMode == TtsLanguageMode.russianRu ||
      normalizedMode == TtsLanguageMode.armenianAm) {
    return normalizedMode;
  }
  final detected = detectLanguageCodeFromText(text);
  if (text.trim().isNotEmpty) {
    return detected;
  }
  return _mapAppLocaleToTtsLanguageCode(appLocaleCode);
}

String detectLanguageCodeFromText(String text) {
  if (text.isEmpty) {
    return TtsLanguageMode.englishUs;
  }

  final hasArmenian = RegExp(r'[\u0530-\u058F]').hasMatch(text);
  if (hasArmenian) {
    return TtsLanguageMode.armenianAm;
  }

  final hasCyrillic = RegExp(r'[\u0400-\u04FF]').hasMatch(text);
  if (hasCyrillic) {
    return TtsLanguageMode.russianRu;
  }

  return TtsLanguageMode.englishUs;
}

String _mapAppLocaleToTtsLanguageCode(String localeCode) {
  final normalized = localeCode.trim().toLowerCase();
  switch (normalized) {
    case 'hy':
      return TtsLanguageMode.armenianAm;
    case 'ru':
      return TtsLanguageMode.russianRu;
    default:
      return TtsLanguageMode.englishUs;
  }
}
