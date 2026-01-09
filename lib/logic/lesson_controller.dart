import 'package:flutter/foundation.dart';

/// Controller for managing lesson state using Provider.
/// Handles question progression and answer tracking for a single exercise.
class LessonController extends ChangeNotifier {
  int _currentQuestionIndex = 0;
  int _totalQuestions = 0;
  int _correctAnswers = 0;

  /// Current question index (0-based)
  int get currentQuestionIndex => _currentQuestionIndex;

  /// Total number of questions in this exercise
  int get totalQuestions => _totalQuestions;

  /// Number of correct answers so far
  int get correctAnswers => _correctAnswers;

  /// Progress as a value between 0.0 and 1.0
  double get progress {
    if (_totalQuestions == 0) return 0.0;
    return _correctAnswers / _totalQuestions;
  }

  /// Whether all questions have been answered correctly
  bool get isLessonCompleted {
    if (_totalQuestions == 0) return false;
    return _correctAnswers == _totalQuestions;
  }

  /// Initialize the lesson with total number of questions
  void initializeLesson(int totalQuestions) {
    _currentQuestionIndex = 0;
    _totalQuestions = totalQuestions;
    _correctAnswers = 0;
    notifyListeners();
  }

  /// Submit an answer and update progress
  /// 
  /// Parameters:
  /// - isCorrect: whether the submitted answer was correct
  void submitAnswer({required bool isCorrect}) {
    // Only increment correct count if the answer was correct
    if (isCorrect) {
      _correctAnswers++;
    }
    
    // Move to next question
    _currentQuestionIndex++;
    
    // Notify listeners exactly once
    notifyListeners();
  }

  /// Reset the lesson state
  void reset() {
    _currentQuestionIndex = 0;
    _totalQuestions = 0;
    _correctAnswers = 0;
    notifyListeners();
  }
}
