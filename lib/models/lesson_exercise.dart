/// Defines the type of exercise in a lesson.
enum ExerciseType {
  multipleChoice,
  matching,
  spelling,
}

/// A single exercise within a lesson flow.
class LessonExercise {
  final ExerciseType type;
  final String? title;

  const LessonExercise({
    required this.type,
    this.title,
  });
}
