import 'package:flutter/material.dart';

enum PhraseLevel { beginner, intermediate }

class PronunciationPhrase {
  final String id;
  final String phrase;
  final String translation;
  final PhraseLevel level;
  final String? emoji;

  const PronunciationPhrase({
    required this.id,
    required this.phrase,
    required this.translation,
    required this.level,
    this.emoji,
  });

  String get levelName {
    switch (level) {
      case PhraseLevel.beginner:
        return 'Básico';
      case PhraseLevel.intermediate:
        return 'Intermedio';
    }
  }

  Color get levelColor {
    switch (level) {
      case PhraseLevel.beginner:
        return Colors.green;
      case PhraseLevel.intermediate:
        return Colors.orange;
    }
  }
}

class PronunciationPhrasesData {
  static const List<PronunciationPhrase> phrases = [
    // Nivel Básico - Saludos y cortesía
    PronunciationPhrase(
      id: 'b1',
      phrase: 'Hello',
      translation: 'Hola',
      level: PhraseLevel.beginner,
      emoji: '👋',
    ),
    PronunciationPhrase(
      id: 'b2',
      phrase: 'Good morning',
      translation: 'Buenos días',
      level: PhraseLevel.beginner,
      emoji: '🌅',
    ),
    PronunciationPhrase(
      id: 'b3',
      phrase: 'Good afternoon',
      translation: 'Buenas tardes',
      level: PhraseLevel.beginner,
      emoji: '☀️',
    ),
    PronunciationPhrase(
      id: 'b4',
      phrase: 'Good evening',
      translation: 'Buenas noches',
      level: PhraseLevel.beginner,
      emoji: '🌙',
    ),
    PronunciationPhrase(
      id: 'b5',
      phrase: 'Goodbye',
      translation: 'Adiós',
      level: PhraseLevel.beginner,
      emoji: '👋',
    ),
    PronunciationPhrase(
      id: 'b6',
      phrase: 'Thank you',
      translation: 'Gracias',
      level: PhraseLevel.beginner,
      emoji: '🙏',
    ),
    PronunciationPhrase(
      id: 'b7',
      phrase: 'Thank you very much',
      translation: 'Muchas gracias',
      level: PhraseLevel.beginner,
      emoji: '🙏',
    ),
    PronunciationPhrase(
      id: 'b8',
      phrase: 'You are welcome',
      translation: 'De nada',
      level: PhraseLevel.beginner,
      emoji: '😊',
    ),
    PronunciationPhrase(
      id: 'b9',
      phrase: 'Please',
      translation: 'Por favor',
      level: PhraseLevel.beginner,
      emoji: '🤝',
    ),
    PronunciationPhrase(
      id: 'b10',
      phrase: 'Excuse me',
      translation: 'Disculpe',
      level: PhraseLevel.beginner,
      emoji: '🙋',
    ),

    // Nivel Intermedio - Conversación básica
    PronunciationPhrase(
      id: 'i1',
      phrase: 'How are you?',
      translation: '¿Cómo estás?',
      level: PhraseLevel.intermediate,
      emoji: '❓',
    ),
    PronunciationPhrase(
      id: 'i2',
      phrase: 'I am fine',
      translation: 'Estoy bien',
      level: PhraseLevel.intermediate,
      emoji: '👍',
    ),
    PronunciationPhrase(
      id: 'i3',
      phrase: 'Nice to meet you',
      translation: 'Mucho gusto',
      level: PhraseLevel.intermediate,
      emoji: '🤝',
    ),
    PronunciationPhrase(
      id: 'i4',
      phrase: 'My name is',
      translation: 'Me llamo',
      level: PhraseLevel.intermediate,
      emoji: '👤',
    ),
    PronunciationPhrase(
      id: 'i5',
      phrase: 'What is your name?',
      translation: '¿Cómo te llamas?',
      level: PhraseLevel.intermediate,
      emoji: '❓',
    ),
    PronunciationPhrase(
      id: 'i6',
      phrase: 'See you later',
      translation: 'Hasta luego',
      level: PhraseLevel.intermediate,
      emoji: '👋',
    ),
    PronunciationPhrase(
      id: 'i7',
      phrase: 'See you tomorrow',
      translation: 'Hasta mañana',
      level: PhraseLevel.intermediate,
      emoji: '📅',
    ),
    PronunciationPhrase(
      id: 'i8',
      phrase: 'Have a nice day',
      translation: 'Que tengas un buen día',
      level: PhraseLevel.intermediate,
      emoji: '🌟',
    ),
    PronunciationPhrase(
      id: 'i9',
      phrase: 'I am sorry',
      translation: 'Lo siento',
      level: PhraseLevel.intermediate,
      emoji: '😔',
    ),
    PronunciationPhrase(
      id: 'i10',
      phrase: 'No problem',
      translation: 'No hay problema',
      level: PhraseLevel.intermediate,
      emoji: '✅',
    ),
  ];

  static List<PronunciationPhrase> getBeginnerPhrases() {
    return phrases.where((p) => p.level == PhraseLevel.beginner).toList();
  }

  static List<PronunciationPhrase> getIntermediatePhrases() {
    return phrases.where((p) => p.level == PhraseLevel.intermediate).toList();
  }

  static List<PronunciationPhrase> getByLevel(PhraseLevel level) {
    return phrases.where((p) => p.level == level).toList();
  }
}
