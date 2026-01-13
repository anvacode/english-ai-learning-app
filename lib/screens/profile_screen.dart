import 'package:flutter/material.dart';
import '../data/lessons_data.dart';
import '../logic/lesson_progress_evaluator.dart';
import '../logic/badge_service.dart';
import '../logic/mastery_evaluator.dart';
import '../models/badge.dart' as achievement;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Progreso'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Global Progress Section
            _buildGlobalProgress(),
            const SizedBox(height: 32),

            // Lessons Progress Section
            _buildLessonsProgress(),
            const SizedBox(height: 32),

            // Badges Section
            _buildBadgesSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Build global progress indicator
  Widget _buildGlobalProgress() {
    return FutureBuilder<double>(
      future: _calculateGlobalProgress(),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0.0;
        final percentage = (progress * 100).toStringAsFixed(0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progreso General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.deepPurple,
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage% completado',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build lesson progress list
  Widget _buildLessonsProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lecciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<_LessonProgressItem>>(
          future: _getLessonsProgress(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final lessons = snapshot.data ?? [];
            return Column(
              children: lessons
                  .map((lesson) => _buildLessonCard(lesson))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  /// Build a single lesson card
  Widget _buildLessonCard(_LessonProgressItem lesson) {
    final progressColor = _getProgressColor(lesson.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with badge icon if mastered
            Row(
              children: [
                Expanded(
                  child: Text(
                    lesson.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (lesson.badge != null && lesson.badge!.unlocked)
                  Text(
                    lesson.badge!.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Status and progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lesson.statusText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: progressColor,
                  ),
                ),
                Text(
                  '${lesson.completedCount} / ${lesson.totalCount}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: lesson.totalCount > 0
                    ? lesson.completedCount / lesson.totalCount
                    : 0,
                backgroundColor: Colors.grey[300],
                color: progressColor,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build badges section
  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Badges Desbloqueados',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<achievement.Badge>>(
          future: BadgeService.getBadges(lessonsList),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final badges = snapshot.data ?? [];
            final unlockedBadges = badges.where((b) => b.unlocked).toList();

            if (unlockedBadges.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Domina lecciones para desbloquear badges',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: unlockedBadges
                  .map(
                    (badge) => Tooltip(
                      message: badge.title,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.amber[400]!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            badge.icon,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  /// Helper: Calculate global progress (average across all lessons)
  /// Based on lesson states: notStarted=0%, inProgress=50%, mastered=100%
  Future<double> _calculateGlobalProgress() async {
    if (lessonsList.isEmpty) return 0.0;

    final evaluator = MasteryEvaluator();
    double totalProgress = 0.0;

    for (final lesson in lessonsList) {
      final status = await evaluator.evaluateLesson(lesson.id);
      
      // Map status to progress value
      final lessonProgress = switch (status) {
        LessonMasteryStatus.notStarted => 0.0,
        LessonMasteryStatus.inProgress => 0.5,
        LessonMasteryStatus.mastered => 1.0,
      };
      
      totalProgress += lessonProgress;
    }

    return totalProgress / lessonsList.length;
  }

  /// Helper: Get lessons progress data
  Future<List<_LessonProgressItem>> _getLessonsProgress() async {
    final service = LessonProgressService();
    final evaluator = MasteryEvaluator();
    final progressItems = <_LessonProgressItem>[];

    for (final lesson in lessonsList) {
      final progress = await service.evaluate(lesson);
      final badge = await BadgeService.getBadge(lesson);
      
      // Get actual mastery status (not accumulated progress evaluation)
      final masteryStatus = await evaluator.evaluateLesson(lesson.id);
      
      // Convert LessonMasteryStatus to LessonProgressStatus (same values)
      final displayStatus = switch (masteryStatus) {
        LessonMasteryStatus.notStarted => LessonProgressStatus.notStarted,
        LessonMasteryStatus.inProgress => LessonProgressStatus.inProgress,
        LessonMasteryStatus.mastered => LessonProgressStatus.mastered,
      };

      progressItems.add(
        _LessonProgressItem(
          lessonId: lesson.id,
          title: lesson.title,
          completedCount: progress.completedCount,
          totalCount: progress.totalCount,
          status: displayStatus,
          badge: badge,
        ),
      );
    }

    return progressItems;
  }

  /// Helper: Get status text in Spanish
  Color _getProgressColor(LessonProgressStatus status) {
    switch (status) {
      case LessonProgressStatus.notStarted:
        return Colors.grey;
      case LessonProgressStatus.inProgress:
        return Colors.amber;
      case LessonProgressStatus.mastered:
        return Colors.green;
    }
  }
}

/// Data class for lesson progress display
class _LessonProgressItem {
  final String lessonId;
  final String title;
  final int completedCount;
  final int totalCount;
  final LessonProgressStatus status;
  final achievement.Badge? badge;

  _LessonProgressItem({
    required this.lessonId,
    required this.title,
    required this.completedCount,
    required this.totalCount,
    required this.status,
    this.badge,
  });

  String get statusText {
    switch (status) {
      case LessonProgressStatus.notStarted:
        return 'No iniciada';
      case LessonProgressStatus.inProgress:
        return 'En progreso';
      case LessonProgressStatus.mastered:
        return 'Dominada';
    }
  }
}
