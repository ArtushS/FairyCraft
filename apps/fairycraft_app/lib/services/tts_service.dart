import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../app/config.dart';
import '../shared/network/request_context.dart';

class TtsServiceException implements Exception {
  const TtsServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TtsVoiceRecord {
  const TtsVoiceRecord({
    required this.voiceId,
    required this.voiceWebname,
    required this.language,
    required this.gender,
  });

  final String voiceId;
  final String voiceWebname;
  final String language;
  final String gender;

  factory TtsVoiceRecord.fromJson(Map<String, dynamic> json) {
    return TtsVoiceRecord(
      voiceId: _asString(json['VoiceId'], _asString(json['voiceId'])).trim(),
      voiceWebname:
          _asString(json['VoiceWebname'], _asString(json['voiceWebname']))
              .trim(),
      language: _asString(json['Language'], _asString(json['language'])).trim(),
      gender:
          _asString(json['Gender'], _asString(json['gender'], 'unknown')).trim(),
    );
  }
}

class TtsService {
  TtsService({
    required AppConfig config,
    required http.Client httpClient,
    required RequestContext requestContext,
  }) : _config = config,
       _httpClient = httpClient,
       _requestContext = requestContext;

  static const Duration _requestTimeout = Duration(seconds: 30);

  final AppConfig _config;
  final http.Client _httpClient;
  final RequestContext _requestContext;

  Future<Uint8List> generateTts({
    required String text,
    required String voiceId,
    required String languageCode,
    String effect = 'default',
    double speed = 0,
    double pitch = 0,
    double volume = 0,
  }) async {
    try {
      final uri = _buildHttpUri('/v1/tts');
      final response = await _httpClient
          .post(
            uri,
            headers: _requestContext.headers(
              extra: const <String, String>{'Content-Type': 'application/json'},
            ),
            body: jsonEncode(
              _buildPayload(
                text: text,
                voiceId: voiceId,
                languageCode: languageCode,
                effect: effect,
                speed: speed,
                pitch: pitch,
                volume: volume,
                returnBase64: false,
              ),
            ),
          )
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _extractHttpError(
          response,
          fallback:
              'Unable to generate narration audio right now. Please try again.',
        );
      }

      final contentType = (response.headers['content-type'] ?? '').toLowerCase();
      if (contentType.startsWith('audio/')) {
        return response.bodyBytes;
      }

      final decoded = _decodeJson(response.bodyBytes);
      final base64Audio = _asString(decoded['audioBase64']).trim();
      if (base64Audio.isEmpty) {
        throw const TtsServiceException('TTS returned no audio data.');
      }

      try {
        return base64Decode(base64Audio);
      } catch (_) {
        throw const TtsServiceException('TTS returned invalid audio data.');
      }
    } on TimeoutException {
      throw const TtsServiceException(
        'Unable to generate narration audio right now. Please try again.',
      );
    } on http.ClientException {
      throw const TtsServiceException(
        'Network connection is unstable. Please try again.',
      );
    }
  }

  Stream<Uint8List> streamTts({
    required String text,
    required String voiceId,
    required String languageCode,
    String effect = 'default',
    double speed = 0,
    double pitch = 0,
    double volume = 0,
  }) {
    final channel = WebSocketChannel.connect(_buildWsUri('/v1/tts/stream'));
    final controller = StreamController<Uint8List>();

    late final StreamSubscription<dynamic> subscription;
    var closed = false;

    Future<void> closeAll() async {
      if (closed) {
        return;
      }
      closed = true;
      await subscription.cancel();
      await channel.sink.close();
      await controller.close();
    }

    subscription = channel.stream.timeout(_requestTimeout).listen(
      (dynamic event) {
        final parsedBytes = _parseStreamChunk(event);
        if (parsedBytes != null && parsedBytes.isNotEmpty) {
          controller.add(parsedBytes);
          return;
        }

        final decoded = _tryDecodeMessage(event);
        if (decoded == null) {
          return;
        }

        final errorCode = _asString(decoded['error']).trim();
        if (errorCode.isNotEmpty) {
          final safeMessage = _asString(decoded['safeMessage']).trim();
          controller.addError(
            TtsServiceException(
              safeMessage.isEmpty ? 'Streaming TTS failed.' : safeMessage,
            ),
          );
          unawaited(closeAll());
          return;
        }

        final isFinal =
            decoded['done'] == true ||
            decoded['isFinal'] == true ||
            _asString(decoded['status']).trim().toLowerCase() == 'completed';
        if (isFinal) {
          unawaited(closeAll());
        }
      },
      onError: (Object error) {
        if (error is TimeoutException) {
          controller.addError(
            const TtsServiceException('Streaming TTS request timed out.'),
          );
        } else if (error is TtsServiceException) {
          controller.addError(error);
        } else {
          controller.addError(
            const TtsServiceException(
              'Unable to stream narration audio right now.',
            ),
          );
        }
        unawaited(closeAll());
      },
      onDone: () {
        unawaited(closeAll());
      },
    );

    channel.sink.add(
      jsonEncode(
        _buildPayload(
          text: text,
          voiceId: voiceId,
          languageCode: languageCode,
          effect: effect,
          speed: speed,
          pitch: pitch,
          volume: volume,
          returnBase64: false,
        ),
      ),
    );

    controller.onCancel = () async {
      await closeAll();
    };

    return controller.stream;
  }

