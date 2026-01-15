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
  Lesson(
    id: 'family_1',
    title: 'Familia',
    question: '¿Qué miembro de la familia es este?',
    items: [
      LessonItem(
        id: 'mother',
        title: 'Mother',
        stimulusImageAsset: 'assets/images/family/mother.jpg',
        options: ['mother', 'father', 'sister'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'father',
        title: 'Father',
        stimulusImageAsset: 'assets/images/family/father.jpg',
        options: ['father', 'mother', 'brother'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'brother',
        title: 'Brother',
        stimulusImageAsset: 'assets/images/family/brother.jpg',
        options: ['brother', 'sister', 'father'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'sister',
        title: 'Sister',
        stimulusImageAsset: 'assets/images/family/sister.jpg',
        options: ['sister', 'brother', 'mother'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'grandfather',
        title: 'Grandfather',
        stimulusImageAsset: 'assets/images/family/grandfather.jpg',
        options: ['grandfather', 'grandmother', 'father'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'grandmother',
        title: 'Grandmother',
        stimulusImageAsset: 'assets/images/family/grandmother.jpg',
        options: ['grandmother', 'grandfather', 'mother'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'family',
        title: 'Family',
        stimulusImageAsset: 'assets/images/family/family.jpg',
        options: ['family', 'father', 'mother'],
        correctAnswerIndex: 0,
      ),
    ],
    exercises: const [
      LessonExercise(type: ExerciseType.multipleChoice),
      LessonExercise(type: ExerciseType.matching),
    ],
  ),
  Lesson(
    id: 'numbers',
    title: 'Números',
    question: '¿Qué número es este?',
    items: [
      LessonItem(
        id: 'one',
        title: 'One',
        stimulusImageAsset: 'assets/images/numbers/one.jpg',
        options: ['one', 'two', 'three'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'two',
        title: 'Two',
        stimulusImageAsset: 'assets/images/numbers/two.jpg',
        options: ['two', 'one', 'four'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'three',
        title: 'Three',
        stimulusImageAsset: 'assets/images/numbers/three.jpg',
        options: ['three', 'two', 'five'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'four',
        title: 'Four',
        stimulusImageAsset: 'assets/images/numbers/four.jpg',
        options: ['four', 'three', 'six'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'five',
        title: 'Five',
        stimulusImageAsset: 'assets/images/numbers/five.jpg',
        options: ['five', 'four', 'seven'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'six',
        title: 'Six',
        stimulusImageAsset: 'assets/images/numbers/six.jpg',
        options: ['six', 'five', 'eight'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'seven',
        title: 'Seven',
        stimulusImageAsset: 'assets/images/numbers/seven.jpg',
        options: ['seven', 'six', 'nine'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'eight',
        title: 'Eight',
        stimulusImageAsset: 'assets/images/numbers/eight.jpg',
        options: ['eight', 'seven', 'ten'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'nine',
        title: 'Nine',
        stimulusImageAsset: 'assets/images/numbers/nine.jpg',
        options: ['nine', 'eight', 'ten'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'ten',
        title: 'Ten',
        stimulusImageAsset: 'assets/images/numbers/ten.jpg',
        options: ['ten', 'nine', 'eight'],
        correctAnswerIndex: 0,
      ),
    ],
    exercises: const [
      LessonExercise(type: ExerciseType.multipleChoice),
      LessonExercise(type: ExerciseType.matching),
    ],
  ),
  Lesson(
    id: 'body_parts',
    title: 'Partes del cuerpo',
    question: '¿Qué parte del cuerpo es esta?',
    items: [
      LessonItem(
        id: 'head',
        title: 'Head',
        stimulusImageAsset: 'assets/images/body_parts/head.jpg',
        options: ['head', 'hand', 'foot'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'eye',
        title: 'Eye',
        stimulusImageAsset: 'assets/images/body_parts/eye.jpg',
        options: ['eye', 'ear', 'nose'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'nose',
        title: 'Nose',
        stimulusImageAsset: 'assets/images/body_parts/nose.jpg',
        options: ['nose', 'mouth', 'eye'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'mouth',
        title: 'Mouth',
        stimulusImageAsset: 'assets/images/body_parts/mouth.jpg',
        options: ['mouth', 'nose', 'ear'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'hand',
        title: 'Hand',
        stimulusImageAsset: 'assets/images/body_parts/hand.jpg',
        options: ['hand', 'foot', 'arm'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'foot',
        title: 'Foot',
        stimulusImageAsset: 'assets/images/body_parts/foot.jpg',
        options: ['foot', 'hand', 'leg'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'arm',
        title: 'Arm',
        stimulusImageAsset: 'assets/images/body_parts/arm.jpg',
        options: ['arm', 'leg', 'hand'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'leg',
        title: 'Leg',
        stimulusImageAsset: 'assets/images/body_parts/leg.jpg',
        options: ['leg', 'arm', 'foot'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'ear',
        title: 'Ear',
        stimulusImageAsset: 'assets/images/body_parts/ear.jpg',
        options: ['ear', 'eye', 'nose'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'hair',
        title: 'Hair',
        stimulusImageAsset: 'assets/images/body_parts/hair.jpg',
        options: ['hair', 'head', 'eye'],
        correctAnswerIndex: 0,
      ),
    ],
    exercises: const [
      LessonExercise(type: ExerciseType.multipleChoice),
      LessonExercise(type: ExerciseType.matching),
    ],
  ),
  Lesson(
    id: 'clothes',
    title: 'Ropa',
    question: '¿Qué prenda es esta?',
    items: [
      LessonItem(
        id: 'shirt',
        title: 'Shirt',
        stimulusImageAsset: 'assets/images/clothes/shirt.jpg',
        options: ['shirt', 'pants', 'dress'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'pants',
        title: 'Pants',
        stimulusImageAsset: 'assets/images/clothes/pants.jpg',
        options: ['pants', 'shirt', 'shoes'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'dress',
        title: 'Dress',
        stimulusImageAsset: 'assets/images/clothes/dress.jpg',
        options: ['dress', 'shirt', 'skirt'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'shoes',
        title: 'Shoes',
        stimulusImageAsset: 'assets/images/clothes/shoes.jpg',
        options: ['shoes', 'socks', 'hat'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'hat',
        title: 'Hat',
        stimulusImageAsset: 'assets/images/clothes/hat.jpg',
        options: ['hat', 'cap', 'shoes'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'socks',
        title: 'Socks',
        stimulusImageAsset: 'assets/images/clothes/socks.jpg',
        options: ['socks', 'shoes', 'pants'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'jacket',
        title: 'Jacket',
        stimulusImageAsset: 'assets/images/clothes/jacket.jpg',
        options: ['jacket', 'shirt', 'coat'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'skirt',
        title: 'Skirt',
        stimulusImageAsset: 'assets/images/clothes/skirt.jpg',
        options: ['skirt', 'dress', 'pants'],
        correctAnswerIndex: 0,
      ),
    ],
    exercises: const [
      LessonExercise(type: ExerciseType.multipleChoice),
      LessonExercise(type: ExerciseType.matching),
    ],
  ),
  Lesson(
    id: 'food_drinks',
    title: 'Comida y bebidas',
    question: '¿Qué es esto?',
    items: [
      LessonItem(
        id: 'bread',
        title: 'Bread',
        stimulusImageAsset: 'assets/images/food/bread.jpg',
        options: ['bread', 'cake', 'cookie'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'milk',
        title: 'Milk',
        stimulusImageAsset: 'assets/images/food/milk.jpg',
        options: ['milk', 'water', 'juice'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'water',
        title: 'Water',
        stimulusImageAsset: 'assets/images/food/water.jpg',
        options: ['water', 'milk', 'juice'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'egg',
        title: 'Egg',
        stimulusImageAsset: 'assets/images/food/egg.jpg',
        options: ['egg', 'bread', 'cheese'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'cheese',
        title: 'Cheese',
        stimulusImageAsset: 'assets/images/food/cheese.jpg',
        options: ['cheese', 'egg', 'butter'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'rice',
        title: 'Rice',
        stimulusImageAsset: 'assets/images/food/rice.jpg',
        options: ['rice', 'bread', 'pasta'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'juice',
        title: 'Juice',
        stimulusImageAsset: 'assets/images/food/juice.jpg',
        options: ['juice', 'water', 'milk'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'cake',
        title: 'Cake',
        stimulusImageAsset: 'assets/images/food/cake.jpg',
        options: ['cake', 'cookie', 'bread'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'cookie',
        title: 'Cookie',
        stimulusImageAsset: 'assets/images/food/cookie.jpg',
        options: ['cookie', 'cake', 'bread'],
        correctAnswerIndex: 0,
      ),
    ],
    exercises: const [
      LessonExercise(type: ExerciseType.multipleChoice),
      LessonExercise(type: ExerciseType.matching),
    ],
  ),
  Lesson(
    id: 'actions',
    title: 'Acciones',
    question: '¿Qué acción es esta?',
    items: [
      LessonItem(
        id: 'run',
        title: 'Run',
        stimulusImageAsset: 'assets/images/actions/run.jpg',
        options: ['run', 'walk', 'jump'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'jump',
        title: 'Jump',
        stimulusImageAsset: 'assets/images/actions/jump.jpg',
        options: ['jump', 'run', 'sit'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'eat',
        title: 'Eat',
        stimulusImageAsset: 'assets/images/actions/eat.jpg',
        options: ['eat', 'drink', 'sleep'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'sleep',
        title: 'Sleep',
        stimulusImageAsset: 'assets/images/actions/sleep.jpg',
        options: ['sleep', 'eat', 'wake'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'walk',
        title: 'Walk',
        stimulusImageAsset: 'assets/images/actions/walk.jpg',
        options: ['walk', 'run', 'stand'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'sit',
        title: 'Sit',
        stimulusImageAsset: 'assets/images/actions/sit.jpg',
        options: ['sit', 'stand', 'jump'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'stand',
        title: 'Stand',
        stimulusImageAsset: 'assets/images/actions/stand.jpg',
        options: ['stand', 'sit', 'walk'],
        correctAnswerIndex: 0,
      ),
      LessonItem(
        id: 'drink',
        title: 'Drink',
        stimulusImageAsset: 'assets/images/actions/drink.jpg',
        options: ['drink', 'eat', 'run'],
        correctAnswerIndex: 0,
      ),
    ],
    exercises: const [
      LessonExercise(type: ExerciseType.multipleChoice),
      LessonExercise(type: ExerciseType.matching),
    ],
  ),
];

/// Niveles educativos agrupando lecciones por dificultad.
final List<LessonLevel> lessonLevels = [
  LessonLevel(
    id: 'beginner',
    title: 'Principiante',
    lessons: [
      lessonsList[0], // Colors
      lessonsList[1], // Fruits
      lessonsList[2], // Animals
      lessonsList[3], // Classroom Objects
      lessonsList[4], // Family
      lessonsList[5], // Numbers
      lessonsList[6], // Body Parts
      lessonsList[7], // Clothes
      lessonsList[8], // Food and Drinks
      lessonsList[9], // Actions
    ],
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

/// ============================================================================
/// LISTA DE IMÁGENES JPG REQUERIDAS
/// ============================================================================
/// 
/// Total: 76 imágenes JPG (Colors usa stimulusColor, no imágenes)
/// 
/// FRUITS (8): apple.jpg, banana.jpg, orange.jpg, strawberry.jpg, grapes.jpg, 
///             pineapple.jpg, watermelon.jpg, pear.jpg
/// ANIMALS (8): dog.jpg, cat.jpg, cow.jpg, chicken.jpg, horse.jpg, elephant.jpg, 
///              bird.jpg, fish.jpg
/// CLASSROOM (8): book.jpg, pencil.jpg, chair.jpg, table.jpg, notebook.jpg, 
///                backpack.jpg, eraser.jpg, ruler.jpg
/// FAMILY (7): mother.jpg, father.jpg, brother.jpg, sister.jpg, grandfather.jpg, 
///             grandmother.jpg, family.jpg
/// NUMBERS (10): one.jpg, two.jpg, three.jpg, four.jpg, five.jpg, six.jpg, 
///               seven.jpg, eight.jpg, nine.jpg, ten.jpg
/// BODY_PARTS (10): head.jpg, eye.jpg, nose.jpg, mouth.jpg, hand.jpg, foot.jpg, 
///                  arm.jpg, leg.jpg, ear.jpg, hair.jpg
/// CLOTHES (8): shirt.jpg, pants.jpg, dress.jpg, shoes.jpg, hat.jpg, socks.jpg, 
///              jacket.jpg, skirt.jpg
/// FOOD_DRINKS (9): bread.jpg, milk.jpg, water.jpg, egg.jpg, cheese.jpg, rice.jpg, 
///                  juice.jpg, cake.jpg, cookie.jpg
/// ACTIONS (8): run.jpg, jump.jpg, eat.jpg, sleep.jpg, walk.jpg, sit.jpg, 
///              stand.jpg, drink.jpg
/// 
/// Estructura de carpetas:
/// assets/images/
/// ├── colors/          (no se usan imágenes, solo stimulusColor)
/// ├── fruits/          (8 imágenes)
/// ├── animals/         (8 imágenes)
/// ├── classroom/       (8 imágenes)
/// ├── family/          (7 imágenes)
/// ├── numbers/         (10 imágenes)
/// ├── body_parts/      (10 imágenes)
/// ├── clothes/         (8 imágenes)
/// ├── food/            (9 imágenes)
/// └── actions/         (8 imágenes)
/// ============================================================================
