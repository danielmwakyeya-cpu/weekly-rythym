import 'package:flutter/material.dart';

class MoonPhaseIcon extends StatelessWidget {
  final String phase;
  final double size;
  final Color? color;

  const MoonPhaseIcon({
    super.key,
    required this.phase,
    this.size = 18,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final moonColor = color ?? const Color(0xFFFBF0F3);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MoonPainter(phase: phase, color: moonColor),
      ),
    );
  }
}

class _MoonPainter extends CustomPainter {
  final String phase;
  final Color color;

  _MoonPainter({required this.phase, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final basePaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final litPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw background disc (dim moon)
    canvas.drawCircle(center, radius, basePaint);

    // Draw lit phase
    switch (phase) {
      case 'full':
        canvas.drawCircle(center, radius, litPaint);
        break;
      case 'first-quarter':
        // Right half lit
        final rect = Rect.fromCircle(center: center, radius: radius);
        canvas.drawArc(rect, -1.5708, 3.1416, true, litPaint);
        break;
      case 'last-quarter':
        // Left half lit
        final rect = Rect.fromCircle(center: center, radius: radius);
        canvas.drawArc(rect, 1.5708, 3.1416, true, litPaint);
        break;
      case 'waxing-crescent':
        final path = Path();
        path.arcTo(Rect.fromCircle(center: center, radius: radius), -1.5708, 3.1416, false);
        path.arcTo(Rect.fromCenter(center: center, width: radius * 0.8, height: radius * 2), 1.5708, 3.1416, false);
        canvas.drawPath(path, litPaint);
        break;
      case 'waning-crescent':
        final path = Path();
        path.arcTo(Rect.fromCircle(center: center, radius: radius), 1.5708, 3.1416, false);
        path.arcTo(Rect.fromCenter(center: center, width: radius * 0.8, height: radius * 2), -1.5708, 3.1416, false);
        canvas.drawPath(path, litPaint);
        break;
      case 'waxing-gibbous':
        final path = Path();
        path.arcTo(Rect.fromCircle(center: center, radius: radius), -1.5708, 3.1416, false);
        path.arcTo(Rect.fromCenter(center: center, width: radius * 0.8, height: radius * 2), -1.5708, 3.1416, false);
        canvas.drawPath(path, litPaint);
        break;
      case 'waning-gibbous':
        final path = Path();
        path.arcTo(Rect.fromCircle(center: center, radius: radius), 1.5708, 3.1416, false);
        path.arcTo(Rect.fromCenter(center: center, width: radius * 0.8, height: radius * 2), 1.5708, 3.1416, false);
        canvas.drawPath(path, litPaint);
        break;
      default:
        canvas.drawCircle(center, radius, litPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MoonPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.color != color;
}
