import 'package:speech_to_text/speech_to_text.dart';
import '../utils/logger.dart';
import '../utils/text_formatter.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _accumulatedText = '';
  final _log = AppLogger.instance;
  int _soundLogTick = 0;

  Future<bool> initSpeech() async {
    try {
      _log.i('Speech init: starting');
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          _log.e(
            'Speech recognition error: ${error.errorMsg} (${error.permanent})',
          );
        },
        onStatus: (status) {
          _log.i('Speech status: $status');
        },
      );
      _log.i('Speech init complete: enabled=$_speechEnabled');
      return _speechEnabled;
    } catch (e) {
      _log.e('Failed to initialize speech: $e');
      return false;
    }
  }

  Future<void> startListening(
    Function(String) onResult, {
    bool resetDraft = true,
  }) async {
    _log.i(
      'Speech startListening called; enabled=$_speechEnabled resetDraft=$resetDraft',
    );
    if (!_speechEnabled) {
      _speechEnabled = await initSpeech();
    }

    if (_speechEnabled) {
      if (resetDraft) {
        _accumulatedText = '';
        _lastWords = '';
        _soundLogTick = 0;
      }
      await _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          _log.i(
            'Speech result: final=${result.finalResult}, words="${_lastWords.trim()}"',
          );
          if (result.finalResult) {
            final formatted = TextFormatter.formatFinalChunk(_lastWords);
            _accumulatedText += '$formatted ';
            _log.d('Formatted final chunk: "$formatted"');
            onResult(_accumulatedText.trim());
          } else {
            onResult('$_accumulatedText${_lastWords.trim()}');
          }
        },
        onSoundLevelChange: (level) {
          // Throttle logs to avoid overwhelming console output.
          _soundLogTick++;
          if (_soundLogTick % 8 == 0) {
            _log.d('Mic sound level: ${level.toStringAsFixed(2)}');
          }
        },
        localeId: 'en_US',
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          autoPunctuation: true,
          partialResults: true,
        ),
      );
      _log.i('Speech listen started: isListening=${_speechToText.isListening}');
    } else {
      _log.w('Speech not enabled; listen skipped');
    }
  }

  Future<void> pauseListening() async {
    _log.i('Speech pause requested');
    await _speechToText.stop();
    _log.i(
      'Speech paused/stopped for resume; isListening=${_speechToText.isListening}',
    );
  }

  Future<void> resumeListening(Function(String) onResult) async {
    _log.i('Speech resume requested');
    await startListening(onResult, resetDraft: false);
  }

  Future<void> stopListening() async {
    _log.i('Speech stop requested');
    await _speechToText.stop();
    _log.i('Speech stopped; isListening=${_speechToText.isListening}');
    _accumulatedText = '';
    _soundLogTick = 0;
  }

  bool get isListening => _speechToText.isListening;
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;
}
