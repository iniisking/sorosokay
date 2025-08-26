import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _accumulatedText = '';

  Future<bool> initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) => debugPrint('Speech recognition error: $error'),
      );
      return _speechEnabled;
    } catch (e) {
      debugPrint('Failed to initialize speech: $e');
      return false;
    }
  }

  Future<void> startListening(Function(String) onResult) async {
    if (!_speechEnabled) {
      _speechEnabled = await initSpeech();
    }

    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          if (result.finalResult) {
            _accumulatedText += '${_lastWords.trim()} ';
            onResult(_accumulatedText.trim());
          } else {
            onResult('$_accumulatedText${_lastWords.trim()}');
          }
        },
        localeId: 'en_US',
        listenOptions: SpeechListenOptions(listenMode: ListenMode.dictation),
      );
    }
  }

  Future<void> pauseListening() async {
    await _speechToText.stop();
  }

  Future<void> resumeListening(Function(String) onResult) async {
    await startListening(onResult);
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    _accumulatedText = '';
  }

  bool get isListening => _speechToText.isListening;
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;
}
