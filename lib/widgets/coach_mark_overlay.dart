import 'package:flutter/material.dart';

/// Overlay que oscurece la pantalla y resalta un área específica.
///
/// Diseñado para tutoriales interactivos donde el usuario debe
/// tocar un elemento específico para avanzar.
class CoachMarkOverlay extends StatelessWidget {
  final Rect highlightRect;
  final String instruction;
  final VoidCallback onTap;
  final bool isCircular;
  final Color overlayColor;
  final double highlightPadding;

  const CoachMarkOverlay({
    super.key,
    required this.highlightRect,
    required this.instruction,
    required this.onTap,
    this.isCircular = true,
    this.overlayColor = const Color(0xCC000000),
    this.highlightPadding = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _CoachMarkPainter(
          highlightRect: highlightRect.inflate(highlightPadding),
          overlayColor: overlayColor,
          isCircular: isCircular,
        ),
        child: Stack(
          children: [
            // Flecha animada señalando el elemento
            _buildAnimatedArrow(),
            // Texto de instrucción
            _buildInstruction(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedArrow() {
    return Positioned(
      left: highlightRect.center.dx - 20,
      top: highlightRect.bottom + highlightPadding + 8,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Icon(
              Icons.touch_app,
              size: 40,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstruction(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 100,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            instruction,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _CoachMarkPainter extends CustomPainter {
  final Rect highlightRect;
  final Color overlayColor;
  final bool isCircular;

  _CoachMarkPainter({
    required this.highlightRect,
    required this.overlayColor,
    required this.isCircular,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (isCircular) {
      final radius = highlightRect.width / 2;
      final center = highlightRect.center;
      path.addOval(Rect.fromCircle(center: center, radius: radius));
    } else {
      final rrect = RRect.fromRectAndRadius(
        highlightRect,
        const Radius.circular(16),
      );
      path.addRRect(rrect);
    }

    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Borde brillante alrededor del highlight
    final borderPaint = Paint()
      ..color = Colors.white.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    if (isCircular) {
      final radius = highlightRect.width / 2;
      final center = highlightRect.center;
      canvas.drawCircle(center, radius, borderPaint);
    } else {
      final rrect = RRect.fromRectAndRadius(
        highlightRect,
        const Radius.circular(16),
      );
      canvas.drawRRect(rrect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CoachMarkPainter oldDelegate) {
    return oldDelegate.highlightRect != highlightRect ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.isCircular != isCircular;
  }
}
