import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../app/config.dart';
import '../auth/auth_service.dart';
import '../settings/settings_controller.dart';
import '../shared/network/request_context.dart';
import 'models.dart';

class StoryServiceException implements Exception {
  StoryServiceException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'StoryServiceException($code): $message';
}

class StoryService {
  StoryService({
    required AppConfig config,
    required AuthService authService,
    required SettingsController settingsController,
    required RequestContext requestContext,
    http.Client? client,
  })  : _config = config,
        _authService = authService,
        _settingsController = settingsController,
        _requestContext = requestContext,
        _client = client ?? http.Client();

  final AppConfig _config;
  final AuthService _authService;
  final SettingsController _settingsController;
  final RequestContext _requestContext;
  final http.Client _client;

  final Map<String, Future<StoryResponsePayload>> _inFlight = <String, Future<StoryResponsePayload>>{};
  final Map<String, DateTime> _cooldowns = <String, DateTime>{};

  Future<StoryRecord> generateStory({
    required String storyLang,
    String? ageGroup,
    String? storyLength,
    double? creativityLevel,
    String? hero,
    String? location,
    String? storyType,
    String? idea,
    bool imageEnabled = false,
  }) async {
    final payload = StoryRequestPayload(
      action: 'generate',
      storyLang: storyLang,
      ageGroup: ageGroup,
      storyLength: storyLength,
      creativityLevel: creativityLevel,
      hero: hero,
      location: location,
      storyType: storyType,
      idea: idea,
      imageEnabled: imageEnabled,
    );

    final response = await _send(payload);
    if (!response.ok || response.storyId == null || response.chapter == null) {
      throw StoryServiceException(
        response.error ?? 'generate_failed',
        response.safeMessage ?? 'Unable to generate story.',
      );
    }

    return StoryRecord(
      storyId: response.storyId!,
      storyLang: storyLang,
      title: response.title ?? 'FairyCraft Story',
      chapters: <StoryChapter>[response.chapter!],
      createdAt: DateTime.now(),
      lastImagePrompt: response.imagePrompt,
    );
  }

  Future<StoryRecord> continueStory({
    required StoryRecord story,
    required String choiceId,
  }) async {
    final payload = StoryRequestPayload(
      action: 'continue',
      storyLang: story.storyLang,
      storyId: story.storyId,
      choiceId: choiceId,
    );

    final response = await _send(payload);
    if (!response.ok || response.chapter == null) {
      throw StoryServiceException(
        response.error ?? 'continue_failed',
        response.safeMessage ?? 'Unable to continue story.',
      );
    }

    final updatedChapters = response.chapters ?? <StoryChapter>[...story.chapters, response.chapter!];

    return story.copyWith(chapters: updatedChapters, lastImagePrompt: response.imagePrompt);
  }

  Future<StoryResponsePayload> illustrateStory({
    required StoryRecord story,
    String? prompt,
  }) async {
    final payload = StoryRequestPayload(
      action: 'illustrate',
      storyLang: story.storyLang,
      storyId: story.storyId,
      prompt: prompt,
    );

    final response = await _send(payload);
    if (!response.ok) {
      throw StoryServiceException(
        response.error ?? 'illustrate_failed',
        response.safeMessage ?? 'Unable to illustrate story.',
      );
    }
    return response;
  }

  Future<StoryResponsePayload> _send(StoryRequestPayload payload) {
    _pruneCooldowns();
    final inFlightKey = '${payload.action}:${payload.storyId ?? 'new'}';
    final existing = _inFlight[inFlightKey];
    if (existing != null) {
      return existing;
    }

    final future = _sendWithRetry(payload).whenComplete(() {
      _inFlight.remove(inFlightKey);
    });

    _inFlight[inFlightKey] = future;
    return future;
  }

