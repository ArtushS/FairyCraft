import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../data/voicemaker_stt_client.dart';
import '../domain/stt_language.dart';
import '../domain/stt_result.dart';

enum SttUiState { idle, recording, processing }

class SttController extends ChangeNotifier {
  SttController({required VoicemakerSttClient client, AudioRecorder? recorder})
    : _client = client,
      _recorder = recorder ?? AudioRecorder();

  static const Duration maxRecordingDuration = Duration(seconds: 30);

  final VoicemakerSttClient _client;
  final AudioRecorder _recorder;

  SttUiState _state = SttUiState.idle;
  String? _errorMessage;
  String? _lastDetectedLanguage;
  String? _activeRecordingPath;
  SttLanguage _activeLanguage = SttLanguage.auto;
  DateTime? _recordingStartedAt;
  Timer? _autoStopTimer;

  SttUiState get state => _state;
  bool get isIdle => _state == SttUiState.idle;
  bool get isRecording => _state == SttUiState.recording;
  bool get isProcessing => _state == SttUiState.processing;
  String? get errorMessage => _errorMessage;
  String? get lastDetectedLanguage => _lastDetectedLanguage;
  Duration? get recordingElapsed {
    final started = _recordingStartedAt;
    if (started == null) {
      return null;
    }
    final elapsed = DateTime.now().difference(started);
    if (elapsed < Duration.zero) {
      return Duration.zero;
    }
    return elapsed;
  }

  Future<SttResult?> startRecording({
    SttLanguage language = SttLanguage.auto,
  }) async {
    if (!isIdle) {
      return null;
    }

    _setError(null);
    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      _setError('Microphone permission is required for voice input.');
      return null;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/stt_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          numChannels: 1,
          sampleRate: 16000,
          bitRate: 128000,
        ),
        path: outputPath,
      );

      _activeRecordingPath = outputPath;
      _activeLanguage = language;
      _recordingStartedAt = DateTime.now();
      _setState(SttUiState.recording);
      _autoStopTimer?.cancel();
      _autoStopTimer = Timer(maxRecordingDuration, () {
        if (isRecording) {
          unawaited(stopRecordingAndTranscribe(language: _activeLanguage));
        }
      });
      return null;
    } catch (_) {
      _setError('Unable to start recording right now.');
      _setState(SttUiState.idle);
      return null;
    }
  }

  Future<SttResult?> stopRecordingAndTranscribe({
    required SttLanguage language,
  }) async {
    if (!isRecording) {
      return null;
    }

    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    _setState(SttUiState.processing);

    File? audioFile;
    try {
      final path = await _recorder.stop();
      final resolvedPath = (path ?? _activeRecordingPath)?.trim();
      if (resolvedPath == null || resolvedPath.isEmpty) {
        throw const VoicemakerSttException(
          'Recorded audio file was not created.',
        );
      }

      audioFile = File(resolvedPath);
      if (!await audioFile.exists()) {
        throw const VoicemakerSttException(
          'Recorded audio file was not found.',
        );
      }

      final result = await _client.transcribe(
        audioFile: audioFile,
        language: language,
      );
      _lastDetectedLanguage = result.detectedLanguageCode;
      if (result.isProcessing) {
        _setError('Transcription in progress. Please try a shorter sample.');
      } else {
        _setError(null);
      }
      _setState(SttUiState.idle);
      _activeRecordingPath = null;
      _recordingStartedAt = null;
      return result;
    } on VoicemakerSttException catch (error) {
      _setError(error.message);
    } on SocketException {
      _setError('Network connection is unstable. Please try again.');
    } catch (_) {
      _setError('Voice transcription failed. Please try again.');
    } finally {
      _setState(SttUiState.idle);
      _activeRecordingPath = null;
      _recordingStartedAt = null;
      final fileToDelete = audioFile;
      if (fileToDelete != null) {
        unawaited(() async {
          try {
            await fileToDelete.delete();
          } catch (_) {}
        }());
      }
    }

    return null;
  }

  Future<void> cancelRecording() async {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    try {
      await _recorder.stop();
    } catch (_) {}
    _activeRecordingPath = null;
    _recordingStartedAt = null;
    _setState(SttUiState.idle);
  }

  void clearError() {
    _setError(null);
  }

  void _setState(SttUiState value) {
    _state = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    unawaited(_recorder.dispose());
    super.dispose();
  }
}
