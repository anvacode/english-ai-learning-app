import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/feedback_messages.dart';

/// Pantalla de completado de lección rediseñada con animaciones y efectos.
///
/// Muestra:
/// - Confetti automático
/// - Emoji grande de celebración con animación bounce
/// - Contador animado de estrellas
/// - Frase motivacional aleatoria
/// - Estadísticas de la lección
/// - Botones: Continuar, Repetir lección
class LessonCompletionScreen extends StatefulWidget {
  final String lessonTitle;
  final int starsEarned;
  final int correctAnswers;
  final int totalQuestions;
  final String? badgeIcon;
  final String? badgeTitle;
  final bool isPerfectScore;

  const LessonCompletionScreen({
    super.key,
    required this.lessonTitle,
    this.starsEarned = 0,
    this.correctAnswers = 0,
    this.totalQuestions = 0,
    this.badgeIcon,
    this.badgeTitle,
    this.isPerfectScore = false,
  });

  @override
  State<LessonCompletionScreen> createState() => _LessonCompletionScreenState();
}

class _LessonCompletionScreenState extends State<LessonCompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;
  bool _showConfetti = true;
  int _displayedStars = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _animateStars();
  }

  Future<void> _animateStars() async {
    for (int i = 0; i <= widget.starsEarned; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {
          _displayedStars = i;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motivationalMessage = FeedbackMessages.getCompletionMessage();
    final accuracy = widget.totalQuestions > 0
        ? (widget.correctAnswers / widget.totalQuestions * 100).round()
        : 0;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.scale(
                          scale: _bounceAnimation.value,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Emoji grande de celebración
                              Text(
                                widget.isPerfectScore ? '🏆' : '🎉',
                                style: const TextStyle(fontSize: 80),
                              ),
                              const SizedBox(height: 16),

                              // Título
                              Text(
                                widget.isPerfectScore
                                    ? '¡Puntuación perfecta!'
                                    : '¡Lección completada!',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),

                              // Nombre de la lección
                              Text(
                                widget.lessonTitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),

                              // Estrellas con contador animado
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 36,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '$_displayedStars',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Estadísticas
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(30),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      icon: Icons.check_circle,
                                      value:
                                          '${widget.correctAnswers}/${widget.totalQuestions}',
                                      label: 'Correctas',
                                    ),
                                    _buildStatItem(
                                      icon: Icons.percent,
                                      value: '$accuracy%',
                                      label: 'Precisión',
                                    ),
                                    if (widget.isPerfectScore)
                                      _buildStatItem(
                                        icon: Icons.emoji_events,
                                        value: 'Perfecto',
                                        label: '',
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Badge si existe
                              if (widget.badgeIcon != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withAlpha(50),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.amber.withAlpha(150),
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
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.badgeTitle ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (widget.badgeIcon != null)
                                const SizedBox(height: 20),

                              // Frase motivacional
                              Text(
                                motivationalMessage,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // Botón principal: Continuar
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primary,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Continuar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Botón secundario: Repetir lección
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'retry'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Repetir lección',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Confetti overlay
          if (_showConfetti)
            ConfettiOverlay(
              isPlaying: _showConfetti,
              onComplete: () {
                setState(() {
                  _showConfetti = false;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
      ],
    );
  }
}
