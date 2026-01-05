import '../logic/activity_result_service.dart';

/// Estados posibles del dominio de una lección.
enum LessonMasteryStatus {
  /// La lección no ha sido iniciada (sin resultados).
  notStarted,

  /// La lección ha sido iniciada pero no alcanza dominio.
  inProgress,

  /// La lección ha sido dominada (3 respuestas correctas consecutivas).
  mastered,
}

/// Evaluador de dominio de lecciones basado en consistencia de respuestas.
/// 
/// Criterio: Una lección se considera dominada cuando se obtienen
/// 3 respuestas correctas consecutivas para esa lección.
class MasteryEvaluator {
  /// Evalúa el estado de dominio de una lección.
  /// 
  /// [lessonId] identificador único de la lección.
  /// 
  /// Retorna:
  /// - [LessonMasteryStatus.notStarted] si no hay resultados para la lección
  /// - [LessonMasteryStatus.mastered] si hay 3 respuestas correctas consecutivas
  /// - [LessonMasteryStatus.inProgress] si hay resultados pero no alcanza dominio
  Future<LessonMasteryStatus> evaluateLesson(String lessonId) async {
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

    // Ordena por timestamp (cronológico) para evaluar en orden
    lessonResults.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Evaluar respuestas consecutivas correctas
    int consecutiveCorrect = 0;

    for (final result in lessonResults) {
      if (result.isCorrect) {
        consecutiveCorrect++;

        // Si alcanza 3 correctas consecutivas, está dominada
        if (consecutiveCorrect >= 3) {
          return LessonMasteryStatus.mastered;
        }
      } else {
        // Si hay una respuesta incorrecta, reinicia el contador
        consecutiveCorrect = 0;
      }
    }

    // Hay resultados pero no alcanza dominio
    return LessonMasteryStatus.inProgress;
  }
}
