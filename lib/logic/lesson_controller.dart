import 'package:flutter/foundation.dart';
import '../models/lesson_attempt.dart';

/// Controller for managing lesson state using Provider.
/// Handles lesson-level progress and per-attempt state through LessonAttempt.
class LessonController extends ChangeNotifier {
  /// Per-lesson progress state (persists across attempts)
  int _totalQuestions = 0;

  /// Current attempt session (reset on retry)
  LessonAttempt? _currentAttempt;

  /// Total number of questions in the lesson
  int get totalQuestions => _totalQuestions;

  /// Current question index in the active attempt
  int get currentQuestionIndex => _currentAttempt?.currentQuestionIndex ?? 0;

  /// Number of correct answers in the active attempt
  int get correctAnswers => _currentAttempt?.correctAnswersCount ?? 0;

  /// Progress as a value between 0.0 and 1.0
  double get progress {
    if (_currentAttempt == null || _totalQuestions == 0) return 0.0;
    return _currentAttempt!.progress;
  }

  /// Whether the current attempt is complete (all questions correct)
  bool get isLessonCompleted {
    if (_currentAttempt == null) return false;
    return _currentAttempt!.isComplete;
  }

  /// Initialize/start a lesson with a fresh attempt
  void initializeLesson(int totalQuestions) {
    _totalQuestions = totalQuestions;
    // Create a new attempt - this ensures retry always starts fresh
    _currentAttempt = LessonAttempt(totalQuestions: totalQuestions);
    notifyListeners();
  }

  /// Submit an answer and update the current attempt
  /// 
  /// Parameters:
  /// - itemId: the ID of the question item
  /// - selectedOption: the user's selected answer
  /// - isCorrect: whether the answer is correct
  /// 
  /// Returns whether the lesson should be restarted due to too many errors
  bool submitAnswer({
    required String itemId,
    required String selectedOption,
    required bool isCorrect,
  }) {
    if (_currentAttempt == null) return false;

    // Record the selected answer
    _currentAttempt!.recordSelectedAnswer(itemId, selectedOption);

    // Only increment correct count if the answer was correct
    if (isCorrect) {
      _currentAttempt!.recordCorrectAnswer(itemId);
      // Move to next question only if correct
      _currentAttempt!.nextQuestion();
    } else {
      // Record incorrect attempt
      _currentAttempt!.recordIncorrectAnswer(itemId);
      
      // Check if max attempts exceeded - if so, restart lesson
      if (_currentAttempt!.hasExceededMaxAttempts(itemId)) {
        notifyListeners();
        return true; // Signal that lesson should be restarted
      }
    }

    // Notify listeners of progress update
    notifyListeners();
    return false;
  }
  
  /// Get number of incorrect attempts for current question
  int getIncorrectAttemptsForCurrentQuestion(String itemId) {
    if (_currentAttempt == null) return 0;
    return _currentAttempt!.getIncorrectAttempts(itemId);
  }
  
  /// Restart the lesson (resets to beginning with fresh attempt)
  void restartLesson() {
    if (_totalQuestions > 0) {
      _currentAttempt = LessonAttempt(totalQuestions: _totalQuestions);
      notifyListeners();
    }
  }

  /// Reset the lesson state (only use for testing or explicit reset)
  void reset() {
    _totalQuestions = 0;
    _currentAttempt = null;
    notifyListeners();
  }

  /// Decrement the question index for a retry attempt
  /// Called when a user wants to retry the current question
  void decrementQuestionIndex() {
    if (_currentAttempt != null && _currentAttempt!.currentQuestionIndex > 0) {
      _currentAttempt!.previousQuestion();
      notifyListeners();
    }
  }

  /// Get the current attempt (for testing or advanced scenarios)
  LessonAttempt? get currentAttempt => _currentAttempt;
}