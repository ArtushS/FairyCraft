import 'dart:io';

import '../../../services/stt_service.dart';
import '../domain/stt_language.dart';
import '../domain/stt_result.dart';

class VoicemakerSttException implements Exception {
  const VoicemakerSttException(this.message);

  final String message;

  @override
  String toString() => message;
}

class VoicemakerSttClient {
  VoicemakerSttClient({required SttService sttService})
    : _sttService = sttService;

  final SttService _sttService;

  Future<SttResult> transcribe({
    required File audioFile,
    required SttLanguage language,
  }) async {
    final languageCandidates = language.apiLanguageCandidates;
    Object? lastError;

    for (var i = 0; i < languageCandidates.length; i++) {
      final languageCode = languageCandidates[i];
      try {
        final response = await _sttService.transcribe(
          audioFile,
          model: 'stt-flagship-v1',
          language: languageCode,
        );

        return SttResult(
          success: response.status.toLowerCase() != 'failed',
          text: response.generatedText,
          requestLanguageCode: languageCode,
          detectedLanguageCode: response.detectedLanguage,
          isProcessing: response.isProcessing,
          usedChars: response.usedChars,
          remainChars: response.remainChars,
          errorMessage: response.isProcessing
              ? 'Transcription is still processing. Please record a shorter sample.'
              : null,
        );
      } on SttServiceException catch (error) {
        lastError = error;
        if (i == languageCandidates.length - 1) {
          throw VoicemakerSttException(error.message);
        }
      } catch (error) {
        lastError = error;
        if (i == languageCandidates.length - 1) {
          throw const VoicemakerSttException(
            'Unable to transcribe recorded audio.',
          );
        }
      }
    }

    throw VoicemakerSttException(
      lastError is SttServiceException
          ? lastError.message
          : 'Unable to transcribe recorded audio.',
    );
  }
}
