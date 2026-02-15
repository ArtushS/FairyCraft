import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../app/config.dart';
import '../../../shared/network/request_context.dart';
import '../domain/stt_language.dart';
import '../domain/stt_result.dart';

class VoicemakerSttException implements Exception {
  const VoicemakerSttException(this.message);

  final String message;

  @override
  String toString() => message;
}

class VoicemakerSttClient {
  VoicemakerSttClient({
    required AppConfig config,
    required http.Client httpClient,
    required RequestContext requestContext,
    Future<String?> Function()? idTokenProvider,
  }) : _config = config,
       _httpClient = httpClient,
       _requestContext = requestContext,
       _idTokenProvider = idTokenProvider;

  static final Uri _directSttUri = Uri.parse(
    'https://developer.voicemaker.in/api/v1/speech-to-text',
  );

  final AppConfig _config;
  final http.Client _httpClient;
  final RequestContext _requestContext;
  final Future<String?> Function()? _idTokenProvider;

  Future<SttResult> transcribe({
    required File audioFile,
    required SttLanguage language,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[stt:transcribe] mode=${_config.sttMode} '
        'requested=$language appLang=${_requestContext.localeCode}',
      );
    }
    final languageCandidates = language.apiLanguageCandidates;
    Object? lastError;

    for (var i = 0; i < languageCandidates.length; i++) {
      final languageCode = languageCandidates[i];
      try {
        final response = _config.sttMode == SttMode.direct
            ? await _sendDirect(
                audioFile: audioFile,
                languageCode: languageCode,
              )
            : await _sendProxy(
                audioFile: audioFile,
                languageCode: languageCode,
              );
        return _parseResponse(response, requestLanguageCode: languageCode);
      } on VoicemakerSttException catch (error) {
        lastError = error;
        final isLast = i == languageCandidates.length - 1;
        if (isLast) {
          rethrow;
        }
      } catch (error) {
        lastError = error;
        final isLast = i == languageCandidates.length - 1;
        if (isLast) {
          rethrow;
        }
      }
    }

    throw VoicemakerSttException(
      lastError is VoicemakerSttException
          ? lastError.message
          : 'Unable to transcribe recorded audio.',
    );
  }

  Future<Map<String, dynamic>> _sendDirect({
    required File audioFile,
    required String languageCode,
  }) async {
    final token = _config.voicemakerApiKey.trim();
    if (token.isEmpty) {
      throw const VoicemakerSttException(
        'VOICEMAKER_API_KEY is missing. Start with --dart-define=VOICEMAKER_API_KEY=<key>.',
      );
    }

    final request = http.MultipartRequest('POST', _directSttUri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['model'] = 'stt-flagship-v1'
      ..fields['language'] = languageCode
      ..fields['responseFormat'] = 'json'
      ..fields['includeSubtitle'] = 'false'
      ..fields['tagAudioEvents'] = 'false'
      ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));
    request.headers.addAll(_requestContext.headers());

    final streamResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamResponse);
    final decoded = _decodeJson(response.bodyBytes);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VoicemakerSttException(
        _extractErrorMessage(decoded) ??
            'Speech recognition request failed. Please try again.',
      );
    }

    return decoded;
  }

  Future<Map<String, dynamic>> _sendProxy({
    required File audioFile,
    required String languageCode,
  }) async {
    final baseUrl = _config.sttProxyUrl.trim();
    if (baseUrl.isEmpty) {
      throw const VoicemakerSttException(
        'STT proxy URL is missing. Use --dart-define=STT_PROXY_URL=<backend_url>.',
      );
    }

    final baseUri = Uri.tryParse(baseUrl);
    if (baseUri == null) {
      throw const VoicemakerSttException('STT proxy URL is invalid.');
    }

    final uri = baseUri.path.endsWith('/v1/stt/transcribe')
        ? baseUri
        : baseUri.replace(
            path: _appendPath(baseUri.path, '/v1/stt/transcribe'),
          );

    final request = http.MultipartRequest('POST', uri)
      ..fields['model'] = 'stt-flagship-v1'
      ..fields['language'] = languageCode
      ..fields['responseFormat'] = 'json'
      ..fields['includeSubtitle'] = 'false'
      ..fields['tagAudioEvents'] = 'false'
      ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));
    request.headers.addAll(_requestContext.headers());

    if (_idTokenProvider != null) {
      try {
        final token = await _idTokenProvider();
        if (token != null && token.trim().isNotEmpty) {
          request.headers['Authorization'] = 'Bearer ${token.trim()}';
        }
      } catch (_) {
        // Continue without auth header in development/local modes.
      }
    }

    final streamResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamResponse);
    final decoded = _decodeJson(response.bodyBytes);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VoicemakerSttException(
        _extractErrorMessage(decoded) ??
            'Speech recognition proxy request failed. Please try again.',
      );
    }

    return decoded;
  }

  SttResult _parseResponse(
    Map<String, dynamic> decoded, {
    required String requestLanguageCode,
  }) {
    final normalized = _normalizeResponse(decoded);
    final success = normalized['success'] as bool? ?? false;
    if (!success) {
      throw VoicemakerSttException(
        _extractErrorMessage(normalized) ??
            'Speech recognition failed. Please try again.',
      );
    }

    final isProcessing = normalized['isProcessing'] as bool? ?? false;
    final data = normalized['data'];
    Map<String, dynamic> parsedData;
    if (data is Map<String, dynamic>) {
      parsedData = data;
    } else if (data is Map) {
      parsedData = data.map((key, value) => MapEntry(key.toString(), value));
    } else {
      parsedData = <String, dynamic>{};
    }

    final generatedText =
        (parsedData['generatedText'] as String?)?.trim() ?? '';
    final detectedLanguageCode = (parsedData['language'] as String?)?.trim();
    return SttResult(
      success: success,
      text: generatedText,
      requestLanguageCode: requestLanguageCode,
      detectedLanguageCode: detectedLanguageCode,
      isProcessing: isProcessing,
      usedChars: _asInt(normalized['usedChars']),
      remainChars: _asInt(normalized['remainChars']),
      errorMessage: isProcessing
          ? 'Transcription is still processing. Please record a shorter sample.'
          : null,
    );
  }

  Map<String, dynamic> _normalizeResponse(Map<String, dynamic> decoded) {
    if (decoded.containsKey('success') || decoded.containsKey('data')) {
      return decoded;
    }

    if (decoded.containsKey('text')) {
      return <String, dynamic>{
        'success': true,
        'isProcessing': false,
        'data': <String, dynamic>{
          'generatedText': decoded['text'] as String? ?? '',
          'language': decoded['language'] as String?,
          'charge': decoded['charge'],
        },
        'usedChars': decoded['usedChars'],
        'remainChars': decoded['remainChars'],
      };
    }

    return decoded;
  }

  static Map<String, dynamic> _decodeJson(List<int> bodyBytes) {
    if (bodyBytes.isEmpty) {
      return <String, dynamic>{};
    }
    final text = utf8.decode(bodyBytes, allowMalformed: true);
    final decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
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

  static String? _extractErrorMessage(Map<String, dynamic> decoded) {
    final message = decoded['message'] as String?;
    if (message != null && message.trim().isNotEmpty) {
      return message.trim();
    }
    final error = decoded['error'] as String?;
    if (error != null && error.trim().isNotEmpty) {
      return error.trim();
    }
    final data = decoded['data'];
    if (data is Map) {
      final reason = data['reason'] as String?;
      if (reason != null && reason.trim().isNotEmpty) {
        return reason.trim();
      }
    }
    return null;
  }
}
