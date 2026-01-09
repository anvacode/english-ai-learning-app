import 'lesson_item.dart';
import 'lesson_exercise.dart';

class Lesson {
  final String id;
  final String title;
  final String question;
  final List<LessonItem> items;
  final List<LessonExercise> exercises;

  Lesson({
    required this.id,
    required this.title,
    required this.question,
    required this.items,
    required this.exercises,
  });
}
