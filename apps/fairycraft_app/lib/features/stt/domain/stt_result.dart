class SttResult {
  const SttResult({
    required this.success,
    required this.text,
    required this.requestLanguageCode,
    this.detectedLanguageCode,
    this.isProcessing = false,
    this.usedChars,
    this.remainChars,
    this.errorMessage,
  });

  final bool success;
  final String text;
  final String requestLanguageCode;
  final String? detectedLanguageCode;
  final bool isProcessing;
  final int? usedChars;
  final int? remainChars;
  final String? errorMessage;
}
