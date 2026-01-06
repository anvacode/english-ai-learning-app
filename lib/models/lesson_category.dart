import 'lesson.dart';

/// Categoría temática que agrupa lecciones relacionadas.
class LessonCategory {
  final String id;
  final String title;
  final String? description;
  final List<Lesson> lessons;

  LessonCategory({
    required this.id,
    required this.title,
    this.description,
    required this.lessons,
  });
}
