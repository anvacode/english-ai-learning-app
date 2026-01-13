import '../logic/activity_result_service.dart';
import '../logic/lesson_completion_service.dart';

/// Estados posibles del dominio de una lección.
enum LessonMasteryStatus {
  /// La lección no ha sido iniciada (sin resultados).
  notStarted,

  /// La lección ha sido iniciada pero no fue dominada (attempted but not perfect).
  inProgress,

  /// La lección ha sido dominada (100% correct in a single attempt).
  mastered,
}

/// Evaluador de dominio de lecciones basado en LessonCompletion records.
/// 
/// IMPORTANT: Lesson mastery is determined by the presence of a LessonCompletion record,
/// NOT by analyzing ActivityResult data.
/// 
/// State logic:
/// - mastered: LessonCompletion exists for this lesson
/// - inProgress: No LessonCompletion, but at least one ActivityResult exists
/// - notStarted: No LessonCompletion and no ActivityResult
class MasteryEvaluator {
  /// Evalúa el estado de dominio de una lección.
  /// 
  /// [lessonId] identificador único de la lección.
  /// 
  /// Retorna:
  /// - [LessonMasteryStatus.mastered] si LessonCompletion existe
  /// - [LessonMasteryStatus.inProgress] si hay ActivityResults pero no LessonCompletion
  /// - [LessonMasteryStatus.notStarted] si no hay registro alguno
  Future<LessonMasteryStatus> evaluateLesson(String lessonId) async {
    // Check 1: Is this lesson completed (mastered)?
    final isCompleted = await LessonCompletionService.isLessonCompleted(lessonId);
    if (isCompleted) {
      return LessonMasteryStatus.mastered;
    }

    // Check 2: Has this lesson been attempted?
    final allResults = await ActivityResultService.getActivityResults();
    final lessonResults = allResults
        .where((result) => result.lessonId == lessonId)
        .toList();

    if (lessonResults.isEmpty) {
      return LessonMasteryStatus.notStarted;
    }

    // Has ActivityResults but no LessonCompletion = in progress
    return LessonMasteryStatus.inProgress;
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
