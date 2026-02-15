import 'dart:io';

import '../application/tts_cache.dart';
import '../domain/tts_request.dart';
import '../domain/tts_voice.dart';
import 'voicemaker_client.dart';

typedef ChunkProgressCallback = void Function(int current, int total);

class VoicemakerRepository {
  VoicemakerRepository({
    required VoicemakerClient client,
    required TtsCache cache,
  }) : _client = client,
       _cache = cache;

  final VoicemakerClient _client;
  final TtsCache _cache;

  Future<List<TtsVoice>> fetchVoices({
    required String languageCode,
    required String preferredGender,
    required String qualityPreset,
  }) async {
    try {
      final voices = await _client.listVoices(languageCode: languageCode);
      final byGender = _filterByGender(
        voices: voices,
        preferredGender: preferredGender,
      );
      return _filterByQuality(byGender, qualityPreset);
    } catch (_) {
      // If the TTS backend is misconfigured (missing proxy URL or API key),
      // don't crash the UI — return an empty list and let callers show a
      // friendly "no voices available" message.
      return const <TtsVoice>[];
    }
  }

  TtsVoice? pickDefaultVoice(List<TtsVoice> voices) {
    if (voices.isEmpty) {
      return null;
    }

    for (final matcher in <bool Function(TtsVoice)>[
      (voice) => _searchableVoiceText(voice).contains('ai3'),
      (voice) => _searchableVoiceText(voice).contains('ai2'),
      (voice) => _searchableVoiceText(voice).contains('neural'),
    ]) {
      for (final voice in voices) {
        if (matcher(voice)) {
          return voice;
        }
      }
    }

    return voices.first;
  }

  Future<List<File>> buildAudioChunkFiles({
    required TtsRequest request,
    required ChunkProgressCallback onPreparingChunk,
  }) async {
    final chunks = chunkText(request.text);
    final files = <File>[];

    for (var index = 0; index < chunks.length; index++) {
      final chunk = chunks[index];
      final requestWithChunk = request.copyWith(text: chunk);
      final cacheKey = _cache.buildChunkCacheKey(
        request: requestWithChunk,
        textChunk: chunk,
      );

      onPreparingChunk(index + 1, chunks.length);
      final cached = await _cache.getCachedFile(cacheKey);
      if (cached != null) {
        files.add(cached);
        continue;
      }

      final result = await _client.convert(requestWithChunk);
      final bytes =
          result.audioBytes ??
          (result.audioUri == null
              ? null
              : await _client.downloadAudio(result.audioUri!));
      if (bytes == null || bytes.isEmpty) {
        throw const VoicemakerException('Generated audio is empty.');
      }

      final savedFile = await _cache.writeBytes(key: cacheKey, bytes: bytes);
      files.add(savedFile);
    }

    return files;
  }

  List<String> chunkText(
    String text, {
    int targetSize = 2000,
    int maxSize = 2500,
  }) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return const <String>[];
    }

    final paragraphs = normalized
        .split(RegExp(r'\n\s*\n'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    final units = <String>[];
    for (final paragraph in paragraphs) {
      final splitSentences = _splitParagraphToUnits(
        paragraph: paragraph,
        maxSize: maxSize,
      );
      units.addAll(splitSentences);
    }

    if (units.isEmpty) {
      return <String>[normalized];
    }

    final chunks = <String>[];
    final buffer = StringBuffer();

    for (final unit in units) {
      final unitText = unit.trim();
      if (unitText.isEmpty) {
        continue;
      }

      final projectedLength = buffer.isEmpty
          ? unitText.length
          : buffer.length + 1 + unitText.length;

      if (projectedLength > maxSize && buffer.isNotEmpty) {
        chunks.add(buffer.toString().trim());
        buffer.clear();
      }

      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write(unitText);

      if (buffer.length >= targetSize) {
        chunks.add(buffer.toString().trim());
        buffer.clear();
      }
    }

    if (buffer.isNotEmpty) {
      chunks.add(buffer.toString().trim());
    }

    return chunks.where((chunk) => chunk.isNotEmpty).toList(growable: false);
  }

  List<TtsVoice> _filterByGender({
    required List<TtsVoice> voices,
    required String preferredGender,
  }) {
    if (preferredGender == TtsGenderPreference.any) {
      return voices;
    }
    final filtered = voices
        .where((voice) => voice.matchesGenderPreference(preferredGender))
        .toList(growable: false);
    if (filtered.isEmpty) {
      return voices;
    }
    return filtered;
  }

  List<TtsVoice> _filterByQuality(List<TtsVoice> voices, String preset) {
    if (preset == TtsOutputQualityPreset.defaultPreset) {
      return voices;
    }

    bool matchesPreset(TtsVoice voice) {
      final text = _searchableVoiceText(voice);
      switch (preset) {
        case TtsOutputQualityPreset.expressive:
          return text.contains('expressive') || text.contains('ai3');
        case TtsOutputQualityPreset.highres:
          return text.contains('high-res') ||
              text.contains('highres') ||
              text.contains('high res');
        case TtsOutputQualityPreset.turbo:
          return text.contains('turbo');
        case TtsOutputQualityPreset.pro2:
          return text.contains('pro2') || text.contains('ai2');
        case TtsOutputQualityPreset.pro1:
          return text.contains('pro1') || text.contains('ai1');
        default:
          return true;
      }
    }

    final filtered = voices.where(matchesPreset).toList(growable: false);
    if (filtered.isEmpty) {
      return voices;
    }
    return filtered;
  }

  List<String> _splitParagraphToUnits({
    required String paragraph,
    required int maxSize,
  }) {
    final sentences = paragraph
        .split(RegExp(r'(?<=[.!?։])\s+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (sentences.isEmpty) {
      return _splitLongTextByWords(paragraph, maxSize: maxSize);
    }

    final units = <String>[];
    for (final sentence in sentences) {
      if (sentence.length <= maxSize) {
        units.add(sentence);
        continue;
      }
      units.addAll(_splitLongTextByWords(sentence, maxSize: maxSize));
    }
    return units;
  }

  List<String> _splitLongTextByWords(String text, {required int maxSize}) {
    final words = text
        .split(RegExp(r'\s+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) {
      return const <String>[];
    }

    final units = <String>[];
    final buffer = StringBuffer();
    for (final word in words) {
      final projectedLength = buffer.isEmpty
          ? word.length
          : buffer.length + 1 + word.length;
      if (projectedLength > maxSize && buffer.isNotEmpty) {
        units.add(buffer.toString().trim());
        buffer.clear();
      }
      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write(word);
    }
    if (buffer.isNotEmpty) {
      units.add(buffer.toString().trim());
    }
    return units;
  }

  String _searchableVoiceText(TtsVoice voice) {
    return '${voice.voiceId} ${voice.name} ${voice.engine}'.toLowerCase();
  }
}
