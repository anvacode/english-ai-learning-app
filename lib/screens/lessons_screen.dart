import 'package:flutter/material.dart';
import '../data/lessons_data.dart';
import '../logic/mastery_evaluator.dart';
import 'lesson_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  late Future<LessonMasteryStatus> _masteryFuture;
  final _evaluator = MasteryEvaluator();

  @override
  void initState() {
    super.initState();
    // Evaluar dominio de la lección "colors_1"
    _masteryFuture = _evaluator.evaluateLesson('colors_1');
  }

  Color _getStatusColor(LessonMasteryStatus status) {
    switch (status) {
      case LessonMasteryStatus.notStarted:
        return Colors.grey;
      case LessonMasteryStatus.inProgress:
        return Colors.amber;
      case LessonMasteryStatus.mastered:
        return Colors.green;
    }
  }

  String _getStatusText(LessonMasteryStatus status) {
    switch (status) {
      case LessonMasteryStatus.notStarted:
        return 'Not started';
      case LessonMasteryStatus.inProgress:
        return 'In progress';
      case LessonMasteryStatus.mastered:
        return 'Mastered';
    }
  }

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

    return Stack(
      children: [
        LessonScreen(lesson: firstLesson),
        // Indicador de estado de dominio (top-left, no intrusivo)
        FutureBuilder<LessonMasteryStatus>(
          future: _masteryFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final status = snapshot.data!;
            final statusColor = _getStatusColor(status);
            final statusText = _getStatusText(status);

            return Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
