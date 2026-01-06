import 'package:flutter/material.dart';
import '../data/lessons_data.dart';
import '../logic/mastery_evaluator.dart';
import '../models/lesson.dart';
import 'lesson_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final _evaluator = MasteryEvaluator();

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
    return Scaffold(
      appBar: AppBar(title: const Text('Lecciones')),
      body: lessonLevels.isEmpty
          ? const Center(
              child: Text('No lessons available'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: lessonLevels.length,
              itemBuilder: (context, index) {
                final level = lessonLevels[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Level title
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
                      child: Text(
                        level.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    // Lessons in this level
                    if (level.lessons.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'No lessons available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      ...level.lessons.map((lesson) {
                        return LessonListItem(
                          lesson: lesson,
                          evaluator: _evaluator,
                          getStatusColor: _getStatusColor,
                          getStatusText: _getStatusText,
                        );
                      }),
                    const SizedBox(height: 12.0),
                  ],
                );
              },
            ),
    );
  }
}

/// Widget que representa un ítem de lección en la lista.
class LessonListItem extends StatelessWidget {
  final Lesson lesson;
  final MasteryEvaluator evaluator;
  final Function(LessonMasteryStatus) getStatusColor;
  final Function(LessonMasteryStatus) getStatusText;

  const LessonListItem({
    super.key,
    required this.lesson,
    required this.evaluator,
    required this.getStatusColor,
    required this.getStatusText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonScreen(lesson: lesson),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Título/ID de la lección
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${lesson.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Badge de estado de dominio
              FutureBuilder<LessonMasteryStatus>(
                future: evaluator.evaluateLesson(lesson.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    );
                  }

                  final status = snapshot.data!;
                  final statusColor = getStatusColor(status);
                  final statusText = getStatusText(status);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
