import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'feedback_messages.dart';

/// Widget de retroalimentación llamativo para niños
class FeedbackWidget extends StatelessWidget {
  final bool isCorrect;
  final int attemptNumber;
  final String? correctAnswer;
  final VoidCallback onContinue;

  const FeedbackWidget({
    super.key,
    required this.isCorrect,
    required this.attemptNumber,
    this.correctAnswer,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    Color backgroundColor;
    Color textColor;
    String buttonText;

    if (isCorrect) {
      message = FeedbackMessages.getCorrectMessage(includeEncouragement: true);
      backgroundColor = Colors.green[100]!;
      textColor = Colors.green[700]!;
      buttonText = '¡Continuar!';
    } else if (attemptNumber >= 3 && correctAnswer != null) {
      message = '💡 La respuesta correcta es: $correctAnswer';
      backgroundColor = Colors.orange[100]!;
      textColor = Colors.orange[700]!;
      buttonText = 'Siguiente';
    } else {
      message = FeedbackMessages.getTryAgainMessage(
        attemptNumber: attemptNumber,
      );
      backgroundColor = Colors.red[100]!;
      textColor = Colors.red[700]!;
      buttonText = 'Intentar de nuevo';
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withAlpha(100),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: isCorrect ? Colors.green : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              minimumSize: const Size(220, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
