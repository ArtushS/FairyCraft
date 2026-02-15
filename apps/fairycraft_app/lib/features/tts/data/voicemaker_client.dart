import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../app/config.dart';
import '../../../shared/network/request_context.dart';
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
    required AppConfig config,
    required http.Client httpClient,
    required RequestContext requestContext,
  })
    : _config = config,
      _httpClient = httpClient,
      _requestContext = requestContext;

  static final Uri _directConvertUri = Uri.parse(
    'https://developer.voicemaker.in/api/v1/voice/convert',
  );
  static final Uri _directListVoicesUri = Uri.parse(
    'https://developer.voicemaker.in/api/v1/voice/list',
  );

  final AppConfig _config;
  final http.Client _httpClient;
  final RequestContext _requestContext;

  Future<List<TtsVoice>> listVoices({required String languageCode}) async {
    if (kDebugMode) {
      debugPrint(
        '[tts:voices] mode=${_config.ttsMode} '
        'requestLang=$languageCode appLang=${_requestContext.localeCode}',
      );
    }
    final http.Response response;
    if (_config.ttsMode == TtsMode.direct) {
      final key = _validatedDirectApiKey();
      response = await _httpClient.post(
        _directListVoicesUri,
        headers: _requestContext.headers(
          extra: <String, String>{
            'Authorization': 'Bearer $key',
            'Content-Type': 'application/json',
          },
        ),
        body: jsonEncode(<String, dynamic>{'language': languageCode}),
      );
    } else {
      final uri = _proxyVoicesUri();
      response = await _httpClient.post(
        uri,
        headers: _requestContext.headers(
          extra: const <String, String>{'Content-Type': 'application/json'},
        ),
        body: jsonEncode(<String, dynamic>{
          'languageCode': languageCode,
          'language': languageCode,
        }),
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VoicemakerException(
        'Unable to load voices right now. Please try again.',
      );
    }

    final dynamic decoded = _decodeJson(response.bodyBytes);
    final List<Map<String, dynamic>> records = _extractVoiceRecords(decoded);
    final voices = records.map(_mapVoiceRecord).toList(growable: false)
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    return voices;
  }

  Future<TtsResult> convert(TtsRequest request) async {
    if (kDebugMode) {
      debugPrint(
        '[tts:convert] mode=${_config.ttsMode} '
        'requestLang=${request.languageCode} appLang=${_requestContext.localeCode}',
      );
    }
    final http.Response response;
    if (_config.ttsMode == TtsMode.direct) {
      final key = _validatedDirectApiKey();
      final headers = <String, String>{
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      };
      response = await _postConvertWithFallback(
        uri: _directConvertUri,
        headers: _requestContext.headers(extra: headers),
        payload: request.toVoicemakerPayload(),
      );
    } else {
      final uri = _proxyConvertUri();
      response = await _postConvertWithFallback(
        uri: uri,
        headers: _requestContext.headers(
          extra: const <String, String>{'Content-Type': 'application/json'},
        ),
        payload: <String, dynamic>{
          'voiceId': request.voiceId,
          'languageCode': request.languageCode,
          'language': request.languageCode,
          'text': request.text,
          'outputFormat': request.outputFormat,
          'sampleRate': request.sampleRate,
          'masterSpeed': request.masterSpeed,
          'masterPitch': request.masterPitch,
          'masterVolume': '0',
          'qualityPreset': request.qualityPreset,
        },
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VoicemakerException(
        'Unable to generate narration audio right now. Please try again.',
      );
    }

    final contentType = response.headers['content-type'] ?? '';
    if (contentType.startsWith('audio/')) {
      return TtsResult(success: true, audioBytes: response.bodyBytes);
    }

    final dynamic decoded = _decodeJson(response.bodyBytes);
    if (decoded is! Map<String, dynamic>) {
      throw const VoicemakerException(
        'Unexpected audio response from TTS service.',
      );
    }

    final success = decoded['success'] as bool? ?? true;
    if (!success) {
      throw VoicemakerException(
        (decoded['message'] as String?) ??
            (decoded['error'] as String?) ??
            'Narration generation failed.',
      );
    }

    final dynamic audioPathRaw = decoded['path'] ?? decoded['audioUrl'];
    final audioBytes = _extractAudioBytes(decoded);
    Uri? audioUri;
    if (audioPathRaw is String && audioPathRaw.trim().isNotEmpty) {
      audioUri = Uri.tryParse(audioPathRaw.trim());
    }

    if ((audioBytes == null || audioBytes.isEmpty) && audioUri == null) {
      throw const VoicemakerException('TTS returned no audio data.');
    }

    return TtsResult(
      success: true,
      audioUri: audioUri,
      audioBytes: audioBytes,
      usedCharacters: _asInt(decoded['usedChars']),
      remainingCharacters: _asInt(decoded['remainChars']),
    );
  }

  Future<Uint8List> downloadAudio(Uri uri) async {
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
  }

  Future<http.Response> _postConvertWithFallback({
    required Uri uri,
    required Map<String, String> headers,
    required Map<String, dynamic> payload,
  }) async {
    var response = await _httpClient.post(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    final canFallback =
        payload['masterSpeed']?.toString() != '0' ||
        payload['masterPitch']?.toString() != '0' ||
        payload['MasterSpeed']?.toString() != '0' ||
        payload['MasterPitch']?.toString() != '0';
    if (!canFallback) {
      return response;
    }

    final fallbackPayload = Map<String, dynamic>.from(payload)
      ..['masterSpeed'] = '0'
      ..['masterPitch'] = '0'
      ..['MasterSpeed'] = '0'
      ..['MasterPitch'] = '0';
    response = await _httpClient.post(
      uri,
      headers: headers,
      body: jsonEncode(fallbackPayload),
    );
    return response;
  }

  String _validatedDirectApiKey() {
    final key = _config.voicemakerApiKey.trim();
    if (key.isEmpty) {
      throw const VoicemakerException(
        'VOICEMAKER_API_KEY is missing. Start app with --dart-define=VOICEMAKER_API_KEY=<key>.',
      );
    }
    return key;
  }

  Uri _proxyConvertUri() {
    final base = _proxyBaseUri();
    if (base.path.endsWith('/v1/tts/voicemaker')) {
      return base;
    }
    return base.replace(path: _appendPath(base.path, '/v1/tts/voicemaker'));
  }

  Uri _proxyVoicesUri() {
    final convert = _proxyConvertUri();
    if (convert.path.endsWith('/voices')) {
      return convert;
    }
    return convert.replace(path: _appendPath(convert.path, '/voices'));
  }

  Uri _proxyBaseUri() {
    final raw = _config.ttsProxyUrl.trim();
    if (raw.isEmpty) {
      throw const VoicemakerException(
        'TTS proxy URL is missing. Set --dart-define=TTS_PROXY_URL=<backend_url>.',
      );
    }
    final uri = Uri.tryParse(raw);
    if (uri == null) {
      throw const VoicemakerException('TTS proxy URL is invalid.');
    }
    return uri;
  }

  static String _appendPath(String basePath, String segment) {
    final normalizedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    final normalizedSegment = segment.startsWith('/') ? segment : '/$segment';
    if (normalizedBase.isEmpty) {
      return normalizedSegment;
    }
    return '$normalizedBase$normalizedSegment';
  }

  static dynamic _decodeJson(Uint8List bytes) {
    final text = utf8.decode(bytes, allowMalformed: true);
    return jsonDecode(text);
  }

  static List<Map<String, dynamic>> _extractVoiceRecords(dynamic decoded) {
    if (decoded is List) {
      return decoded.whereType<Map>().map(_toStringMap).toList(growable: false);
    }
    if (decoded is! Map) {
      return const <Map<String, dynamic>>[];
    }

    final map = _toStringMap(decoded);
    for (final key in <String>['voices', 'data', 'result', 'items']) {
      final records = map[key];
      if (records is List) {
        return records
            .whereType<Map>()
            .map(_toStringMap)
            .toList(growable: false);
      }
    }
    return const <Map<String, dynamic>>[];
  }

  static TtsVoice _mapVoiceRecord(Map<String, dynamic> record) {
    final voiceId = _asString(
      record['VoiceId'],
      fallback: _asString(record['voiceId']),
    );
    final name = _asString(
      record['VoiceWebname'],
      fallback: _asString(record['voiceName'], fallback: voiceId),
    );
    final genderRaw = _asString(
      record['VoiceGender'],
      fallback: _asString(record['gender']),
    );
    final engine = _asString(
      record['Engine'],
      fallback: _asString(record['engine']),
    );
    final language = _asString(
      record['Language'],
      fallback: _asString(record['language']),
    );
    final country = _asString(
      record['Country'],
      fallback: _asString(record['country']),
    );
    final languageName = _asString(
      record['LanguageName'],
      fallback: _asString(record['languageName']),
    );
    return TtsVoice(
      voiceId: voiceId,
      name: name.isEmpty ? voiceId : name,
      gender: TtsVoice.parseGender(genderRaw),
      engine: engine,
      language: language,
      country: country,
      languageName: languageName,
    );
  }

  static Map<String, dynamic> _toStringMap(Map<dynamic, dynamic> source) {
    return source.map((key, value) => MapEntry(key.toString(), value));
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value is String) {
      return value;
    }
    return fallback;
  }

  static int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static Uint8List? _extractAudioBytes(Map<String, dynamic> decoded) {
    final encoded = decoded['audioBase64'] ?? decoded['audioBytes'];
    if (encoded is! String || encoded.isEmpty) {
      return null;
    }
    try {
      return base64Decode(encoded);
    } catch (_) {
      return null;
    }
  }
}
