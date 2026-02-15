import 'package:flutter_tts/flutter_tts.dart';

class TtsVoiceOption {
  const TtsVoiceOption({
    required this.id,
    required this.name,
    required this.locale,
  });

  final String id;
  final String name;
  final String locale;

  String get displayLabel => '$name ($locale)';
}

class TtsService {
  TtsService() : _flutterTts = FlutterTts();

  final FlutterTts _flutterTts;
  final Map<String, TtsVoiceOption> _voicesById = <String, TtsVoiceOption>{};

  Future<void> speak(String text, {required String languageCode}) async {
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> setVolume(double value) async {
    await _flutterTts.setVolume(value.clamp(0.0, 1.0));
  }

  Future<void> setSpeechRate(double value) async {
    await _flutterTts.setSpeechRate(value.clamp(0.5, 1.5));
  }

  Future<void> setPitch(double value) async {
    await _flutterTts.setPitch(value.clamp(0.0, 1.5));
  }

  Future<List<TtsVoiceOption>> getAvailableVoices({String? localeCode}) async {
    final dynamic rawVoices = await _flutterTts.getVoices;
    final normalizedLocale = localeCode?.trim().toLowerCase();

    final List<TtsVoiceOption> options = <TtsVoiceOption>[];
    _voicesById.clear();

    if (rawVoices is List) {
      for (final raw in rawVoices) {
        if (raw is! Map) {
          continue;
        }
        final map = Map<String, dynamic>.from(raw);
        final name = (map['name'] as String?)?.trim() ?? '';
        final locale = (map['locale'] as String?)?.trim() ?? '';
        if (name.isEmpty || locale.isEmpty) {
          continue;
        }

        if (normalizedLocale != null && normalizedLocale.isNotEmpty) {
          final localeLower = locale.toLowerCase();
          if (!localeLower.startsWith(normalizedLocale)) {
            continue;
          }
        }

        final id = _voiceId(name: name, locale: locale);
        final option = TtsVoiceOption(id: id, name: name, locale: locale);
        _voicesById[id] = option;
        options.add(option);
      }
    }

    options.sort((a, b) => a.displayLabel.compareTo(b.displayLabel));
    return options;
  }

  Future<void> applyVoiceById(
    String? voiceId, {
    required String localeCode,
  }) async {
    if (voiceId == null || voiceId.isEmpty) {
      await _flutterTts.setLanguage(localeCode);
      return;
    }

    TtsVoiceOption? option = _voicesById[voiceId];
    option ??= _voiceFromId(voiceId);
    if (option == null) {
      await _flutterTts.setLanguage(localeCode);
      return;
    }

    await _flutterTts.setVoice(<String, String>{
      'name': option.name,
      'locale': option.locale,
    });
  }

  Future<void> configureNarration({
    required String localeCode,
    required String? selectedVoiceId,
    required double volume,
    required double speed,
    required double intensity,
  }) async {
    await setVolume(volume);
    await setSpeechRate(speed);
    await setPitch(intensity);
    await applyVoiceById(selectedVoiceId, localeCode: localeCode);
  }

  static String createVoiceId({
    required String name,
    required String locale,
  }) {
    return _voiceId(name: name, locale: locale);
  }

  static String _voiceId({
    required String name,
    required String locale,
  }) {
    return '$locale|$name';
  }

  TtsVoiceOption? _voiceFromId(String id) {
    final separatorIndex = id.indexOf('|');
    if (separatorIndex <= 0 || separatorIndex >= id.length - 1) {
      return null;
    }
    final locale = id.substring(0, separatorIndex);
    final name = id.substring(separatorIndex + 1);
    if (locale.isEmpty || name.isEmpty) {
      return null;
    }
    return TtsVoiceOption(id: id, name: name, locale: locale);
  }
}
