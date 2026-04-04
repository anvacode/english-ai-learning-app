import '../models/diagnostic_question.dart';

class DiagnosticQuestionsData {
  static const List<DiagnosticQuestion> questions = [
    // ===== ANIMALES (4 preguntas) =====
    DiagnosticQuestion(
      id: '1',
      questionEn: 'Which one is the DOG?',
      questionEs: '¿Which one is the DOG?',
      mainEmoji: '🐕',
      options: ['🐱', '🐕', '🦊', '🐰'],
      correctAnswerIndex: 1,
      type: DiagnosticQuestionType.vocab,
    ),
    DiagnosticQuestion(
      id: '2',
      questionEn: 'Which one is the CAT?',
      questionEs: '¿Which one is the CAT?',
      mainEmoji: '🐱',
      options: ['🐶', '🐱', '🐭', '🐰'],
      correctAnswerIndex: 1,
      type: DiagnosticQuestionType.vocab,
    ),
    DiagnosticQuestion(
      id: '3',
      questionEn: 'Which one is the BIRD?',
      questionEs: '¿Which one is the BIRD?',
      mainEmoji: '🐦',
      options: ['🐱', '🐕', '🐦', '🐟'],
      correctAnswerIndex: 2,
      type: DiagnosticQuestionType.vocab,
    ),
    DiagnosticQuestion(
      id: '4',
      questionEn: 'Which one is a FISH?',
      questionEs: '¿Which one is a FISH?',
      mainEmoji: '🐟',
      options: ['🐠', '🐟', '🦀', '🐬'],
      correctAnswerIndex: 1,
      type: DiagnosticQuestionType.vocab,
    ),

    // ===== COLORES (2 preguntas) =====
    DiagnosticQuestion(
      id: '5',
      questionEn: 'What color is this?',
      questionEs: '¿What color is this?',
      mainEmoji: '🔴',
      options: ['🔴', '🔵', '🟢', '🟡'],
      correctAnswerIndex: 0,
      type: DiagnosticQuestionType.color,
    ),
    DiagnosticQuestion(
      id: '6',
      questionEn: 'What color is this?',
      questionEs: '¿What color is this?',
      mainEmoji: '🔵',
      options: ['🟡', '🟠', '🔵', '🟣'],
      correctAnswerIndex: 2,
      type: DiagnosticQuestionType.color,
    ),

    // ===== NÚMEROS (2 preguntas) =====
    DiagnosticQuestion(
      id: '7',
      questionEn: 'How many stars?',
      questionEs: '¿How many stars?',
      mainEmoji: '⭐⭐',
      options: ['1', '2', '3', '4'],
      correctAnswerIndex: 2,
      type: DiagnosticQuestionType.number,
    ),
    DiagnosticQuestion(
      id: '8',
      questionEn: 'How many apples?',
      questionEs: '¿How many apples?',
      mainEmoji: '🍎🍎🍎',
      options: ['1', '2', '3', '4'],
      correctAnswerIndex: 2,
      type: DiagnosticQuestionType.number,
    ),

    // ===== COMIDA (1 pregunta) =====
    DiagnosticQuestion(
      id: '9',
      questionEn: 'Which one is an APPLE?',
      questionEs: '¿Which one is an APPLE?',
      mainEmoji: '🍎',
      options: ['🍌', '🍎', '🍇', '🍊'],
      correctAnswerIndex: 1,
      type: DiagnosticQuestionType.vocab,
    ),

    // ===== NATURALEZA (1 pregunta) =====
    DiagnosticQuestion(
      id: '10',
      questionEn: 'Where is the SUN?',
      questionEs: '¿Where is the SUN?',
      mainEmoji: '☀️',
      options: ['☀️', '🌙', '⭐', '🌧️'],
      correctAnswerIndex: 0,
      type: DiagnosticQuestionType.vocab,
    ),
  ];
}