  Future<List<TtsVoiceRecord>> listVoices({required String languageCode}) async {
    try {
      final uri = _buildHttpUri('/v1/tts/voices').replace(
        queryParameters: <String, String>{'language': languageCode},
      );

      final response = await _httpClient
          .get(uri, headers: _requestContext.headers())
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _extractHttpError(
          response,
          fallback: 'Unable to load voices right now. Please try again.',
        );
      }

      final decoded = _decodeJson(response.bodyBytes);
      final rawVoices = decoded['voices'];
      if (rawVoices is! List) {
        return const <TtsVoiceRecord>[];
      }

      return rawVoices
          .whereType<Map>()
          .map((raw) => raw.map(
                (key, value) => MapEntry(key.toString(), value),
              ))
          .map(TtsVoiceRecord.fromJson)
          .where((voice) => voice.voiceId.isNotEmpty)
          .toList(growable: false);
    } on TimeoutException {
      throw const TtsServiceException(
        'Unable to load voices right now. Please try again.',
      );
    } on http.ClientException {
      throw const TtsServiceException(
        'Network connection is unstable. Please try again.',
      );
    }
  }

  Uri _buildHttpUri(String path) {
    final raw = _config.storyAgentUrl.trim();
    if (raw.isEmpty) {
      throw const TtsServiceException(
        'Story Agent URL is missing. Use --dart-define=STORY_AGENT_URL=<backend_url>.',
      );
    }

    final base = Uri.tryParse(raw);
    if (base == null) {
      throw const TtsServiceException('Story Agent URL is invalid.');
    }

    return base.replace(path: _appendPath(base.path, path));
  }

  Uri _buildWsUri(String path) {
    final httpUri = _buildHttpUri(path);
    final nextScheme = httpUri.scheme == 'https' ? 'wss' : 'ws';
    return httpUri.replace(scheme: nextScheme);
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

  static Map<String, dynamic> _buildPayload({
    required String text,
    required String voiceId,
    required String languageCode,
    required String effect,
    required double speed,
    required double pitch,
    required double volume,
    required bool returnBase64,
  }) {
    return <String, dynamic>{
      'text': text,
      'voiceId': voiceId,
      'languageCode': languageCode,
      'effect': effect,
      'speed': speed,
      'pitch': pitch,
      'volume': volume,
      'returnBase64': returnBase64,
    };
  }

  static Map<String, dynamic> _decodeJson(Uint8List bytes) {
    if (bytes.isEmpty) {
      return <String, dynamic>{};
    }

    final text = utf8.decode(bytes, allowMalformed: true);
    final decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  static Map<String, dynamic>? _tryDecodeMessage(dynamic event) {
    if (event is! String) {
      return null;
    }

    try {
      final decoded = jsonDecode(event);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Uint8List? _parseStreamChunk(dynamic event) {
    if (event is Uint8List) {
      return event;
    }
    if (event is List<int>) {
      return Uint8List.fromList(event);
    }

    final decoded = _tryDecodeMessage(event);
    if (decoded == null) {
      return null;
    }

    final base64Audio = _asString(decoded['audioBase64']).trim();
    if (base64Audio.isEmpty) {
      return null;
    }

    try {
      return base64Decode(base64Audio);
    } catch (_) {
      return null;
    }
  }

  static TtsServiceException _extractHttpError(
    http.Response response, {
    required String fallback,
  }) {
    try {
      final decoded = _decodeJson(response.bodyBytes);
      final safeMessage = _asString(decoded['safeMessage']).trim();
      if (safeMessage.isNotEmpty) {
        return TtsServiceException(safeMessage);
      }
      final message = _asString(decoded['message'], _asString(decoded['error']))
          .trim();
      if (message.isNotEmpty) {
        return TtsServiceException(message);
      }
    } catch (_) {
      // Ignore decode failures and use fallback.
    }

    return TtsServiceException(fallback);
  }
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
