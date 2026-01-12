/// Utility for generating randomized question options.
/// 
/// Enforces the contract:
/// - Correct answer is ALWAYS included
/// - Options are generated from a predefined pool
/// - Generation happens exactly once per question (on lesson init/retry)
/// - Options are never regenerated inside build() methods
class QuestionOptionsBuilder {
  /// Build randomized options for a question.
  ///
  /// Parameters:
  /// - [correctAnswer]: The correct option (guaranteed to be included)
  /// - [incorrectOptions]: Pool of incorrect options to choose from
  ///
  /// Returns:
  /// - Shuffled list containing [correctAnswer] plus random [incorrectOptions]
  /// - List length = 1 (correct) + [incorrectOptions].length
  ///
  /// Contract:
  /// - correctAnswer is ALWAYS first added to the list
  /// - List is then shuffled
  /// - After shuffle, correctAnswer is guaranteed to be in the list
  /// - Caller is responsible for detecting the correct answer by string comparison
  static List<String> buildOptions({
    required String correctAnswer,
    required List<String> incorrectOptions,
  }) {
    // Start with the correct answer (guaranteed inclusion)
    final options = [correctAnswer];

    // Add all incorrect options
    options.addAll(incorrectOptions);

    // Shuffle to randomize order
    options.shuffle();

    // Defensive: Assert correct answer is still present (should always be true)
    assert(
      options.contains(correctAnswer),
      'FATAL: Correct answer "$correctAnswer" missing from generated options',
    );

    return options;
  }

  /// Build options from a predefined pool where each item includes the correct answer.
  ///
  /// This variant is used when lesson data defines options as:
  /// - options: [correct, wrong1, wrong2, ...]
  /// - correctAnswerIndex: index of correct answer in options
  ///
  /// Parameters:
  /// - [allOptions]: List containing [correctAnswer at correctAnswerIndex] + incorrect options
  /// - [correctAnswerIndex]: Index of the correct answer in [allOptions]
  ///
  /// Returns:
  /// - Shuffled list with correct answer guaranteed to be included
  ///
  /// Example:
  /// ```
  /// final options = ['red', 'blue', 'green'];
  /// final correctIndex = 0; // 'red' is correct
  /// final randomized = QuestionOptionsBuilder.buildOptionsFromPool(
  ///   allOptions: options,
  ///   correctAnswerIndex: correctIndex,
  /// );
  /// // Result: shuffled list containing 'red', 'blue', 'green'
  /// // 'red' is ALWAYS present
  /// ```
  static List<String> buildOptionsFromPool({
    required List<String> allOptions,
    required int correctAnswerIndex,
  }) {
    // Defensive: Bounds check
    if (correctAnswerIndex < 0 || correctAnswerIndex >= allOptions.length) {
      throw RangeError(
        'correctAnswerIndex $correctAnswerIndex out of range [0, ${allOptions.length - 1}]',
      );
    }

    // Extract correct answer
    final correctAnswer = allOptions[correctAnswerIndex];

    // Create a shuffled copy of all options
    final options = List<String>.from(allOptions);
    options.shuffle();

    // Defensive: Assert correct answer is present
    assert(
      options.contains(correctAnswer),
      'FATAL: Correct answer "$correctAnswer" missing from pool after shuffle',
    );

    return options;
  }
}
