class Student {
  final String id;
  int level;
  int points;

  Student({
    required this.id,
    this.level = 1,
    this.points = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'level': level,
    'points': points,
  };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'] as String,
    level: json['level'] as int? ?? 1,
    points: json['points'] as int? ?? 0,
  );
}
