import 'dart:typed_data';

class TtsResult {
  const TtsResult({
    required this.success,
    this.audioUri,
    this.audioBytes,
    this.usedCharacters,
    this.remainingCharacters,
    this.errorMessage,
  });

  final bool success;
  final Uri? audioUri;
  final Uint8List? audioBytes;
  final int? usedCharacters;
  final int? remainingCharacters;
  final String? errorMessage;

  bool get hasAudioBytes => audioBytes != null && audioBytes!.isNotEmpty;
  bool get hasAudioUri => audioUri != null;
}
