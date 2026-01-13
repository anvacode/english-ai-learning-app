/// Represents a single lesson attempt/session.
/// Encapsulates all per-attempt state that should be reset when retrying.
class LessonAttempt {
  /// Current question index in this attempt (0-based)
  int currentQuestionIndex = 0;

  /// Number of correct answers in this attempt
  int correctAnswersCount = 0;

  /// Total number of questions in this attempt
  int totalQuestions;

  /// Track which items have been answered correctly in this attempt
  final Set<String> correctItemIds = {};

  /// Track selected answers per item (itemId -> selectedOption)
  final Map<String, String> selectedAnswers = {};

  LessonAttempt({required this.totalQuestions});

  /// Record a correct answer for an item in this attempt
  void recordCorrectAnswer(String itemId) {
    correctItemIds.add(itemId);
    correctAnswersCount++;
  }

  /// Record a selected answer for an item
  void recordSelectedAnswer(String itemId, String selectedOption) {
    selectedAnswers[itemId] = selectedOption;
  }

  /// Get progress as a percentage (0.0 to 1.0)
  double get progress {
    if (totalQuestions == 0) return 0.0;
    return correctAnswersCount / totalQuestions;
  }

  /// Whether all questions in this attempt have been answered correctly
  bool get isComplete {
    return correctAnswersCount == totalQuestions;
  }

  /// Move to next question
  void nextQuestion() {
    if (currentQuestionIndex < totalQuestions - 1) {
      currentQuestionIndex++;
    }
  }

  /// Move to previous question (for retry)
  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      currentQuestionIndex--;
    }
  }

  /// Reset the attempt to initial state
  void reset() {
    currentQuestionIndex = 0;
    correctAnswersCount = 0;
    correctItemIds.clear();
    selectedAnswers.clear();
  }
}
