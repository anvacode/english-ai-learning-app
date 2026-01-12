import 'package:flutter/material.dart';

/// Immutable Question model used by LessonController as the single source of truth.
/// 
/// Contract:
/// - stimulus (color or image) uniquely identifies the question
/// - correctAnswer is a String value that MUST be in options
/// - options is a randomized list that ALWAYS contains correctAnswer
/// - options are generated EXACTLY ONCE during lesson init/retry
/// - options are NEVER regenerated inside widget build() methods
/// 
/// Options Generation Flow:
/// 1. LessonController.initializeLesson() builds Questions with randomized options
/// 2. Options are created via QuestionOptionsBuilder (ensures correct answer included)
/// 3. Options are shuffled before being stored in Question.options
/// 4. Question objects are immutable—options never change after construction
/// 5. On lesson retry, LessonController.retryLesson() creates FRESH Question objects
///    with new randomized options (no reuse from previous attempt)
/// 
/// UI Contract:
/// - UI reads options via LessonController.getCurrentQuestionOptions()
/// - UI never generates, shuffles, or modifies options
/// - UI never calls any randomization logic
class Question {
  final String id;
  final String title;
  final Color? stimulusColor;
  final String? stimulusImageAsset;
  final String correctAnswer;
  final List<String> options; // Already randomized, and contains correctAnswer

  const Question({
    required this.id,
    required this.title,
    this.stimulusColor,
    this.stimulusImageAsset,
    required this.correctAnswer,
    required this.options,
  });
}
