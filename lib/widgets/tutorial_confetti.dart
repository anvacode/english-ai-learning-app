import 'dart:math';

import 'package:flutter/material.dart';

/// Widget de confetti para celebraciones en el tutorial.
///
/// Muestra partículas coloridas que caen desde la parte superior
/// de la pantalla con animación de gravedad.
class TutorialConfetti extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;

  const TutorialConfetti({
    super.key,
    this.duration = const Duration(seconds: 2),
    this.onComplete,
  });

  @override
  State<TutorialConfetti> createState() => _TutorialConfettiState();
}

class _TutorialConfettiState extends State<TutorialConfetti>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiPiece> _pieces = [];
  final Random _random = Random();

  static const List<Color> _colors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF95E1D3),
    Color(0xFFF38181),
    Color(0xFFAA96DA),
    Color(0xFFFFD93D),
    Color(0xFF6BCB77),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete?.call();
        }
      });

    _generatePieces();
    _controller.forward();
  }

  void _generatePieces() {
    for (int i = 0; i < 50; i++) {
      _pieces.add(_ConfettiPiece(
        x: _random.nextDouble(),
        y: -0.1 - (_random.nextDouble() * 0.3),
        color: _colors[_random.nextInt(_colors.length)],
        size: 6 + _random.nextDouble() * 8,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        shape: _random.nextBool() ? _ConfettiShape.rect : _ConfettiShape.circle,
      ));
    }
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
          painter: _ConfettiPainter(
            pieces: _pieces,
            progress: _controller.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _ConfettiPiece {
  final double x;
  double y;
  final Color color;
  final double size;
  double rotation;
  final double rotationSpeed;
  final _ConfettiShape shape;

  _ConfettiPiece({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

enum _ConfettiShape { rect, circle }

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;

  _ConfettiPainter({
    required this.pieces,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final gravity = 1.5;
      piece.y += gravity * 0.016;

      if (piece.y > 1.2) continue;

      piece.rotation += piece.rotationSpeed * 0.016;

      final dx = piece.x * size.width;
      final dy = piece.y * size.height;

      final paint = Paint()..color = piece.color;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(piece.rotation);

      if (piece.shape == _ConfettiShape.rect) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.6,
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, piece.size / 2, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

/// Mini confetti para celebraciones pequeñas (por paso completado)
class MiniCelebration extends StatefulWidget {
  final VoidCallback onComplete;

  const MiniCelebration({super.key, required this.onComplete});

  @override
  State<MiniCelebration> createState() => _MiniCelebrationState();
}

class _MiniCelebrationState extends State<MiniCelebration>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.3),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 30,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
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
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 32, color: Colors.green[600]),
                  const SizedBox(width: 12),
                  Text(
                    '¡Muy bien!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
