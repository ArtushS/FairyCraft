import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../data/voicemaker_client.dart';
import '../data/voicemaker_repository.dart';
import '../domain/tts_request.dart';
import '../domain/tts_voice.dart';

class TtsController extends ChangeNotifier {
  TtsController({
    required VoicemakerRepository repository,
    AudioPlayer? audioPlayer,
  }) : _repository = repository,
       _audioPlayer = audioPlayer ?? AudioPlayer() {
    _wirePlayerStreams();
  }

  final VoicemakerRepository _repository;
  final AudioPlayer _audioPlayer;
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  List<TtsVoice> _cachedVoices = const <TtsVoice>[];
  String? _cachedLanguageCode;
  String? _cachedGender;
  String? _cachedQualityPreset;

  bool _isPreparing = false;
  int _preparingChunk = 0;
  int _totalChunks = 0;
  String _statusLabel = '';
  String? _lastError;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool get isPreparing => _isPreparing;
  bool get isPlaying => _audioPlayer.playing;
  bool get isPaused => !isPreparing && !isPlaying && _position > Duration.zero;
  String get statusLabel => _statusLabel;
  String? get lastError => _lastError;
  int get preparingChunk => _preparingChunk;
  int get totalChunks => _totalChunks;
  Duration get position => _position;
  Duration get duration => _duration;
  double get progress {
    if (_duration.inMilliseconds <= 0) {
      return 0;
    }
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
  }

  Future<List<TtsVoice>> fetchVoices({
    required String languageCode,
    required String preferredGender,
    required String qualityPreset,
    bool forceRefresh = false,
  }) async {
    final canUseCache =
        !forceRefresh &&
        _cachedLanguageCode == languageCode &&
        _cachedGender == preferredGender &&
        _cachedQualityPreset == qualityPreset &&
        _cachedVoices.isNotEmpty;
    if (canUseCache) {
      return _cachedVoices;
    }

    final voices = await _repository.fetchVoices(
      languageCode: languageCode,
      preferredGender: preferredGender,
      qualityPreset: qualityPreset,
    );

    _cachedLanguageCode = languageCode;
    _cachedGender = preferredGender;
    _cachedQualityPreset = qualityPreset;
    _cachedVoices = voices;
    return voices;
  }

  TtsVoice? pickDefaultVoice(List<TtsVoice> voices) {
    return _repository.pickDefaultVoice(voices);
  }

  String resolveLanguageCode({
    required String text,
    required String languageMode,
    String appLocaleCode = 'en',
  }) {
    return resolveNarrationLanguageCode(
      languageMode: languageMode,
      text: text,
      appLocaleCode: appLocaleCode,
    );
  }

  Future<void> playText({
    required String text,
    required String languageMode,
    String appLocaleCode = 'en',
    required String preferredGender,
    required String qualityPreset,
    required String? preferredVoiceId,
    required double speed,
    required double intensity,
    required double volume,
  }) async {
    final narrationText = text.trim();
    if (narrationText.isEmpty) {
      _setError('Narration text is empty.');
      return;
    }

    _setPreparingState();
    try {
      final languageCode = resolveLanguageCode(
        text: narrationText,
        languageMode: languageMode,
        appLocaleCode: appLocaleCode,
      );

      final voices = await fetchVoices(
        languageCode: languageCode,
        preferredGender: preferredGender,
        qualityPreset: qualityPreset,
      );
      if (voices.isEmpty) {
        throw const TtsControllerException(
          'No voices available for this language.',
        );
      }

      final selectedVoice = _resolveVoiceSelection(
        voices: voices,
        preferredVoiceId: preferredVoiceId,
      );
      if (selectedVoice == null) {
        throw const TtsControllerException(
          'Unable to select a narration voice.',
        );
      }

      final request = TtsRequest(
        voiceId: selectedVoice.voiceId,
        languageCode: languageCode,
        text: narrationText,
        outputFormat: 'mp3',
        sampleRate: '48000',
        speed: speed,
        intensity: intensity,
        volume: volume,
        qualityPreset: qualityPreset,
      );

      final files = await _repository.buildAudioChunkFiles(
        request: request,
        onPreparingChunk: (current, total) {
          _preparingChunk = current;
          _totalChunks = total;
          _statusLabel = 'Preparing audio... ($current/$total chunks)';
          notifyListeners();
        },
      );

      if (files.isEmpty) {
        throw const TtsControllerException('No audio chunks were generated.');
      }

      await _audioPlayer.stop();
      await _audioPlayer.setAudioSources(
        files
            .map((file) => AudioSource.file(file.path))
            .toList(growable: false),
        preload: true,
      );
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
      await _audioPlayer.play();

      _isPreparing = false;
      _statusLabel = 'Playing...';
      _lastError = null;
      notifyListeners();
    } on TtsControllerException catch (error) {
      _setError(error.message);
    } on VoicemakerException catch (error) {
      _setError(error.message);
    } on IOException {
      _setError('Network connection is unstable. Please try again.');
    } catch (_) {
      _setError('Unable to start narration right now. Please try again.');
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _statusLabel = 'Paused';
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
    _statusLabel = 'Playing...';
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _position = Duration.zero;
    _statusLabel = '';
    notifyListeners();
  }

  Future<void> setPlayerVolume(double value) async {
    await _audioPlayer.setVolume(value.clamp(0.0, 1.0));
  }

  void _wirePlayerStreams() {
    _subscriptions.add(
      _audioPlayer.positionStream.listen((position) {
        _position = position;
        notifyListeners();
      }),
    );
    _subscriptions.add(
      _audioPlayer.durationStream.listen((duration) {
        _duration = duration ?? Duration.zero;
        notifyListeners();
      }),
    );
    _subscriptions.add(
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _statusLabel = 'Completed';
          _position = _duration;
        } else if (state.playing && !_isPreparing) {
          _statusLabel = 'Playing...';
        }
        notifyListeners();
      }),
    );
  }

  TtsVoice? _resolveVoiceSelection({
    required List<TtsVoice> voices,
    required String? preferredVoiceId,
  }) {
    final trimmed = preferredVoiceId?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      for (final voice in voices) {
        if (voice.voiceId == trimmed) {
          return voice;
        }
      }
    }
    return pickDefaultVoice(voices);
  }

  void _setPreparingState() {
    _isPreparing = true;
    _preparingChunk = 0;
    _totalChunks = 0;
    _statusLabel = 'Preparing audio...';
    _lastError = null;
    notifyListeners();
  }

  void _setError(String message) {
    _isPreparing = false;
    _statusLabel = '';
    _lastError = message;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }
}

class TtsControllerException implements Exception {
  const TtsControllerException(this.message);

  final String message;
}
