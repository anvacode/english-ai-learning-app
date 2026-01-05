import 'package:flutter/material.dart';
import '../data/lessons_data.dart';
import 'lesson_screen.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firstLesson = lessonsList.isNotEmpty ? lessonsList[0] : null;

    if (firstLesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lecciones')),
        body: const Center(
          child: Text('No lessons available'),
        ),
      );
    }

    return LessonScreen(lesson: firstLesson);
  }
}
