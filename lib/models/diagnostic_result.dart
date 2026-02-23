enum EnglishLevel { beginner, intermediate, advanced }

class DiagnosticResult {
  final String level;
  final int score;
  final int totalQuestions;
  final int basicCorrect;
  final int intermediateCorrect;
  final int advancedCorrect;
  final DateTime completedAt;

  const DiagnosticResult({
    required this.level,
    required this.score,
    required this.totalQuestions,
    required this.basicCorrect,
    required this.intermediateCorrect,
    required this.advancedCorrect,
    required this.completedAt,
  });

  double get percentage => (score / totalQuestions) * 100;

  String get levelDisplayName {
    switch (level) {
      case 'beginner':
        return 'Principiante';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      default:
        return 'No determinado';
    }
  }

  String get levelDescription {
    switch (level) {
      case 'beginner':
        return 'Tienes conocimientos básicos de inglés. Te recomendamos empezar con las lecciones fundamentales.';
      case 'intermediate':
        return 'Tienes una base sólida de inglés. Puedes avanzar con lecciones más desafiantes.';
      case 'advanced':
        return 'Tienes un excelente dominio del inglés. Te sugerimos contenido avanzado para perfeccionar.';
      default:
        return 'Completa la prueba para conocer tu nivel.';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'score': score,
      'totalQuestions': totalQuestions,
      'basicCorrect': basicCorrect,
      'intermediateCorrect': intermediateCorrect,
      'advancedCorrect': advancedCorrect,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory DiagnosticResult.fromJson(Map<String, dynamic> json) {
    return DiagnosticResult(
      level: json['level'] as String,
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      basicCorrect: json['basicCorrect'] as int,
      intermediateCorrect: json['intermediateCorrect'] as int,
      advancedCorrect: json['advancedCorrect'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }
}
