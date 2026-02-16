import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../app/config.dart';
import '../shared/network/request_context.dart';

class SttServiceException implements Exception {
  const SttServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SttTranscription {
  const SttTranscription({
    required this.generatedText,
    required this.status,
    this.taskId,
    this.detectedLanguage,
    this.usedChars,
    this.remainChars,
  });

  final String generatedText;
  final String status;
  final String? taskId;
  final String? detectedLanguage;
  final int? usedChars;
  final int? remainChars;

  bool get isProcessing => status.toLowerCase() == 'processing';
}

class SttService {
  SttService({
    required AppConfig config,
    required http.Client httpClient,
    required RequestContext requestContext,
    Future<String?> Function()? idTokenProvider,
  }) : _config = config,
       _httpClient = httpClient,
       _requestContext = requestContext,
       _idTokenProvider = idTokenProvider;

  static const Duration _requestTimeout = Duration(seconds: 30);

  final AppConfig _config;
  final http.Client _httpClient;
  final RequestContext _requestContext;
  final Future<String?> Function()? _idTokenProvider;

  Future<String> transcribeAudio(
    File file, {
    String model = 'stt-flagship-v1',
    String language = 'auto',
  }) async {
    final transcription = await transcribe(
      file,
      model: model,
      language: language,
    );
    return transcription.generatedText;
  }

  Future<SttTranscription> transcribe(
    File file, {
    String model = 'stt-flagship-v1',
    String language = 'auto',
  }) async {
    if (!await file.exists()) {
      throw const SttServiceException('Recorded audio file was not found.');
    }

    try {
      final uri = _buildUri('/v1/stt');
      final request = http.MultipartRequest('POST', uri)
        ..fields['model'] = model
        ..fields['language'] = language
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      request.headers.addAll(_requestContext.headers());

      if (_idTokenProvider != null) {
        try {
          final token = await _idTokenProvider();
          if (token != null && token.trim().isNotEmpty) {
            request.headers['Authorization'] = 'Bearer ${token.trim()}';
          }
        } catch (_) {
          // Continue without an auth header in local/dev mode.
        }
      }

      final streamResponse = await _httpClient
          .send(request)
          .timeout(_requestTimeout);
      final response = await http.Response
          .fromStream(streamResponse)
          .timeout(_requestTimeout);

      final decoded = _decodeJson(response.bodyBytes);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _extractHttpError(
          decoded,
          fallback:
              'Speech recognition proxy request failed. Please try again.',
        );
      }

      final generatedText = _asString(decoded['generatedText']).trim();
      final status = _asString(decoded['status']).trim();
      final normalizedStatus = status.isEmpty
          ? (decoded['ok'] == true ? 'completed' : 'failed')
          : status;

      return SttTranscription(
        generatedText: generatedText,
        status: normalizedStatus,
        taskId: _nullIfEmpty(_asString(decoded['taskId']).trim()),
        detectedLanguage: _nullIfEmpty(
          _asString(
            decoded['detectedLanguage'],
            _asString(decoded['language']),
          ).trim(),
        ),
        usedChars: _asInt(decoded['usedChars']),
        remainChars: _asInt(decoded['remainChars']),
      );
    } on TimeoutException {
      throw const SttServiceException(
        'Network connection is unstable. Please try again.',
      );
    } on http.ClientException {
      throw const SttServiceException(
        'Network connection is unstable. Please try again.',
      );
    }
  }

  Uri _buildUri(String path) {
    final raw = _config.storyAgentUrl.trim();
    if (raw.isEmpty) {
      throw const SttServiceException(
        'Story Agent URL is missing. Use --dart-define=STORY_AGENT_URL=<backend_url>.',
      );
    }

    final base = Uri.tryParse(raw);
    if (base == null) {
      throw const SttServiceException('Story Agent URL is invalid.');
    }

    return base.replace(path: _appendPath(base.path, path));
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

  static SttServiceException _extractHttpError(
    Map<String, dynamic> decoded, {
    required String fallback,
  }) {
    final safeMessage = _asString(decoded['safeMessage']).trim();
    if (safeMessage.isNotEmpty) {
      return SttServiceException(safeMessage);
    }

    final message = _asString(decoded['message'], _asString(decoded['error']))
        .trim();
    if (message.isNotEmpty) {
      return SttServiceException(message);
    }

    return SttServiceException(fallback);
  }
}

String? _nullIfEmpty(String value) {
  if (value.isEmpty) {
    return null;
  }
  return value;
}

String _asString(dynamic value, [String fallback = '']) {
  if (value is String) {
    return value;
  }
  if (value is num || value is bool) {
    return value.toString();
  }
  return fallback;
}

int? _asInt(dynamic value) {
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
