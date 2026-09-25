import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiquidBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;

  LiquidBackgroundPainter({
    required this.animation,
    this.colors = const [
    Color(0xffFF6B2C),
    Color(0xffFF8F5C),
    Color(0xffFFB88C),
  ],
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final time = animation.value * 2 * math.pi;

    final bgPaint = Paint()..color = const Color(0xffFFF5EE);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    _drawBlob(canvas, size, paint, time, 0, size.width * 0.7, size.height * 0.15, size.width * 0.55, colors[0].withValues(alpha: 0.18));
    _drawBlob(canvas, size, paint, time, 1, -size.width * 0.1, size.height * 0.55, size.width * 0.5, colors[1].withValues(alpha: 0.15));
    _drawBlob(canvas, size, paint, time, 2, size.width * 0.85, size.height * 0.7, size.width * 0.4, colors[0].withValues(alpha: 0.12));
    _drawBlob(canvas, size, paint, time, 3, size.width * 0.3, size.height * 0.85, size.width * 0.35, colors[2].withValues(alpha: 0.10));
    _drawBlob(canvas, size, paint, time, 4, size.width * 0.5, -size.height * 0.05, size.width * 0.3, colors[1].withValues(alpha: 0.08));
  }

  void _drawBlob(Canvas canvas, Size size, Paint paint, double time, int index, double baseX, double baseY, double radius, Color color) {
    final offset = index * 1.3;
    final dx = baseX + math.sin(time * 0.5 + offset) * radius * 0.3;
    final dy = baseY + math.cos(time * 0.4 + offset) * radius * 0.25;
    final r = radius + math.sin(time * 0.6 + offset) * radius * 0.15;

    final gradient = RadialGradient(
      colors: [color, color.withValues(alpha: 0.0)],
      stops: const [0.0, 1.0],
    );

    paint.shader = gradient.createShader(
      Rect.fromCircle(center: Offset(dx, dy), radius: r),
    );

    final path = Path();
    final segments = 8;
    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * math.pi;
      final wobble = 1.0 + 0.2 * math.sin(time * 0.7 + angle * 3 + offset);
      final px = dx + r * wobble * math.cos(angle);
      final py = dy + r * wobble * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        final prevAngle = ((i - 1) / segments) * 2 * math.pi;
        final prevWobble = 1.0 + 0.2 * math.sin(time * 0.7 + prevAngle * 3 + offset);
        final cp1x = dx + r * (wobble + prevWobble) * 0.5 * math.cos((angle + prevAngle) / 2) * 1.1;
        final cp1y = dy + r * (wobble + prevWobble) * 0.5 * math.sin((angle + prevAngle) / 2) * 1.1;
        path.quadraticBezierTo(cp1x, cp1y, px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LiquidBackgroundPainter oldDelegate) => true;
}

class LiquidBackground extends StatelessWidget {
  final Widget child;
  final Animation<double>? animation;

  const LiquidBackground({super.key, required this.child, this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation ?? const AlwaysStoppedAnimation(0),
      builder: (context, _) {
        return CustomPaint(
          painter: LiquidBackgroundPainter(
            animation: animation ?? const AlwaysStoppedAnimation(0),
          ),
          child: child,
        );
      },
    );
  }
}
