import 'lesson_item.dart';

class Lesson {
  final String id;
  final String title;
  final String question;
  final List<LessonItem> items;

  Lesson({
    required this.id,
    required this.title,
    required this.question,
    required this.items,
  });
}
