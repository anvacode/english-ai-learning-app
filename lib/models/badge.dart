/// Un badge que se desbloquea cuando una lección se domina.
class Badge {
  final String lessonId;
  final String title;
  final String icon; // Emoji unicode
  final bool unlocked; // Derived from lesson progress

  const Badge({
    required this.lessonId,
    required this.title,
    required this.icon,
    required this.unlocked,
  });

  @override
  String toString() => 'Badge($lessonId, $title, $icon, unlocked: $unlocked)';
}
