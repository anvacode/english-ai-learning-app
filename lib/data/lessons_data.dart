import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../models/lesson_item.dart';
import '../models/lesson_exercise.dart';
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
    exercises: const [
      LessonExercise(type: ExerciseType.multipleChoice),
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
        options: ['banana', 'apple', 'strawberry'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'orange',
        title: 'Orange',
        stimulusImageAsset: 'assets/images/fruits/orange.jpg',
        options: ['orange', 'apple', 'lemon'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'strawberry',
        title: 'Strawberry',
        stimulusImageAsset: 'assets/images/fruits/strawberry.jpg',
        options: ['strawberry', 'cherry', 'apple'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'grapes',
        title: 'Grapes',
        stimulusImageAsset: 'assets/images/fruits/grapes.jpg',
        options: ['grapes', 'blueberry', 'banana'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'pineapple',
        title: 'Pineapple',
        stimulusImageAsset: 'assets/images/fruits/pineapple.jpg',
        options: ['pineapple', 'banana', 'mango'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'watermelon',
        title: 'Watermelon',
        stimulusImageAsset: 'assets/images/fruits/watermelon.jpg',
        options: ['watermelon', 'apple', 'orange'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'pear',
        title: 'Pear',
        stimulusImageAsset: 'assets/images/fruits/pear.jpg',
        options: ['pear', 'apple', 'peach'],
        correctAnswerIndex: 0,
      ),
    ],
    exercises: const [
      LessonExercise(type: ExerciseType.multipleChoice),
    ],
  ),
  Lesson(
    id: 'animals',
    title: 'Animales',
    question: '¿Qué animal es este?',
    items: [
      LessonItem(
        id: 'dog',
        title: 'Dog',
        stimulusImageAsset: 'assets/images/animals/dog.jpg',
        options: ['dog', 'cat', 'horse'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'cat',
        title: 'Cat',
        stimulusImageAsset: 'assets/images/animals/cat.jpg',
        options: ['cat', 'dog', 'bird'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'cow',
        title: 'Cow',
        stimulusImageAsset: 'assets/images/animals/cow.jpg',
        options: ['cow', 'horse', 'pig'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'chicken',
        title: 'Chicken',
        stimulusImageAsset: 'assets/images/animals/chicken.jpg',
        options: ['chicken', 'duck', 'bird'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'horse',
        title: 'Horse',
        stimulusImageAsset: 'assets/images/animals/horse.jpg',
        options: ['horse', 'cow', 'donkey'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'elephant',
        title: 'Elephant',
        stimulusImageAsset: 'assets/images/animals/elephant.jpg',
        options: ['elephant', 'hippo', 'cow'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'bird',
        title: 'Bird',
        stimulusImageAsset: 'assets/images/animals/bird.jpg',
        options: ['bird', 'chicken', 'fish'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'fish',
        title: 'Fish',
        stimulusImageAsset: 'assets/images/animals/fish.jpg',
        options: ['fish', 'bird', 'snake'],
        correctAnswerIndex: 0,
      ),
    ],
    exercises: const [
      LessonExercise(type: ExerciseType.multipleChoice),
      LessonExercise(type: ExerciseType.matching),
    ],
  ),
  Lesson(
    id: 'classroom',
    title: 'Objetos del aula',
    question: '¿Qué objeto es este?',
    items: [
      LessonItem(
        id: 'book',
        title: 'Libro',
        stimulusImageAsset: 'assets/images/classroom/book.jpg',
        options: ['book', 'notebook', 'pencil'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'pencil',
        title: 'Lápiz',
        stimulusImageAsset: 'assets/images/classroom/pencil.jpg',
        options: ['pencil', 'eraser', 'ruler'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'chair',
        title: 'Silla',
        stimulusImageAsset: 'assets/images/classroom/chair.jpg',
        options: ['chair', 'table', 'backpack'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'table',
        title: 'Mesa',
        stimulusImageAsset: 'assets/images/classroom/table.jpg',
        options: ['table', 'chair', 'notebook'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'notebook',
        title: 'Cuaderno',
        stimulusImageAsset: 'assets/images/classroom/notebook.jpg',
        options: ['notebook', 'book', 'pencil'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'backpack',
        title: 'Mochila',
        stimulusImageAsset: 'assets/images/classroom/backpack.jpg',
        options: ['backpack', 'chair', 'table'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'eraser',
        title: 'Borrador',
        stimulusImageAsset: 'assets/images/classroom/eraser.jpg',
        options: ['eraser', 'pencil', 'ruler'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'ruler',
        title: 'Regla',
        stimulusImageAsset: 'assets/images/classroom/ruler.jpg',
        options: ['ruler', 'eraser', 'pencil'],
        correctAnswerIndex: 0,
      ),
    ],
    exercises: const [
      LessonExercise(type: ExerciseType.multipleChoice),
    ],
  ),
];

/// Niveles educativos agrupando lecciones por dificultad.
final List<LessonLevel> lessonLevels = [
  LessonLevel(
    id: 'beginner',
    title: 'Principiante',
    lessons: [lessonsList[0], lessonsList[1], lessonsList[2], lessonsList[3]], // Colors, Fruits, Animals, and Classroom Objects lessons
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
