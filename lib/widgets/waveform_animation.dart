import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveformAnimation extends StatefulWidget {
  const WaveformAnimation({super.key});

  @override
  State<WaveformAnimation> createState() => _WaveformAnimationState();
}

class _WaveformAnimationState extends State<WaveformAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
        return CustomPaint(
          painter: WaveformPainter(
            animation: _controller,
            color: const Color.fromARGB(255, 0, 55, 255),
          ),
          child: Container(),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  WaveformPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    var x = 0.0;
    final points = List.generate(
      size.width.toInt(),
      (i) => math.sin((i * 0.15) + animation.value * 2 * math.pi) * 10,
    );

    path.moveTo(0, size.height / 2 + points[0]);
    for (final y in points) {
      path.lineTo(x, size.height / 2 + y);
      x += 1;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
