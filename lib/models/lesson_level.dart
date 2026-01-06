import '../models/lesson.dart';

/// Nivel educativo que agrupa lecciones por dificultad.
class LessonLevel {
  final String id;
  final String title;
  final List<Lesson> lessons;

  const LessonLevel({
    required this.id,
    required this.title,
    required this.lessons,
  });
}
