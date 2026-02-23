import 'dart:math';

class FeedbackMessages {
  static const List<String> _correctMessages = [
    '¡Excelente! 🌟',
    '¡Muy bien! 🎉',
    '¡Perfecto! ⭐',
    '¡Correcto! 👏',
    '¡Buen trabajo! 💪',
    '¡Lo lograste! 🏆',
  ];

  static const List<String> _encouragementMessages = [
    '¡Sigue así!',
    '¡Eres genial!',
    '¡Sigue aprendiendo!',
    '¡Vas muy bien!',
    '¡Cada vez mejor!',
  ];

  static const List<String> _tryAgainMessages = [
    '¡Inténtalo de nuevo! 💪',
    '¡No te rindas! 🌟',
    '¡Tú puedes! 🎯',
    '¡Ánimo! ⭐',
    '¡Sigue intentando! 💫',
  ];

  static String getCorrectMessage({bool includeEncouragement = false}) {
    final random = Random();
    final correctMsg =
        _correctMessages[random.nextInt(_correctMessages.length)];

    if (includeEncouragement) {
      final encouragementMsg =
          _encouragementMessages[random.nextInt(_encouragementMessages.length)];
      return '$correctMsg $encouragementMsg';
    }

    return correctMsg;
  }

  static String getTryAgainMessage({required int attemptNumber}) {
    final random = Random();

    if (attemptNumber == 1) {
      return _tryAgainMessages[random.nextInt(_tryAgainMessages.length)];
    } else if (attemptNumber == 2) {
      return '¡Casi lo tienes! 🎯';
    } else {
      return '¡Tú puedes! 💪';
    }
  }
}
