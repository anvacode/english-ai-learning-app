import 'package:flutter/material.dart';

/// Widget del búho guía para el tutorial.
///
/// Aparece en cada paso con un bocadillo de diálogo mostrando
/// la instrucción. Tiene animación de salto al completar un paso.
class TutorialMascot extends StatefulWidget {
  final String instruction;
  final bool animateJump;

  const TutorialMascot({
    super.key,
    required this.instruction,
    this.animateJump = false,
  });

  @override
  State<TutorialMascot> createState() => _TutorialMascotState();
}

class _TutorialMascotState extends State<TutorialMascot>
    with TickerProviderStateMixin {
  late AnimationController _jumpController;
  late Animation<double> _jumpAnimation;

  @override
  void initState() {
    super.initState();

    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -20.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -20.0, end: 5.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 5.0, end: 0.0),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(parent: _jumpController, curve: Curves.easeOut),
    );

    if (widget.animateJump) {
      _jumpController.forward();
    }
  }

  @override
  void didUpdateWidget(TutorialMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animateJump && !oldWidget.animateJump) {
      _jumpController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _jumpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _jumpAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _jumpAnimation.value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Bocadillo de diálogo (arriba)
                _buildSpeechBubble(),
                const SizedBox(height: 8),
                // Búho (abajo, centrado)
                Center(child: _buildOwl()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        widget.instruction,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
          height: 1.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOwl() {
    return SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(
        painter: _OwlPainter(),
      ),
    );
  }
}

/// Painter que dibuja el búho del tutorial
class _OwlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Gorro de graduación (azul)
    final hatPaint = Paint()..color = const Color(0xFF1E88E5);

    // Parte superior del gorro (rombo)
    final hatPath = Path()
      ..moveTo(cx, cy - 40)
      ..lineTo(cx - 25, cy - 28)
      ..lineTo(cx, cy - 16)
      ..lineTo(cx + 25, cy - 28)
      ..close();
    canvas.drawPath(hatPath, hatPaint);

    // Borla
    canvas.drawCircle(Offset(cx + 25, cy - 22), 3.5, hatPaint);

    // Hilo de la borla
    final threadPaint = Paint()
      ..color = const Color(0xFF1E88E5)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(cx + 25, cy - 22),
      Offset(cx + 25, cy - 32),
      threadPaint,
    );

    // Cuerpo principal (óvalo)
    final bodyPaint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 5),
        width: 65,
        height: 55,
      ),
      bodyPaint,
    );

    // Contorno del cuerpo
    final bodyOutline = Paint()
      ..color = const Color(0xFF5BA3C9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 5),
        width: 65,
        height: 55,
      ),
      bodyOutline,
    );

    // Ala izquierda
    final wingPaint = Paint()..color = const Color(0xFF6BB5D6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 28, cy + 8),
        width: 22,
        height: 32,
      ),
      wingPaint,
    );

    // Ala derecha
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 28, cy + 8),
        width: 22,
        height: 32,
      ),
      wingPaint,
    );

    // Barriga (más clara)
    final bellyPaint = Paint()..color = const Color(0xFFB8E4F0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 12),
        width: 40,
        height: 35,
      ),
      bellyPaint,
    );

    // Ojos (blancos) - más pequeños
    final eyeWhitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 13, cy - 5), 13, eyeWhitePaint);
    canvas.drawCircle(Offset(cx + 13, cy - 5), 13, eyeWhitePaint);

    // Contorno de ojos
    final eyeOutline = Paint()
      ..color = const Color(0xFF5BA3C9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(cx - 13, cy - 5), 13, eyeOutline);
    canvas.drawCircle(Offset(cx + 13, cy - 5), 13, eyeOutline);

    // Pupilas (negras) - más pequeñas
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(cx - 11, cy - 5), 6, pupilPaint);
    canvas.drawCircle(Offset(cx + 15, cy - 5), 6, pupilPaint);

    // Brillo en pupilas
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 9, cy - 8), 2.5, shinePaint);
    canvas.drawCircle(Offset(cx + 17, cy - 8), 2.5, shinePaint);

    // Pico (naranja)
    final beakPaint = Paint()..color = const Color(0xFFFFA500);
    final beakPath = Path()
      ..moveTo(cx, cy + 5)
      ..lineTo(cx - 8, cy + 16)
      ..lineTo(cx + 8, cy + 16)
      ..close();
    canvas.drawPath(beakPath, beakPaint);

    // Contorno del pico
    final beakOutline = Paint()
      ..color = const Color(0xFFCC8400)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(beakPath, beakOutline);

    // Patas (naranja)
    final feetPaint = Paint()..color = const Color(0xFFFFA500);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 12, cy + 30),
        width: 14,
        height: 7,
      ),
      feetPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 12, cy + 30),
        width: 14,
        height: 7,
      ),
      feetPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OwlPainter oldDelegate) => false;
}
