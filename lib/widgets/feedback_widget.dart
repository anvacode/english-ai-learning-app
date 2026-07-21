import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
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
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: isMobile || isTablet
                ? _buildCompactLayout(context)
                : _buildDesktopLayout(context),
          ),
        );
      },
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: Responsive.scale(context, 320, 360, 400),
      ),
      padding: EdgeInsets.all(Responsive.scale(context, 12, 14, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getBackgroundColor().withAlpha(240),
            _getBackgroundColor().withAlpha(200),
            _getBackgroundColor().withAlpha(180),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withAlpha(100),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getTextColor().withAlpha(80),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withAlpha(60),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji con efecto glassmorphism
          Container(
            width: Responsive.scale(context, 56, 60, 64),
            height: Responsive.scale(context, 56, 60, 64),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white.withAlpha(120),
                  Colors.white.withAlpha(40),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withAlpha(80),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _cachedEmoji,
                style: TextStyle(
                  fontSize: Responsive.scale(context, 32, 36, 40),
                ),
              ),
            ),
          ),
          SizedBox(width: Responsive.scale(context, 12, 14, 16)),
          
          // Contenido: mensaje + botón
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mensaje
                Text(
                  _cachedMessage,
                  style: TextStyle(
                    fontSize: Responsive.scale(context, 14, 15, 16),
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Indicador de racha si aplica
                if (widget.streak >= 3) ...[
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange[400]!,
                          Colors.red[400]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🔥', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 3),
                        Text(
                          '${widget.streak}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                SizedBox(height: 8),
                
                // Botón compacto
                SizedBox(
                  width: double.infinity,
                  height: Responsive.scale(context, 36, 38, 40),
                  child: ElevatedButton(
                    onPressed: widget.onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isCorrect ? Colors.green : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getButtonText(),
                          style: TextStyle(
                            fontSize: Responsive.scale(context, 13, 14, 15),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          widget.isCorrect ? Icons.arrow_forward : Icons.refresh,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: Responsive.scale(context, 340, 380, 420),
      ),
      padding: EdgeInsets.all(Responsive.scale(context, 16, 18, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getBackgroundColor().withAlpha(240),
            _getBackgroundColor().withAlpha(200),
            _getBackgroundColor().withAlpha(180),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withAlpha(100),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getTextColor().withAlpha(80),
            blurRadius: 24,
            spreadRadius: 3,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withAlpha(60),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji con efecto glassmorphism
          Container(
            width: Responsive.scale(context, 64, 68, 72),
            height: Responsive.scale(context, 64, 68, 72),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white.withAlpha(120),
                  Colors.white.withAlpha(40),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withAlpha(80),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _cachedEmoji,
                style: TextStyle(
                  fontSize: Responsive.scale(context, 36, 40, 44),
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.scale(context, 10, 12, 14)),
          
          // Mensaje
          Text(
            _cachedMessage,
            style: TextStyle(
              fontSize: Responsive.scale(context, 15, 16, 17),
              fontWeight: FontWeight.bold,
              color: _getTextColor(),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Indicador de racha si aplica
          if (widget.streak >= 3) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange[400]!,
                    Colors.red[400]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🔥', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 4),
                  Text(
                    'Racha: ${widget.streak}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          SizedBox(height: Responsive.scale(context, 12, 14, 16)),
          
          // Botón
          SizedBox(
            width: double.infinity,
            height: Responsive.scale(context, 40, 42, 44),
            child: ElevatedButton(
              onPressed: widget.onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isCorrect ? Colors.green : AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getButtonText(),
                    style: TextStyle(
                      fontSize: Responsive.scale(context, 14, 15, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    widget.isCorrect ? Icons.arrow_forward : Icons.refresh,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
