import '../models/lesson.dart';

/// Datos offline de lecciones educativas para la app de inglés.
/// Lecciones tipo: selección múltiple.
final List<Lesson> lessonsList = [
  Lesson(
    id: 'colors_1',
    question: 'What color is this?',
    options: ['Red', 'Blue', 'Green'],
    correctAnswerIndex: 0,
  ),
];
