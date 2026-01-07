import '../models/lesson.dart';
import '../logic/activity_result_service.dart';
import 'dart:async';

/// Estados posibles del progreso de una lección.
enum LessonProgressStatus {
  notStarted,
  inProgress,
  mastered,
}

/// Resultado simple del progreso de una lección.
class LessonProgress {
  final int completedCount;
  final int totalCount;
  final LessonProgressStatus status;

  LessonProgress({
    required this.completedCount,
    required this.totalCount,
    required this.status,
  });
}

/// Servicio único que calcula progreso de lecciones.
///
/// Reglas estrictas (no variaciones):
/// - filtra resultados por lessonId e isCorrect == true
/// - cuenta itemIds únicos
/// - aplica reglas exactas para el estado
class LessonProgressService {
  Future<LessonProgress> evaluate(Lesson lesson) async {
    final allResults = await ActivityResultService.getActivityResults();

    final correctResults = allResults.where((r) =>
      r.lessonId == lesson.id && r.isCorrect
    ).toList();

    final completedItemIds = <String>{};
    for (final r in correctResults) {
      completedItemIds.add(r.itemId);
    }

    final completedCount = completedItemIds.length;
    final totalCount = lesson.items.length;

    final status = completedCount == 0
        ? LessonProgressStatus.notStarted
        : (completedCount < totalCount
            ? LessonProgressStatus.inProgress
            : LessonProgressStatus.mastered);

    return LessonProgress(
      completedCount: completedCount,
      totalCount: totalCount,
      status: status,
    );
  }
}
