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
        return 'No iniciado';
      case LessonMasteryStatus.inProgress:
        return 'En progreso';
      case LessonMasteryStatus.mastered:
        return 'Dominado';
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
                final levelIndex = index;
                final isBeginnerLevel = levelIndex == 0;
                final previousLevel = !isBeginnerLevel ? lessonLevels[levelIndex - 1] : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Level title with lock indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            level.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        if (!isBeginnerLevel)
                          FutureBuilder<bool>(
                            future: previousLevel != null
                                ? _evaluator.areAllLessonsMastered(
                                    previousLevel.lessons.map((l) => l.id).toList(),
                                  )
                                : Future.value(true),
                            builder: (context, snapshot) {
                              final isUnlocked = snapshot.data ?? false;
                              if (!isUnlocked) {
                                return const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    '🔒',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // Lessons in this level
                    FutureBuilder<bool>(
                      future: isBeginnerLevel
                          ? Future.value(true)
                          : previousLevel != null
                              ? _evaluator.areAllLessonsMastered(
                                  previousLevel.lessons.map((l) => l.id).toList(),
                                )
                              : Future.value(true),
                      builder: (context, snapshot) {
                        final isLevelUnlocked = snapshot.data ?? false;

                        if (level.lessons.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'No lessons available',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          );
                        }

                        if (!isLevelUnlocked && !isBeginnerLevel) {
                          return Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              'Completa el nivel anterior para desbloquear',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: level.lessons
                              .map((lesson) => LessonListItem(
                                    lesson: lesson,
                                    evaluator: _evaluator,
                                    getStatusColor: _getStatusColor,
                                    getStatusText: _getStatusText,
                                    isLocked: !isLevelUnlocked && !isBeginnerLevel,
                                  ))
                              .toList(),
                        );
                      },
                    ),
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
  final bool isLocked;

  const LessonListItem({
    super.key,
    required this.lesson,
    required this.evaluator,
    required this.getStatusColor,
    required this.getStatusText,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: isLocked
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonScreen(lesson: lesson),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Opacity(
            opacity: isLocked ? 0.6 : 1.0,
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
                // Badge de estado de dominio o lock
                if (isLocked)
                  const Text(
                    '🔒',
                    style: TextStyle(fontSize: 24),
                  )
                else
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
      ),
    );
  }
}
