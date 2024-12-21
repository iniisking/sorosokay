import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/voice_animation.dart';
import '../services/speech_service.dart';

class VoiceScreen extends StatefulWidget {
  final Function(String) onNoteCreated;

  const VoiceScreen({
    super.key,
    required this.onNoteCreated,
  });

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  final SpeechService _speechService = SpeechService();
  String _transcribedText = '';
  bool _isListening = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    await _speechService.initSpeech();
  }

  void _startListening() async {
    await _speechService.startListening((text) {
      setState(() {
        _transcribedText = text;
        _isListening = _speechService.isListening;
      });
    });
    setState(() {
      _isListening = true;
      _isPaused = false;
    });
  }

  void _pauseListening() async {
    await _speechService.pauseListening();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeListening() async {
    await _speechService.resumeListening((text) {
      setState(() {
        _transcribedText = text;
        _isListening = _speechService.isListening;
      });
    });
    setState(() {
      _isPaused = false;
    });
  }

  void _stopListening() async {
    await _speechService.stopListening();
    if (_transcribedText.isNotEmpty) {
      widget.onNoteCreated(_transcribedText);
    }
    setState(() {
      _isListening = false;
      _isPaused = false;
      _transcribedText = '';
    });
    Fluttertoast.showToast(
      msg: "Note saved successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Speak to me in English',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (_isListening)
                const SizedBox(
                  height: 100,
                  child: VoiceAnimation(),
                ),
              Text(
                _transcribedText.isEmpty
                    ? 'Your words will appear here...'
                    : _transcribedText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              if (!_isListening)
                ElevatedButton.icon(
                  onPressed: _startListening,
                  icon: const Icon(Icons.mic),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 55, 255),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isPaused ? _resumeListening : _pauseListening,
                      icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                      label: Text(_isPaused ? 'Resume' : 'Pause'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 55, 255),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _stopListening,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