  Future<StoryResponsePayload> _sendWithRetry(StoryRequestPayload payload) async {
    if (_config.useMockStories) {
      return _mockResponse(payload);
    }

    StoryServiceException? lastException;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await _sendHttp(payload);
      } on StoryServiceException catch (error) {
        lastException = error;
        final isRateLimited = error.code == 'rate_limited';
        final isDailyLimited = error.code == 'daily_limit_reached';
        if (!isRateLimited || isDailyLimited || attempt == 2) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 250 * (attempt + 1)));
      }
    }

    throw lastException ?? StoryServiceException('request_failed', 'Unable to contact story agent.');
  }

  Future<StoryResponsePayload> _sendHttp(StoryRequestPayload payload) async {
    final requestId = _newRequestId();
    final body = payload.toJson(requestId);

    if (kDebugMode) {
      debugPrint(
        '[fairycraft:wire] action=${payload.action} requestId=$requestId '
        'storyId=${payload.storyId ?? '-'} lang=${_requestContext.localeCode}',
      );
    }

    final uri = _resolveActionUri(payload.action);
    final response = await _client.post(
      uri,
      headers: await _buildHeaders(),
      body: jsonEncode(body),
    );

    final serviceHeader = response.headers['x-fairycraft-service'];
    final revisionHeader = response.headers['x-fairycraft-rev'];
    final actionHeader = response.headers['x-fairycraft-action'];
    final kRevision = response.headers['x-k-revision'];

    if (kDebugMode) {
      debugPrint(
        '[fairycraft:wire] status=${response.statusCode} action=$actionHeader service=$serviceHeader rev=$revisionHeader krev=$kRevision',
      );
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw StoryServiceException('invalid_response', 'Story agent returned invalid JSON.');
    }

    final parsed = StoryResponsePayload.fromJson(data);

    if (response.statusCode == 429) {
      _cooldowns[payload.action] = DateTime.now();
      throw StoryServiceException(parsed.error ?? 'rate_limited', parsed.safeMessage ?? 'Too many requests.');
    }

    if (response.statusCode >= 400 || !parsed.ok) {
      throw StoryServiceException(parsed.error ?? 'request_failed', parsed.safeMessage ?? 'Request failed.');
    }

    return parsed;
  }

  Uri _resolveActionUri(String action) {
    final base = _config.storyAgentUrl.trim();
    final normalizedBase = base.endsWith('/') ? base : '$base/';
    final root = Uri.parse(normalizedBase);

    switch (action) {
      case 'generate':
        return root.resolve('v1/story/create');
      case 'continue':
        return root.resolve('v1/story/continue');
      case 'illustrate':
        return root.resolve('v1/story/illustrate');
      default:
        return root;
    }
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Firebase-Locale': _settingsController.defaultLanguageCode,
    };
    headers.addAll(_requestContext.headers());

    final token = await _authService.getIdToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final appCheckToken = await FirebaseAppCheck.instance.getToken(false);
      if (appCheckToken != null && appCheckToken.isNotEmpty) {
        headers['X-Firebase-AppCheck'] = appCheckToken;
      }
    } catch (_) {
      // App Check may be unavailable in local/mock mode.
    }

    return headers;
  }

  Future<StoryResponsePayload> _mockResponse(StoryRequestPayload payload) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final requestId = _newRequestId();

    if (payload.action == 'generate') {
      final hero = payload.hero?.trim().isNotEmpty == true ? payload.hero!.trim() : 'Luna';
      final location = payload.location?.trim().isNotEmpty == true ? payload.location!.trim() : 'Glow Forest';
      final title = 'FairyCraft: $hero in $location';
      final chapter = StoryChapter(
        index: 1,
        title: 'A Bright Start',
        text: '$hero begins a gentle adventure in $location, choosing kindness and curiosity at every turn.',
        choices: <StoryChoice>[
          StoryChoice(id: 'explore_path', label: 'Explore the sparkling path'),
          StoryChoice(id: 'meet_friend', label: 'Meet a new forest friend'),
        ],
      );

      return StoryResponsePayload(
        requestId: requestId,
        ok: true,
        storyId: _newStoryId(),
        title: title,
        chapter: chapter,
        imagePrompt: payload.imageEnabled ? 'Mock illustration prompt for $title' : null,
        imageDisabled: payload.imageEnabled,
      );
    }

    if (payload.action == 'continue') {
      final chapter = StoryChapter(
        index: 2,
        title: 'Next Step',
        text: 'The friends follow ${payload.choiceId ?? 'their choice'} and solve a puzzle together safely.',
        choices: <StoryChoice>[
          StoryChoice(id: 'share_map', label: 'Share a map'),
          StoryChoice(id: 'rest_and_plan', label: 'Rest and make a plan'),
        ],
      );

      return StoryResponsePayload(
        requestId: requestId,
        ok: true,
        storyId: payload.storyId,
        chapter: chapter,
      );
    }

    return StoryResponsePayload(
      requestId: requestId,
      ok: true,
      storyId: payload.storyId,
      imagePrompt: payload.prompt ?? 'Mock illustration placeholder',
      imageDisabled: true,
    );
  }

  void _pruneCooldowns() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _cooldowns.forEach((key, value) {
      if (now.difference(value) > const Duration(hours: 24)) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _cooldowns.remove(key);
    }
  }

  String _newRequestId() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    final randomPart = Random().nextInt(1 << 20).toRadixString(16);
    return 'req_${millis}_$randomPart';
  }

  String _newStoryId() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    final randomPart = Random().nextInt(1 << 20).toRadixString(16);
    return 'story_${millis}_$randomPart';
  }
}
