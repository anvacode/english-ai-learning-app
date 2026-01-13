import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../models/lesson_exercise.dart';
import '../models/matching_item.dart';
import 'lesson_screen.dart';
import 'matching_exercise_screen.dart';

class LessonFlowScreen extends StatefulWidget {
  final Lesson lesson;
  final List<LessonExercise> exercises;

  const LessonFlowScreen({
    super.key,
    required this.lesson,
    required this.exercises,
  });

  @override
  State<LessonFlowScreen> createState() => _LessonFlowScreenState();
}

class _LessonFlowScreenState extends State<LessonFlowScreen> {
  late int _currentExerciseIndex;

  @override
  void initState() {
    super.initState();
    _currentExerciseIndex = 0;
  }

  void _onExerciseComplete() {
    // Move to next exercise
    if (_currentExerciseIndex < widget.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
    } else {
      // All exercises complete - show success and return
      _onLessonComplete();
    }
  }

  void _onLessonComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Lección Completada!'),
        content: const Text('Felicidades por completar todos los ejercicios.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return to lessons with true flag
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercises[_currentExerciseIndex];
    final exerciseCount = widget.exercises.length;
    
    // Calculate progress offset and scale based on current exercise
    // If there are 2 exercises: MC is 0.0-0.5, Matching is 0.5-1.0
    final progressScale = 1.0 / exerciseCount;
    final progressOffset = _currentExerciseIndex * progressScale;

    // Build the appropriate exercise screen based on type
    Widget exerciseScreen;
    switch (exercise.type) {
      case ExerciseType.multipleChoice:
        exerciseScreen = _MultipleChoiceExerciseWrapper(
          key: ValueKey('mc-$_currentExerciseIndex'),
          lesson: widget.lesson,
          onComplete: _onExerciseComplete,
          progressOffset: progressOffset,
          progressScale: progressScale,
        );
        break;

      case ExerciseType.matching:
        exerciseScreen = _MatchingExerciseWrapper(
          key: ValueKey('matching-$_currentExerciseIndex'),
          lesson: widget.lesson,
          onComplete: _onExerciseComplete,
          progressOffset: progressOffset,
          progressScale: progressScale,
        );
        break;
    }

    return Scaffold(
      body: exerciseScreen,
    );
  }
}

/// Wrapper for multiple choice exercise within the flow
class _MultipleChoiceExerciseWrapper extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback onComplete;
  final double progressOffset;
  final double progressScale;

  const _MultipleChoiceExerciseWrapper({
    super.key,
    required this.lesson,
    required this.onComplete,
    required this.progressOffset,
    required this.progressScale,
  });

  @override
  State<_MultipleChoiceExerciseWrapper> createState() =>
      _MultipleChoiceExerciseWrapperState();
}

class _MultipleChoiceExerciseWrapperState
    extends State<_MultipleChoiceExerciseWrapper> {
  @override
  Widget build(BuildContext context) {
    return LessonScreen(
      key: UniqueKey(),
      lesson: widget.lesson,
      onExerciseCompleted: widget.onComplete,
      progressOffset: widget.progressOffset,
      progressScale: widget.progressScale,
    );
  }
}

/// Wrapper for matching exercise within the flow
class _MatchingExerciseWrapper extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback onComplete;
  final double progressOffset;
  final double progressScale;

  const _MatchingExerciseWrapper({
    super.key,
    required this.lesson,
    required this.onComplete,
    required this.progressOffset,
    required this.progressScale,
  });

  @override
  State<_MatchingExerciseWrapper> createState() =>
      _MatchingExerciseWrapperState();
}

class _MatchingExerciseWrapperState extends State<_MatchingExerciseWrapper> {
  @override
  Widget build(BuildContext context) {
    // Build matching items for animals
    final matchingItems = _buildMatchingItems(widget.lesson.id);

    return MatchingExerciseScreen(
      lessonId: widget.lesson.id,
      title: widget.lesson.title,
      items: matchingItems,
      onComplete: widget.onComplete,
      progressOffset: widget.progressOffset,
      progressScale: widget.progressScale,
    );
  }

  List<MatchingItem> _buildMatchingItems(String lessonId) {
    // Customize matching items based on lesson
    if (lessonId == 'animals') {
      return [
        const MatchingItem(
          id: 'dog',
          imagePath: 'assets/images/animals/dog.jpg',
          correctWord: 'dog',
          title: 'Perro',
        ),
        const MatchingItem(
          id: 'cat',
          imagePath: 'assets/images/animals/cat.jpg',
          correctWord: 'cat',
          title: 'Gato',
        ),
        const MatchingItem(
          id: 'cow',
          imagePath: 'assets/images/animals/cow.jpg',
          correctWord: 'cow',
          title: 'Vaca',
        ),
        const MatchingItem(
          id: 'chicken',
          imagePath: 'assets/images/animals/chicken.jpg',
          correctWord: 'chicken',
          title: 'Pollo',
        ),
        const MatchingItem(
          id: 'horse',
          imagePath: 'assets/images/animals/horse.jpg',
          correctWord: 'horse',
          title: 'Caballo',
        ),
        const MatchingItem(
          id: 'elephant',
          imagePath: 'assets/images/animals/elephant.jpg',
          correctWord: 'elephant',
          title: 'Elefante',
        ),
        const MatchingItem(
          id: 'bird',
          imagePath: 'assets/images/animals/bird.jpg',
          correctWord: 'bird',
          title: 'Pájaro',
        ),
        const MatchingItem(
          id: 'fish',
          imagePath: 'assets/images/animals/fish.jpg',
          correctWord: 'fish',
          title: 'Pez',
        ),
      ];
    } else if (lessonId == 'family_1') {
      return [
        const MatchingItem(
          id: 'mother',
          imagePath: 'assets/images/family/mother.jpg',
          correctWord: 'mother',
          title: 'Madre',
        ),
        const MatchingItem(
          id: 'father',
          imagePath: 'assets/images/family/father.jpg',
          correctWord: 'father',
          title: 'Padre',
        ),
        const MatchingItem(
          id: 'brother',
          imagePath: 'assets/images/family/brother.jpg',
          correctWord: 'brother',
          title: 'Hermano',
        ),
        const MatchingItem(
          id: 'sister',
          imagePath: 'assets/images/family/sister.jpg',
          correctWord: 'sister',
          title: 'Hermana',
        ),
        const MatchingItem(
          id: 'grandfather',
          imagePath: 'assets/images/family/grandfather.jpg',
          correctWord: 'grandfather',
          title: 'Abuelo',
        ),
        const MatchingItem(
          id: 'grandmother',
          imagePath: 'assets/images/family/grandmother.jpg',
          correctWord: 'grandmother',
          title: 'Abuela',
        ),
        const MatchingItem(
          id: 'family',
          imagePath: 'assets/images/family/family.jpg',
          correctWord: 'family',
          title: 'Familia',
        ),
      ];
    }
    // Default empty list for other lessons
    return [];
  }
}
