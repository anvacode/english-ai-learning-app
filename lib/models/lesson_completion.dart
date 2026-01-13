/// Represents ONE successful full lesson completion/mastery.
/// 
/// This is the ONLY source of truth for determining if a lesson is "Mastered".
/// Unlike ActivityResult (which tracks every question attempt), LessonCompletion
/// is created ONLY when a lesson is fully completed successfully (all questions correct + 80%+ accuracy).
/// 
/// Why this exists:
/// - Separates "attempted a lesson" (ActivityResult) from "mastered a lesson" (LessonCompletion)
/// - Makes "mastered" status explicit and queryable
/// - Enables badges to be awarded definitively (only on first LessonCompletion)
/// - Simplifies retry logic: failed attempts don't affect mastery status
class LessonCompletion {
  /// Lesson ID
  final String lessonId;

  /// When the lesson was successfully completed
  final DateTime completedAt;

  LessonCompletion({
    required this.lessonId,
    required this.completedAt,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'lessonId': lessonId,
    'completedAt': completedAt.toIso8601String(),
  };

  /// Create from JSON
  factory LessonCompletion.fromJson(Map<String, dynamic> json) => LessonCompletion(
    lessonId: json['lessonId'] as String,
    completedAt: DateTime.parse(json['completedAt'] as String),
  );

  @override
  String toString() => 'LessonCompletion(lessonId=$lessonId, completedAt=$completedAt)';
}
