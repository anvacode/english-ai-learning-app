import 'package:flutter/material.dart';

enum DiagnosticQuestionType { vocab, color, number }

enum DiagnosticLevel { beginner, intermediate }

class DiagnosticQuestion {
  final String id;
  final String questionEn;
  final String questionEs;
  final String mainEmoji;
  final List<String> options;
  final int correctAnswerIndex;
  final DiagnosticQuestionType type;

  const DiagnosticQuestion({
    required this.id,
    required this.questionEn,
    required this.questionEs,
    required this.mainEmoji,
    required this.options,
    required this.correctAnswerIndex,
    required this.type,
  });

  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }

  String get question => questionEs;

  String get questionEnglish => questionEn;
}
