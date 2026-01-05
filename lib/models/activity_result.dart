class ActivityResult {
  final String lessonId;
  final bool isCorrect;
  final DateTime timestamp;

  ActivityResult({
    required this.lessonId,
    required this.isCorrect,
    required this.timestamp,
  });

  /// Convierte ActivityResult a JSON para persistencia.
  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'isCorrect': isCorrect,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Crea una instancia de ActivityResult desde JSON.
  factory ActivityResult.fromJson(Map<String, dynamic> json) {
    return ActivityResult(
      lessonId: json['lessonId'] as String,
      isCorrect: json['isCorrect'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
