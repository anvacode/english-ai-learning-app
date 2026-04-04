import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diagnostic_question.dart';
import '../models/diagnostic_result.dart';
import '../data/diagnostic_questions_data.dart';

class DiagnosticService {
  static const String _diagnosticCompletedKey = 'diagnostic_completed';
  static const String _diagnosticLevelKey = 'diagnostic_level';
  static const String _diagnosticResultKey = 'diagnostic_result';

  static Future<bool> isDiagnosticCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_diagnosticCompletedKey) ?? false;
  }

  static Future<String?> getUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_diagnosticLevelKey);
  }

  static Future<DiagnosticResult?> getDiagnosticResult() async {
    final prefs = await SharedPreferences.getInstance();
    final resultJson = prefs.getString(_diagnosticResultKey);
    if (resultJson == null) return null;

    try {
      return DiagnosticResult.fromJson(jsonDecode(resultJson));
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveDiagnosticResult(DiagnosticResult result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_diagnosticCompletedKey, true);
    await prefs.setString(_diagnosticLevelKey, result.level);
    await prefs.setString(_diagnosticResultKey, jsonEncode(result.toJson()));
  }

  static DiagnosticResult calculateResult(List<int?> answers) {
    final questions = DiagnosticQuestionsData.questions;

    int correctAnswers = 0;

    for (int i = 0; i < questions.length; i++) {
      if (answers[i] != null && questions[i].isCorrect(answers[i]!)) {
        correctAnswers++;
      }
    }

    String level = correctAnswers >= 5 ? 'intermediate' : 'beginner';

    return DiagnosticResult(
      level: level,
      score: correctAnswers,
      totalQuestions: questions.length,
      basicCorrect: correctAnswers,
      intermediateCorrect: 0,
      advancedCorrect: 0,
      completedAt: DateTime.now(),
    );
  }

  static Future<void> resetDiagnostic() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_diagnosticCompletedKey);
    await prefs.remove(_diagnosticLevelKey);
    await prefs.remove(_diagnosticResultKey);
  }
}
