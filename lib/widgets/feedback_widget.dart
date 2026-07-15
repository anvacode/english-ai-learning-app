import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'feedback_messages.dart';

/// Widget de retroalimentación animado para niños.
///
/// Muestra un emoji grande con animación + mensaje motivacional:
/// - Correcto: emoji bounce + mensaje verde
/// - Incorrecto: emoji pulse + mensaje rojo/naranja
/// - Racha 3+: emoji fuego con escala creciente
class FeedbackWidget extends StatefulWidget {
  final bool isCorrect;
  final int attemptNumber;
  final int streak;
  final String? correctAnswer;
  final VoidCallback onContinue;

  const FeedbackWidget({
    super.key,
    required this.isCorrect,
    required this.attemptNumber,
    this.streak = 0,
    this.correctAnswer,
    required this.onContinue,
  });

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  late String _cachedMessage;
  late String _cachedEmoji;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _cacheMessageAndEmoji();
    _setupAnimations();
    _animationController.forward();
  }

  void _cacheMessageAndEmoji() {
    _cachedEmoji = _getEmojiForState();
    _cachedMessage = _getMessageForState();
  }

  String _getEmojiForState() {
    if (widget.isCorrect) {
      if (widget.streak >= 10) return '👑';
      if (widget.streak >= 7) return '🏆';
      if (widget.streak >= 5) return '💎';
      if (widget.streak >= 3) return '🔥';
      return '🎉';
    }
    return '💪';
  }

  String _getMessageForState() {
    if (widget.isCorrect) {
      if (widget.streak >= 3) {
        return FeedbackMessages.getStreakMessage(widget.streak);
      }
      return FeedbackMessages.getCorrectMessage(includeEncouragement: true);
    }
    if (widget.attemptNumber >= 3 && widget.correctAnswer != null) {
      return '💡 La respuesta correcta es: ${widget.correctAnswer}';
    }
    return FeedbackMessages.getTryAgainMessage(attemptNumber: widget.attemptNumber);
  }

  void _setupAnimations() {
    if (widget.isCorrect) {
      _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 20),
        TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 20),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
      ]).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));
      _shakeAnimation = const AlwaysStoppedAnimation(0.0);
    } else {
      _shakeAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 15),
        TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 15),
        TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 15),
        TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 15),
        TweenSequenceItem(tween: Tween(begin: 8.0, end: -5.0), weight: 15),
        TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 10),
        TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 15),
      ]).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      ]).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));
    }
  }

  @override
  void didUpdateWidget(FeedbackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // No reiniciar animación en rebuilds normales
    // La key estable garantiza que el widget no se recrea al cambiar de pregunta
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    if (widget.isCorrect) return Colors.green[100]!;
    if (widget.attemptNumber >= 3) return Colors.orange[100]!;
    return Colors.red[100]!;
  }

  Color _getTextColor() {
    if (widget.isCorrect) return Colors.green[700]!;
    if (widget.attemptNumber >= 3) return Colors.orange[700]!;
    return Colors.red[700]!;
  }

  String _getButtonText() {
    if (widget.isCorrect) return '¡Continuar!';
    if (widget.attemptNumber >= 3) return 'Siguiente';
    return 'Intentar de nuevo';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getBackgroundColor().withAlpha(120),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji grande animado
                  Text(
                    _cachedEmoji,
                    style: const TextStyle(fontSize: 56),
                  ),
                  const SizedBox(height: 8),
                  // Mensaje
                  Text(
                    _cachedMessage,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Botón
                  ElevatedButton(
                    onPressed: widget.onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.isCorrect ? Colors.green : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _getButtonText(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
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
