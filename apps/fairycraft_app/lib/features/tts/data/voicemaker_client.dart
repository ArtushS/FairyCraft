import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../shared/network/request_context.dart';
import '../../../services/tts_service.dart';
import '../domain/tts_request.dart';
import '../domain/tts_result.dart';
import '../domain/tts_voice.dart';

class VoicemakerException implements Exception {
  const VoicemakerException(this.message);

  final String message;

  @override
  String toString() => message;
}

class VoicemakerClient {
  VoicemakerClient({
    required TtsService ttsService,
    required http.Client httpClient,
    required RequestContext requestContext,
  }) : _ttsService = ttsService,
       _httpClient = httpClient,
       _requestContext = requestContext;

  final TtsService _ttsService;
  final http.Client _httpClient;
  final RequestContext _requestContext;

  Future<List<TtsVoice>> listVoices({required String languageCode}) async {
    try {
      final records = await _ttsService.listVoices(languageCode: languageCode);
      final voices = records
          .map(
            (voice) => TtsVoice(
              voiceId: voice.voiceId,
              name: voice.voiceWebname.isEmpty
                  ? voice.voiceId
                  : voice.voiceWebname,
              gender: TtsVoice.parseGender(voice.gender),
              engine: '',
              language: voice.language,
              country: '',
              languageName: '',
            ),
          )
          .toList(growable: false)
        ..sort((a, b) => a.displayName.compareTo(b.displayName));
      return voices;
    } on TtsServiceException catch (error) {
      throw VoicemakerException(error.message);
    }
  }

  Future<TtsResult> convert(TtsRequest request) async {
    try {
      final bytes = await _ttsService.generateTts(
        text: request.text,
        voiceId: request.voiceId,
        languageCode: request.languageCode,
        effect: request.qualityPreset,
        speed: double.tryParse(request.masterSpeed) ?? 0,
        pitch: double.tryParse(request.masterPitch) ?? 0,
        volume: double.tryParse(request.masterVolume) ?? 0,
      );
      return TtsResult(success: true, audioBytes: bytes);
    } on TtsServiceException catch (error) {
      throw VoicemakerException(error.message);
    }
  }

  Future<Uint8List> downloadAudio(Uri uri) async {
    try {
      final response = await _httpClient.get(
        uri,
        headers: _requestContext.headers(),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const VoicemakerException(
          'Failed to download generated narration audio.',
        );
      }
      return response.bodyBytes;
    } on IOException {
      throw const VoicemakerException('Network connection is unstable.');
    }
  }
}
