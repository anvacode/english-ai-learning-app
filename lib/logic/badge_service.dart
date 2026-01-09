import 'package:english_ai_app/models/badge.dart';
import 'package:english_ai_app/models/lesson.dart';
import 'package:english_ai_app/logic/lesson_progress_evaluator.dart';

/// Badge definitions for each lesson.
final Map<String, Map<String, String>> badgeDefinitions = {
  'colors': {'title': 'Color Master', 'icon': '🎨'},
  'fruits': {'title': 'Fruit Expert', 'icon': '🍎'},
  'animals': {'title': 'Animal Friend', 'icon': '🐾'},
};

/// Service para obtener badges basado en el progreso de las lecciones.
class BadgeService {
  /// Get all badges for a set of lessons.
  /// Badge is unlocked if lesson is mastered.
  static Future<List<Badge>> getBadges(List<Lesson> lessons) async {
    final service = LessonProgressService();
    final badges = <Badge>[];

    for (final lesson in lessons) {
      final progress = await service.evaluate(lesson);
      final isMastered = progress.status == LessonProgressStatus.mastered;

      final badgeDef = badgeDefinitions[lesson.id];
      if (badgeDef != null) {
        badges.add(
          Badge(
            lessonId: lesson.id,
            title: badgeDef['title']!,
            icon: badgeDef['icon']!,
            unlocked: isMastered,
          ),
        );
      }
    }

    return badges;
  }

  /// Get a badge for a specific lesson.
  static Future<Badge?> getBadge(Lesson lesson) async {
    final service = LessonProgressService();
    final progress = await service.evaluate(lesson);
    final isMastered = progress.status == LessonProgressStatus.mastered;

    final badgeDef = badgeDefinitions[lesson.id];
    if (badgeDef == null) return null;

    return Badge(
      lessonId: lesson.id,
      title: badgeDef['title']!,
      icon: badgeDef['icon']!,
      unlocked: isMastered,
    );
  }
}
