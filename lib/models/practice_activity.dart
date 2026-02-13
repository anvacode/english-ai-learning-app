/// Tipos de actividades de práctica disponibles
enum PracticeActivityType {
  spelling,
  listening,
  speedMatch,
  wordScramble,
  fillBlanks,
  pictureMemory,
  trueFalse,
  pronunciation,
}

/// Modelo base para actividades de práctica
class PracticeActivity {
  final String id;
  final String lessonId;
  final PracticeActivityType type;
  final String title;
  final String description;
  final String iconEmoji;
  final int totalExercises;
  final bool isUnlocked;
  final int requiredStars;
  final List<String> requiredLessons;

  const PracticeActivity({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.totalExercises,
    this.isUnlocked = false,
    this.requiredStars = 0,
    this.requiredLessons = const [],
  });

  /// Obtiene el nombre legible del tipo de actividad
  String get typeName {
    switch (type) {
      case PracticeActivityType.spelling:
        return 'Spelling Challenge';
      case PracticeActivityType.listening:
        return 'Listening Quiz';
      case PracticeActivityType.speedMatch:
        return 'Speed Match';
      case PracticeActivityType.wordScramble:
        return 'Word Scramble';
      case PracticeActivityType.fillBlanks:
        return 'Fill the Blanks';
      case PracticeActivityType.pictureMemory:
        return 'Picture Memory';
      case PracticeActivityType.trueFalse:
        return 'True or False';
      case PracticeActivityType.pronunciation:
        return 'Pronunciation Practice';
    }
  }

  /// Obtiene el color del tipo de actividad
  int get color {
    switch (type) {
      case PracticeActivityType.spelling:
        return 0xFF2196F3; // Blue
      case PracticeActivityType.listening:
        return 0xFF9C27B0; // Purple
      case PracticeActivityType.speedMatch:
        return 0xFFF44336; // Red
      case PracticeActivityType.wordScramble:
        return 0xFF4CAF50; // Green
      case PracticeActivityType.fillBlanks:
        return 0xFFFF9800; // Orange
      case PracticeActivityType.pictureMemory:
        return 0xFF00BCD4; // Cyan
      case PracticeActivityType.trueFalse:
        return 0xFFE91E63; // Pink
      case PracticeActivityType.pronunciation:
        return 0xFF8BC34A; // Light Green
    }
  }

  PracticeActivity copyWith({
    String? id,
    String? lessonId,
    PracticeActivityType? type,
    String? title,
    String? description,
    String? iconEmoji,
    int? totalExercises,
    bool? isUnlocked,
    int? requiredStars,
    List<String>? requiredLessons,
  }) {
    return PracticeActivity(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      totalExercises: totalExercises ?? this.totalExercises,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      requiredStars: requiredStars ?? this.requiredStars,
      requiredLessons: requiredLessons ?? this.requiredLessons,
    );
  }
}

/// Progreso del usuario en una actividad de práctica
class PracticeProgress {
  final String activityId;
  final int completedExercises;
  final int totalExercises;
  final int starsEarned;
  final int bestScore;
  final DateTime? lastPlayed;
  final int timesPlayed;

  const PracticeProgress({
    required this.activityId,
    this.completedExercises = 0,
    required this.totalExercises,
    this.starsEarned = 0,
    this.bestScore = 0,
    this.lastPlayed,
    this.timesPlayed = 0,
  });

  /// Porcentaje de completitud (0-100)
  double get completionPercentage {
    if (totalExercises == 0) return 0;
    return (completedExercises / totalExercises * 100).clamp(0, 100);
  }

  /// Si la actividad está completada
  bool get isCompleted => completedExercises >= totalExercises;

  /// Calificación en estrellas (0-3)
  int get starRating {
    if (!isCompleted) return 0;
    final percentage = completionPercentage;
    if (percentage >= 90) return 3;
    if (percentage >= 70) return 2;
    return 1;
  }

  PracticeProgress copyWith({
    String? activityId,
    int? completedExercises,
    int? totalExercises,
    int? starsEarned,
    int? bestScore,
    DateTime? lastPlayed,
    int? timesPlayed,
  }) {
    return PracticeProgress(
      activityId: activityId ?? this.activityId,
      completedExercises: completedExercises ?? this.completedExercises,
      totalExercises: totalExercises ?? this.totalExercises,
      starsEarned: starsEarned ?? this.starsEarned,
      bestScore: bestScore ?? this.bestScore,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      timesPlayed: timesPlayed ?? this.timesPlayed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'completedExercises': completedExercises,
      'totalExercises': totalExercises,
      'starsEarned': starsEarned,
      'bestScore': bestScore,
      'lastPlayed': lastPlayed?.toIso8601String(),
      'timesPlayed': timesPlayed,
    };
  }

  factory PracticeProgress.fromJson(Map<String, dynamic> json) {
    return PracticeProgress(
      activityId: json['activityId'] as String,
      completedExercises: json['completedExercises'] as int? ?? 0,
      totalExercises: json['totalExercises'] as int,
      starsEarned: json['starsEarned'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'] as String)
          : null,
      timesPlayed: json['timesPlayed'] as int? ?? 0,
    );
  }
}
