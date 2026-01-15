import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Diálogo de feedback al completar una lección.
/// 
/// Muestra:
/// - Estrellas ganadas
/// - Mensaje de celebración
/// - Estadísticas de la lección
/// - Badge si se desbloqueó
class LessonCompletionDialog extends StatefulWidget {
  final String lessonTitle;
  final int starsEarned;
  final int correctAnswers;
  final int totalQuestions;
  final String? badgeIcon;
  final String? badgeTitle;
  final bool isPerfectScore;

  const LessonCompletionDialog({
    super.key,
    required this.lessonTitle,
    required this.starsEarned,
    required this.correctAnswers,
    required this.totalQuestions,
    this.badgeIcon,
    this.badgeTitle,
    this.isPerfectScore = false,
  });

  /// Muestra el diálogo de finalización de lección.
  static Future<void> show(
    BuildContext context, {
    required String lessonTitle,
    required int starsEarned,
    required int correctAnswers,
    required int totalQuestions,
    String? badgeIcon,
    String? badgeTitle,
    bool isPerfectScore = false,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LessonCompletionDialog(
        lessonTitle: lessonTitle,
        starsEarned: starsEarned,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        badgeIcon: badgeIcon,
        badgeTitle: badgeTitle,
        isPerfectScore: isPerfectScore,
      ),
    );
  }

  @override
  State<LessonCompletionDialog> createState() => _LessonCompletionDialogState();
}

class _LessonCompletionDialogState extends State<LessonCompletionDialog>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _starController;
  late AnimationController _scaleController;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _starAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animación de celebración (rotación y escala)
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: Curves.elasticOut,
      ),
    );

    // Animación de estrellas (aparición)
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _starAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _starController,
        curve: Curves.easeOut,
      ),
    );

    // Animación de escala del diálogo
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutBack,
      ),
    );

    // Iniciar animaciones
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _celebrationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _starController.forward();
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _starController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.correctAnswers / widget.totalQuestions * 100).round();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple[50]!,
                Colors.purple[50]!,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Emoji de celebración animado
              AnimatedBuilder(
                animation: _celebrationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _celebrationAnimation.value * 2 * math.pi * 0.1,
                    child: Transform.scale(
                      scale: 0.5 + (_celebrationAnimation.value * 0.5),
                      child: const Text(
                        '🎉',
                        style: TextStyle(fontSize: 64),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Título
              Text(
                widget.isPerfectScore
                    ? '¡Puntuación Perfecta!'
                    : '¡Lección Completada!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // Nombre de la lección
              Text(
                widget.lessonTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),

              // Estrellas ganadas
              AnimatedBuilder(
                animation: _starAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _starAnimation.value,
                    child: Transform.scale(
                      scale: _starAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.amber[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber[700],
                              size: 24,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '+${widget.starsEarned}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Estadísticas
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            'Respuestas correctas:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Text(
                          '${widget.correctAnswers}/${widget.totalQuestions}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: widget.correctAnswers / widget.totalQuestions,
                      backgroundColor: Colors.grey[200],
                      color: widget.isPerfectScore
                          ? Colors.green
                          : Colors.deepPurple,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$percentage% de aciertos',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              // Badge si se desbloqueó
              if (widget.badgeIcon != null && widget.badgeTitle != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber[400]!,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.badgeIcon!,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Badge: ${widget.badgeTitle!}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Botón de continuar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '¡Continuar!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
