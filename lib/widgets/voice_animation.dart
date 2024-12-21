import 'package:flutter/material.dart';

class VoiceAnimation extends StatefulWidget {
  const VoiceAnimation({super.key});

  @override
  State<VoiceAnimation> createState() => _VoiceAnimationState();
}

class _VoiceAnimationState extends State<VoiceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Color> _colors = [
    Colors.blue.shade300,
    Colors.blue.shade400,
    Colors.blue.shade500,
    Colors.blue.shade600,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(4, (index) {
              return Container(
                width: 100 - (index * 20).toDouble(),
                height: 100 - (index * 20).toDouble(),
                decoration: BoxDecoration(
                  color: _colors[index].withOpacity(
                    (1 - (_controller.value + (index * 0.2)) % 1)
                        .clamp(0.2, 0.8),
                  ),
                  shape: BoxShape.circle,
                ),
              );
            }).reversed.toList(),
          ),
        );
      },
    );
  }
}
