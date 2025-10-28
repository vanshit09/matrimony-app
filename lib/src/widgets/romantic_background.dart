import 'package:flutter/material.dart';

typedef BackgroundChildBuilder = Widget Function(BuildContext context);

class RomanticBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const RomanticBackground({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE0E6), Color(0xFFF3E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: CustomPaint(
              painter: _HeartsPainter(
                color: Colors.white.withOpacity(0.18),
              ),
            ),
          ),
          if (padding != null)
            Padding(padding: padding!, child: child)
          else
            child,
        ],
      ),
    );
  }
}

class _HeartsPainter extends CustomPainter {
  final Color color;
  const _HeartsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw a subtle grid of small hearts
    const double stepX = 64;
    const double stepY = 64;
    for (double y = stepY / 2; y < size.height; y += stepY) {
      for (double x = stepX / 2; x < size.width; x += stepX) {
        final offsetX = ((y ~/ stepY) % 2 == 0) ? 0.0 : stepX / 2; // stagger
        _drawHeart(canvas, Offset(x + offsetX, y), 8.5, paint);
      }
    }
  }

  void _drawHeart(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    // Simple heart path
    path.moveTo(c.dx, c.dy + r / 2);
    path.cubicTo(
      c.dx + r, c.dy - r, // control1
      c.dx + 2 * r, c.dy + r / 3, // control2
      c.dx, c.dy + 2 * r, // end1
    );
    path.cubicTo(
      c.dx - 2 * r, c.dy + r / 3, // control3
      c.dx - r, c.dy - r, // control4
      c.dx, c.dy + r / 2, // close
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartsPainter oldDelegate) => false;
}
