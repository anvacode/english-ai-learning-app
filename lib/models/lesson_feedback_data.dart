import '../logic/activity_result_service.dart';
import '../utils/safe_math.dart';

/// Enum for mastery levels based on accuracy
enum MasteryLevel {
  mastered,           // >= 80%
  inProgress,         // 50-79%
  needsReinforcement, // < 50%
}

/// Data class containing lesson feedback information
class LessonFeedbackData {
  final String lessonId;
  final int totalAttempts;
  final int correctAttempts;
  final int accuracyPercentage;
  final MasteryLevel masteryStatus;

  LessonFeedbackData({
    required this.lessonId,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.accuracyPercentage,
    required this.masteryStatus,
  });

  /// Factory constructor that calculates feedback data from activity results
  static Future<LessonFeedbackData> fromLesson(String lessonId) async {
    final allResults = await ActivityResultService.getActivityResults();
    
    // Filter results for this lesson
    final lessonResults = allResults.where((r) => r.lessonId == lessonId).toList();
    
    // Count total and correct attempts
    final totalAttempts = lessonResults.length;
    final correctAttempts = lessonResults.where((r) => r.isCorrect).length;
    
    // Calculate accuracy percentage using defensive-by-design safe functions
    // This ensures no NaN/Infinity can ever reach the UI
    final accuracyPercentage = safeRound(safePercentage(correctAttempts, totalAttempts));
    
    // Determine mastery level
    final masteryStatus = _getMasteryLevel(accuracyPercentage);
    
    return LessonFeedbackData(
      lessonId: lessonId,
      totalAttempts: totalAttempts,
      correctAttempts: correctAttempts,
      accuracyPercentage: accuracyPercentage,
      masteryStatus: masteryStatus,
    );
  }

  /// Determine mastery level based on accuracy
  static MasteryLevel _getMasteryLevel(int accuracyPercentage) {
    if (accuracyPercentage >= 80) {
      return MasteryLevel.mastered;
    } else if (accuracyPercentage >= 50) {
      return MasteryLevel.inProgress;
    } else {
      return MasteryLevel.needsReinforcement;
    }
  }

  /// Get the Spanish label for mastery status
  String getMasteryLabel() {
    switch (masteryStatus) {
      case MasteryLevel.mastered:
        return 'Dominado';
      case MasteryLevel.inProgress:
        return 'En progreso';
      case MasteryLevel.needsReinforcement:
        return 'Requiere refuerzo';
    }
  }

  /// Get the emoji icon for mastery status
  String getMasteryIcon() {
    switch (masteryStatus) {
      case MasteryLevel.mastered:
        return '🏆'; // Trophy
      case MasteryLevel.inProgress:
        return '📈'; // Chart going up
      case MasteryLevel.needsReinforcement:
        return '💪'; // Flexed biceps (encouragement)
    }
  }

  /// Get a pedagogical message based on mastery status
  String getPedagogicalMessage() {
    switch (masteryStatus) {
      case MasteryLevel.mastered:
        return '¡Excelente trabajo! Has dominado este tema.';
      case MasteryLevel.inProgress:
        return 'Buen progreso. Sigue practicando para mejorar.';
      case MasteryLevel.needsReinforcement:
        return 'Necesitas más práctica. Intenta de nuevo.';
    }
  }
}
