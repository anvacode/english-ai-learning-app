import '../models/diagnostic_question.dart';

class DiagnosticQuestionsData {
  static const List<DiagnosticQuestion> questions = [
    // ===== NIVEL BÁSICO (4 preguntas) =====
    DiagnosticQuestion(
      id: 'b1',
      question: 'What color is the sky on a sunny day?',
      options: ['Blue', 'Red', 'Green', 'Yellow'],
      correctAnswerIndex: 0,
      type: DiagnosticQuestionType.multipleChoice,
      level: DiagnosticLevel.beginner,
    ),
    DiagnosticQuestion(
      id: 'b2',
      question: 'How do you say "perro" in English?',
      options: ['Cat', 'Dog', 'Bird', 'Fish'],
      correctAnswerIndex: 1,
      type: DiagnosticQuestionType.multipleChoice,
      level: DiagnosticLevel.beginner,
    ),
    DiagnosticQuestion(
      id: 'b3',
      question: 'Complete: "I ___ a student."',
      options: ['is', 'am', 'are', 'be'],
      correctAnswerIndex: 1,
      type: DiagnosticQuestionType.fillBlank,
      level: DiagnosticLevel.beginner,
    ),
    DiagnosticQuestion(
      id: 'b4',
      question: 'What is the opposite of "big"?',
      options: ['Tall', 'Small', 'Large', 'Huge'],
      correctAnswerIndex: 1,
      type: DiagnosticQuestionType.multipleChoice,
      level: DiagnosticLevel.beginner,
    ),

    // ===== NIVEL INTERMEDIO (4 preguntas) =====
    DiagnosticQuestion(
      id: 'i1',
      question: 'She ___ to school every day.',
      options: ['go', 'goes', 'going', 'went'],
      correctAnswerIndex: 1,
      type: DiagnosticQuestionType.fillBlank,
      level: DiagnosticLevel.intermediate,
    ),
    DiagnosticQuestion(
      id: 'i2',
      question: 'I have ___ finished my homework.',
      options: ['yet', 'already', 'ever', 'never'],
      correctAnswerIndex: 1,
      type: DiagnosticQuestionType.fillBlank,
      level: DiagnosticLevel.intermediate,
    ),
    DiagnosticQuestion(
      id: 'i3',
      question: 'If I were you, I ___ accept the offer.',
      options: ['will', 'would', 'shall', 'can'],
      correctAnswerIndex: 1,
      type: DiagnosticQuestionType.fillBlank,
      level: DiagnosticLevel.intermediate,
    ),
    DiagnosticQuestion(
      id: 'i4',
      question: 'The book ___ by millions of people.',
      options: ['has read', 'has been read', 'have read', 'have been read'],
      correctAnswerIndex: 1,
      type: DiagnosticQuestionType.fillBlank,
      level: DiagnosticLevel.intermediate,
    ),

    // ===== NIVEL AVANZADO (4 preguntas) =====
    DiagnosticQuestion(
      id: 'a1',
      question: 'If I had known about the meeting, I ___ attended.',
      options: ['would have', 'will have', 'had', 'would'],
      correctAnswerIndex: 0,
      type: DiagnosticQuestionType.fillBlank,
      level: DiagnosticLevel.advanced,
    ),
    DiagnosticQuestion(
      id: 'a2',
      question: 'Not only ___ late, but he also forgot his documents.',
      options: ['he was', 'was he', 'he is', 'is he'],
      correctAnswerIndex: 1,
      type: DiagnosticQuestionType.fillBlank,
      level: DiagnosticLevel.advanced,
    ),
    DiagnosticQuestion(
      id: 'a3',
      question:
          'The project, ___ was launched last month, has been very successful.',
      options: ['that', 'which', 'what', 'who'],
      correctAnswerIndex: 1,
      type: DiagnosticQuestionType.fillBlank,
      level: DiagnosticLevel.advanced,
    ),
    DiagnosticQuestion(
      id: 'a4',
      question: 'Had she studied harder, she ___ the exam.',
      options: ['would pass', 'would have passed', 'will pass', 'had passed'],
      correctAnswerIndex: 1,
      type: DiagnosticQuestionType.fillBlank,
      level: DiagnosticLevel.advanced,
    ),
  ];

  static List<DiagnosticQuestion> getBeginnerQuestions() {
    return questions.where((q) => q.level == DiagnosticLevel.beginner).toList();
  }

  static List<DiagnosticQuestion> getIntermediateQuestions() {
    return questions
        .where((q) => q.level == DiagnosticLevel.intermediate)
        .toList();
  }

  static List<DiagnosticQuestion> getAdvancedQuestions() {
    return questions.where((q) => q.level == DiagnosticLevel.advanced).toList();
  }
}
