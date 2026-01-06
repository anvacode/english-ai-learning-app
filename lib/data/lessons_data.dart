import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../models/lesson_item.dart';
import '../models/lesson_category.dart';
import '../models/lesson_level.dart';

/// Datos offline de lecciones educativas para la app de inglés.
/// Lecciones tipo: asociación visual + selección múltiple.
final List<Lesson> lessonsList = [
  Lesson(
    id: 'colors',
    title: 'Colores',
    question: 'What color is this?',
    options: ['Red', 'Blue', 'Green'],
    correctAnswerIndex: 0,
    items: [
      LessonItem(
        title: 'Red',
        stimulusColor: Colors.red,
        options: ['Red', 'Blue', 'Green'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        title: 'Blue',
        stimulusColor: Colors.blue,
        options: ['Red', 'Blue', 'Green'],
        correctAnswerIndex: 1,
      ),
      LessonItem(
        title: 'Green',
        stimulusColor: Colors.green,
        options: ['Red', 'Blue', 'Green'],
        correctAnswerIndex: 2,
      ),
      LessonItem(
        title: 'Yellow',
        stimulusColor: Colors.yellow,
        options: ['Yellow', 'Purple', 'Pink'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        title: 'Orange',
        stimulusColor: Colors.orange,
        options: ['Purple', 'Orange', 'Brown'],
        correctAnswerIndex: 1,
      ),
    ],
  ),
  Lesson(
    id: 'fruits',
    title: 'Frutas',
    question: '¿Qué fruta es esta?',
    options: ['apple', 'banana', 'orange', 'grape'],
    correctAnswerIndex: 0,
    items: [
      LessonItem(
        title: 'Apple',
        stimulusImageAsset: 'assets/images/fruits/apple.jpg',
        stimulusColor: null,
        options: ['apple', 'banana', 'orange'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        title: 'Banana',
        stimulusImageAsset: 'assets/images/fruits/banana.jpg',
        stimulusColor: null,
        options: ['orange', 'banana', 'grape'],
        correctAnswerIndex: 1,
      ),
      LessonItem(
        title: 'Orange',
        stimulusImageAsset: 'assets/images/fruits/orange.jpg',
        stimulusColor: null,
        options: ['apple', 'grape', 'orange'],
        correctAnswerIndex: 2,
      ),
      LessonItem(
        title: 'Strawberry',
        stimulusImageAsset: 'assets/images/fruits/strawberry.jpg',
        stimulusColor: null,
        options: ['strawberry', 'banana', 'apple'],
        correctAnswerIndex: 0,
      ),
    ],
  ),
];

/// Niveles educativos agrupando lecciones por dificultad.
final List<LessonLevel> lessonLevels = [
  LessonLevel(
    id: 'beginner',
    title: 'Principiante',
    lessons: [lessonsList[0], lessonsList[1]], // Colors and Fruits lessons
  ),
  LessonLevel(
    id: 'intermediate',
    title: 'Intermedio',
    lessons: [],
  ),
  LessonLevel(
    id: 'advanced',
    title: 'Avanzado',
    lessons: [],
  ),
];

/// Categorías de lecciones agrupadas temáticamente.
final List<LessonCategory> lessonCategories = [
  LessonCategory(
    id: 'colors',
    title: 'Colors',
    description: 'Learn English color names through visual association',
    lessons: lessonsList,
  ),
];
