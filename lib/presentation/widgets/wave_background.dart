import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Decorative animated wave background used in profile header section.
class WaveBackground extends StatefulWidget {
  /// Creates animated wave background widget.
  const WaveBackground({super.key});

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _WavePainter(progress: _controller.value),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF98D8C8).withValues(alpha: 0.24)
      ..style = PaintingStyle.fill;
    final path = Path()..moveTo(0, size.height * 0.62);

    for (var x = 0.0; x <= size.width; x++) {
      final y = size.height * 0.62 +
          math.sin((x / size.width * math.pi * 2) + (progress * math.pi * 2)) *
              12;
      path.lineTo(x, y);
    }

    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
