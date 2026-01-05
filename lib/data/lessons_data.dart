import 'package:flutter/material.dart';
import '../models/lesson.dart';

/// Datos offline de lecciones educativas para la app de inglés.
/// Lecciones tipo: asociación visual + selección múltiple.
final List<Lesson> lessonsList = [
  Lesson(
    id: 'colors_1',
    question: 'What color is this?',
    options: ['Red', 'Blue', 'Green'],
    correctAnswerIndex: 0,
    stimulusColor: Colors.red,
  ),
];
