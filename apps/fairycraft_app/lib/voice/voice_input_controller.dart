import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceInputController extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();

  bool _isListening = false;
  String _lastText = '';

  bool get isListening => _isListening;
  String get lastText => _lastText;

  Future<void> startListening() async {
    final available = await _speechToText.initialize();
    if (!available) {
      return;
    }

    _isListening = true;
    notifyListeners();

    await _speechToText.listen(
      onResult: (result) {
        _lastText = result.recognizedWords;
        notifyListeners();
      },
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }
}
