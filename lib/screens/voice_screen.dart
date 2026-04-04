import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/speech_service.dart';
import '../utils/logger.dart';
import '../utils/text_formatter.dart';

class VoiceScreen extends StatefulWidget {
  final Function(String) onNoteCreated;

  const VoiceScreen({super.key, required this.onNoteCreated});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with TickerProviderStateMixin {
  static const _primaryColor = Color.fromARGB(255, 0, 55, 255);

  final SpeechService _speechService = SpeechService();
  final _log = AppLogger.instance;
  String _transcribedText = '';
  bool _isListening = false;
  bool _isPaused = false;
  bool _isTransitioning = false;

  late final AnimationController _rippleController;
  late final AnimationController _buttonScaleController;
  late final AnimationController _cursorController;
  late final AnimationController _listeningPulseController;
  late final Animation<double> _buttonScaleAnim;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeSpeech();

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _buttonScaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonScaleAnim =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 40),
          TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.0), weight: 60),
        ]).animate(
          CurvedAnimation(
            parent: _buttonScaleController,
            curve: Curves.easeInOut,
          ),
        );

    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 530),
      vsync: this,
    )..repeat(reverse: true);

    _listeningPulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _initializeSpeech() async {
    final enabled = await _speechService.initSpeech();
    _log.i('VoiceScreen init speech enabled=$enabled');
  }

  // --------------- speech lifecycle ---------------

  void _onMicPressed() async {
    if (_isTransitioning) return;
    _log.i('VoiceScreen mic button tapped');
    setState(() => _isTransitioning = true);

    _rippleController.forward(from: 0);
    _buttonScaleController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 650));
    _startListening();
    if (mounted) setState(() => _isTransitioning = false);
  }

  void _startListening() async {
    _log.i('VoiceScreen start listening');
    setState(() {
      _transcribedText = '';
      _isListening = true;
      _isPaused = false;
    });
    await _speechService.startListening((text) {
      _log.d('VoiceScreen transcript update length=${text.length}');
      setState(() {
        _transcribedText = text;
      });
      _scrollToBottom();
    });
    _log.i('VoiceScreen state: listening=$_isListening paused=$_isPaused');
  }

  void _pauseListening() async {
    _log.i('VoiceScreen pause listening');
    await _speechService.pauseListening();
    setState(() {
      _isPaused = true;
      _isListening = true;
    });
  }

  void _resumeListening() async {
    _log.i('VoiceScreen resume listening');
    setState(() {
      _isPaused = false;
      _isListening = true;
    });
    await _speechService.resumeListening((text) {
      _log.d('VoiceScreen transcript update length=${text.length}');
      setState(() {
        _transcribedText = text;
      });
      _scrollToBottom();
    });
  }

  void _stopListening() async {
    _log.i('VoiceScreen stop listening');
    await _speechService.stopListening();
    if (_transcribedText.isNotEmpty) {
      final polished = TextFormatter.polishFullText(_transcribedText);
      _log.i('VoiceScreen saving note with ${polished.length} chars');
      widget.onNoteCreated(polished);
    } else {
      _log.w('VoiceScreen stop pressed with empty transcript');
    }
    setState(() {
      _isListening = false;
      _isPaused = false;
      _transcribedText = '';
    });
    _rippleController.reset();
    _buttonScaleController.reset();
    Fluttertoast.showToast(
      msg: "Note saved successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  // --------------- helpers ---------------

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --------------- lifecycle ---------------

  @override
  void dispose() {
    _rippleController.dispose();
    _buttonScaleController.dispose();
    _cursorController.dispose();
    _listeningPulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --------------- build ---------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _isListening ? _buildListeningScreen() : _buildIdleScreen(),
      ),
    );
  }

  // ============== IDLE SCREEN ==============

  Widget _buildIdleScreen() {
    return Center(
      key: const ValueKey('idle'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tap to speak',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.2,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 48),
          _buildMicButton(),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    const double size = 110;

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 3 expanding ripple rings
          for (int i = 0; i < 3; i++)
            AnimatedBuilder(
              animation: _rippleController,
              builder: (_, __) {
                final delay = i * 0.18;
                final t = (_rippleController.value - delay).clamp(0.0, 1.0);
                final scale = 1.0 + t * 1.6;
                final opacity = (1.0 - t) * 0.55;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _primaryColor.withValues(alpha: opacity),
                        width: 2.5,
                      ),
                    ),
                  ),
                );
              },
            ),

          // Main button
          AnimatedBuilder(
            animation: _buttonScaleAnim,
            builder: (_, child) {
              return Transform.scale(
                scale: _isTransitioning ? _buttonScaleAnim.value : 1.0,
                child: child,
              );
            },
            child: GestureDetector(
              onTap: _onMicPressed,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withValues(alpha: 0.35),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============== LISTENING SCREEN ==============

  Widget _buildListeningScreen() {
    return SafeArea(
      key: const ValueKey('listening'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildListeningIndicator(),
            const SizedBox(height: 36),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: _buildTranscribedText(),
              ),
            ),
            _buildFloatingControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildListeningIndicator() {
    return AnimatedBuilder(
      animation: _listeningPulseController,
      builder: (_, __) {
        final alpha = 0.4 + _listeningPulseController.value * 0.6;
        final dotColor = _isPaused ? Colors.orange : Colors.red;
        return Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor.withValues(alpha: alpha),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _isPaused ? 'Paused' : 'Listening...',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.55),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTranscribedText() {
    final hasText = _transcribedText.isNotEmpty;
    final displayText = hasText ? _transcribedText : 'Start speaking';
    final textColor = hasText
        ? Theme.of(context).textTheme.bodyLarge?.color
        : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.2);

    return AnimatedBuilder(
      animation: _cursorController,
      builder: (_, __) {
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: displayText,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: hasText ? FontWeight.w400 : FontWeight.w300,
                  color: textColor,
                  height: 1.65,
                  letterSpacing: 0.15,
                ),
              ),
              TextSpan(
                text: '|',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w200,
                  color: _primaryColor.withValues(
                    alpha: _cursorController.value,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingControls() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pause / Resume
          GestureDetector(
            onTap: _isPaused ? _resumeListening : _pauseListening,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                size: 30,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 36),
          // Stop & Save
          GestureDetector(
            onTap: _stopListening,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.stop_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
