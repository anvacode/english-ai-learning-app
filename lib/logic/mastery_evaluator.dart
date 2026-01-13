import '../logic/activity_result_service.dart';
import '../data/lessons_data.dart';

/// Estados posibles del dominio de una lección.
enum LessonMasteryStatus {
  /// La lección no ha sido iniciada (sin resultados).
  notStarted,

  /// La lección ha sido iniciada pero no alcanza dominio.
  inProgress,

  /// La lección ha sido dominada (80% accuracy AND all items completed at least once correctly).
  mastered,
}

/// Evaluador de dominio de lecciones basado en criterios de precisión.
/// 
/// Criterio: Una lección se considera dominada cuando:
/// 1. Todos los items han sido respondidos correctamente al menos una vez
/// 2. La precisión global es >= 80%
class MasteryEvaluator {
  /// Evalúa el estado de dominio de una lección.
  /// 
  /// [lessonId] identificador único de la lección.
  /// 
  /// Retorna:
  /// - [LessonMasteryStatus.notStarted] si no hay resultados para la lección
  /// - [LessonMasteryStatus.mastered] si todos los items completados y precisión >= 80%
  /// - [LessonMasteryStatus.inProgress] si hay resultados pero no alcanza dominio
  Future<LessonMasteryStatus> evaluateLesson(String lessonId) async {
    // Obtener la lección para acceder a los items
    final lesson = lessonsList.firstWhere(
      (l) => l.id == lessonId,
      orElse: () => throw Exception('Lesson not found: $lessonId'),
    );

    // Obtener todos los resultados
    final allResults = await ActivityResultService.getActivityResults();

    // Filtrar resultados por lessonId
    final lessonResults = allResults
        .where((result) => result.lessonId == lessonId)
        .toList();

    // Si no hay resultados, la lección no ha sido iniciada
    if (lessonResults.isEmpty) {
      return LessonMasteryStatus.notStarted;
    }

    // Check 1: All items must be answered at least once correctly
    final itemIds = lesson.items.map((item) => item.id).toSet();
    final completedIds = lessonResults
        .where((r) => r.isCorrect)
        .map((r) => r.itemId)
        .toSet();

    final allItemsCompleted = itemIds.every((id) => completedIds.contains(id));
    if (!allItemsCompleted) {
      return LessonMasteryStatus.inProgress;
    }

    // Check 2: Accuracy must be >= 80%
    final totalAttempts = lessonResults.length;
    final correctAttempts = lessonResults.where((r) => r.isCorrect).length;
    final accuracyPercentage = (correctAttempts * 100) ~/ totalAttempts;

    return accuracyPercentage >= 80
        ? LessonMasteryStatus.mastered
        : LessonMasteryStatus.inProgress;
  }

  /// Evalúa si todas las lecciones en una lista están dominadas.
  Future<bool> areAllLessonsMastered(List<String> lessonIds) async {
    if (lessonIds.isEmpty) return true;

    for (final lessonId in lessonIds) {
      final status = await evaluateLesson(lessonId);
      if (status != LessonMasteryStatus.mastered) {
        return false;
      }
    }
    return true;
  }
}
