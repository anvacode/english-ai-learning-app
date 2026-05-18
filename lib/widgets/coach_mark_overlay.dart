import 'package:flutter/material.dart';

/// Overlay visual que oscurece la pantalla y resalta un área específica.
///
/// Este widget SOLO dibuja el oscurecimiento visual. NO captura gestos.
/// Los gestos se manejan por separado en el padre para permitir que los
/// taps dentro del highlight lleguen a los botones interactivos.
class CoachMarkVisual extends StatelessWidget {
  final Rect highlightRect;
  final bool isCircular;
  final Color overlayColor;
  final double highlightPadding;
  final bool showPulse;

  const CoachMarkVisual({
    super.key,
    required this.highlightRect,
    this.isCircular = true,
    this.overlayColor = const Color(0xCC000000),
    this.highlightPadding = 12,
    this.showPulse = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo oscuro con cutout
        CustomPaint(
          painter: _CoachMarkPainter(
            highlightRect: highlightRect.inflate(highlightPadding),
            overlayColor: overlayColor,
            isCircular: isCircular,
          ),
          child: const SizedBox.expand(),
        ),

        // Anillo pulsante alrededor del highlight
        if (showPulse)
          _PulseRing(
            highlightRect: highlightRect.inflate(highlightPadding),
            isCircular: isCircular,
          ),
      ],
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

class _PulseRing extends StatefulWidget {
  final Rect highlightRect;
  final bool isCircular;

  const _PulseRing({
    required this.highlightRect,
    required this.isCircular,
  });

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _PulseRingPainter(
            highlightRect: widget.highlightRect,
            isCircular: widget.isCircular,
            progress: _animation.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _PulseRingPainter extends CustomPainter {
  final Rect highlightRect;
  final bool isCircular;
  final double progress;

  _PulseRingPainter({
    required this.highlightRect,
    required this.isCircular,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha((100 * (1 - progress)).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * (1 - progress);

    if (isCircular) {
      final radius = (highlightRect.width / 2) + (progress * 20);
      final center = highlightRect.center;
      canvas.drawCircle(center, radius, paint);
    } else {
      final rrect = RRect.fromRectAndRadius(
        highlightRect.inflate(progress * 20),
        const Radius.circular(16),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulseRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
