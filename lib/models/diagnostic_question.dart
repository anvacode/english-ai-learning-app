import 'package:flutter/material.dart';

enum DiagnosticQuestionType { multipleChoice, fillBlank }

enum DiagnosticLevel { beginner, intermediate, advanced }

class DiagnosticQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final DiagnosticQuestionType type;
  final DiagnosticLevel level;
  final String? hint;

  const DiagnosticQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.type,
    required this.level,
    this.hint,
  });

  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }

  String get levelName {
    switch (level) {
      case DiagnosticLevel.beginner:
        return 'Básico';
      case DiagnosticLevel.intermediate:
        return 'Intermedio';
      case DiagnosticLevel.advanced:
        return 'Avanzado';
    }
  }

  IconData get levelIcon {
    switch (level) {
      case DiagnosticLevel.beginner:
        return Icons.looks_one;
      case DiagnosticLevel.intermediate:
        return Icons.looks_two;
      case DiagnosticLevel.advanced:
        return Icons.looks_3;
    }
  }

  Color get levelColor {
    switch (level) {
      case DiagnosticLevel.beginner:
        return Colors.green;
      case DiagnosticLevel.intermediate:
        return Colors.orange;
      case DiagnosticLevel.advanced:
        return Colors.red;
    }
  }
}
