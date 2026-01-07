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
    question: '¿Qué color es este?',
    items: [
      LessonItem(
        id: 'red',
        title: 'Red',
        stimulusColor: Colors.red,
        options: ['red', 'blue', 'green'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'blue',
        title: 'Blue',
        stimulusColor: Colors.blue,
        options: ['red', 'blue', 'green'],
        correctAnswerIndex: 1,
      ),
      LessonItem(
        id: 'green',
        title: 'Green',
        stimulusColor: Colors.green,
        options: ['green', 'yellow', 'purple'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'yellow',
        title: 'Yellow',
        stimulusColor: Colors.yellow,
        options: ['yellow', 'purple', 'pink'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'black',
        title: 'Black',
        stimulusColor: Colors.black,
        options: ['black', 'white', 'gray'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'white',
        title: 'White',
        stimulusColor: Colors.white,
        options: ['white', 'black', 'gray'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'orange',
        title: 'Orange',
        stimulusColor: Colors.orange,
        options: ['purple', 'orange', 'brown'],
        correctAnswerIndex: 1,
      ),
      LessonItem(
        id: 'purple',
        title: 'Purple',
        stimulusColor: Colors.purple,
        options: ['orange', 'purple', 'pink'],
        correctAnswerIndex: 1,
      ),
      LessonItem(
        id: 'pink',
        title: 'Pink',
        stimulusColor: Colors.pink,
        options: ['blue', 'pink', 'red'],
        correctAnswerIndex: 1,
      ),
      LessonItem(
        id: 'brown',
        title: 'Brown',
        stimulusColor: Colors.brown,
        options: ['brown', 'orange', 'black'],
        correctAnswerIndex: 0,
      ),
    ],
  ),
  Lesson(
    id: 'fruits',
    title: 'Frutas',
    question: '¿Qué fruta es esta?',
    items: [
      LessonItem(
        id: 'apple',
        title: 'Apple',
        stimulusImageAsset: 'assets/images/fruits/apple.jpg',
        options: ['apple', 'banana', 'orange'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'banana',
        title: 'Banana',
        stimulusImageAsset: 'assets/images/fruits/banana.jpg',
        options: ['orange', 'banana', 'grape'],
        correctAnswerIndex: 1,
      ),
      LessonItem(
        id: 'orange_fruit',
        title: 'Orange',
        stimulusImageAsset: 'assets/images/fruits/orange.jpg',
        options: ['apple', 'grape', 'orange'],
        correctAnswerIndex: 2,
      ),
      LessonItem(
        id: 'strawberry',
        title: 'Strawberry',
        stimulusImageAsset: 'assets/images/fruits/strawberry.jpg',
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
