import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../models/activity_result.dart';
import '../models/matching_item.dart';
import '../logic/activity_result_service.dart';
import '../logic/lesson_progress_evaluator.dart';
import '../logic/badge_service.dart';
import '../logic/lesson_controller.dart';
import '../models/badge.dart' as achievement;
import 'matching_exercise_screen.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback? onExerciseCompleted; // Callback when this exercise completes

  const LessonScreen({
    super.key,
    required this.lesson,
    this.onExerciseCompleted,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  // Core state fields (single source of truth)
  int completedCount = 0;
  int totalCount = 0;
  LessonProgressStatus status = LessonProgressStatus.notStarted;
  int currentItemIndex = 0;

  // Completion flag to prevent looping
  bool _exerciseCompleted = false;

  // Temporary UI interaction state (reset per item)
  int? _selectedAnswerIndex;
  bool _answered = false;
  bool? _isCorrect;
  
  // Randomized options for current item
  late List<String> _randomizedOptions;
  late String _correctAnswerValue; // The correct answer as a string, not index
  
  // Badge state
  achievement.Badge? _badge;

  @override
  void initState() {
    super.initState();
    totalCount = widget.lesson.items.length;
    // Initialize LessonController with total questions for this exercise
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonController>().initializeLesson(totalCount);
    });
    _loadProgressAndPosition();
  }

  Future<void> _loadProgressAndPosition() async {
    final service = LessonProgressService();
    final progress = await service.evaluate(widget.lesson);
    
    // Load badge
    final badge = await BadgeService.getBadge(widget.lesson);

    // Determine first incomplete index from persisted results
    final results = await ActivityResultService.getActivityResults();
    final completedIds = <String>{};
    for (final r in results) {
      if (r.lessonId == widget.lesson.id && r.isCorrect) completedIds.add(r.itemId);
    }

    int firstIncomplete = 0;
    for (var i = 0; i < widget.lesson.items.length; i++) {
      if (!completedIds.contains(widget.lesson.items[i].id)) {
        firstIncomplete = i;
        break;
      }
      if (i == widget.lesson.items.length - 1) {
        firstIncomplete = widget.lesson.items.length - 1;
      }
    }

    setState(() {
      completedCount = progress.completedCount;
      totalCount = progress.totalCount;
      status = progress.status;
      currentItemIndex = firstIncomplete;
      _badge = badge;
      _randomizeOptions();
    });
  }

  /// Randomize options for the current item
  void _randomizeOptions() {
    if (currentItemIndex < widget.lesson.items.length) {
      final currentItem = widget.lesson.items[currentItemIndex];
      // Store the correct answer VALUE before shuffling
      _correctAnswerValue = currentItem.options[currentItem.correctAnswerIndex];
      // Shuffle options
      _randomizedOptions = List<String>.from(currentItem.options);
      _randomizedOptions.shuffle();
    }
  }

  // Save answer first, then evaluate, then setState (persistence order enforced)
  Future<void> _handleOptionTap(int tappedIndex) async {
    if (status == LessonProgressStatus.mastered || _exerciseCompleted) return;

    final currentItem = widget.lesson.items[currentItemIndex];
    final selectedOption = _randomizedOptions[tappedIndex];
    final isCorrect = selectedOption == _correctAnswerValue;

    final result = ActivityResult(
      lessonId: widget.lesson.id,
      itemId: currentItem.id,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
    );

    // 1) Persist immediately
    await ActivityResultService.saveActivityResult(result);

    // 2) Evaluate using single source of truth
    final service = LessonProgressService();
    final progress = await service.evaluate(widget.lesson);

    // Capture context before async operation
    if (!mounted) return;
    final lessonController = context.read<LessonController>();
    
    // 3) Update UI with feedback and progress via Provider
    lessonController.submitAnswer(isCorrect: isCorrect);
    
    setState(() {
      _selectedAnswerIndex = tappedIndex;
      _answered = true;
      _isCorrect = isCorrect;
      completedCount = progress.completedCount;
      totalCount = progress.totalCount;
      status = progress.status;
    });

    // 4) Check if exercise is complete using Provider state
    if (lessonController.isLessonCompleted && !_exerciseCompleted) {
      // All items in this exercise are complete - call callback ONCE immediately
      _exerciseCompleted = true; // Prevent looping
      if (widget.onExerciseCompleted != null) {
        // In flow mode: signal exercise completion immediately
        if (mounted) {
          widget.onExerciseCompleted!();
        }
      } else {
        // Standalone mode: check for mastery and navigate
        if (progress.status == LessonProgressStatus.mastered) {
          _exitAfterMastery();
        }
      }
    }
  }

  // Handle advancing to next item or retry
  Future<void> _onNextOrRetry() async {
    // Don't advance if exercise is complete
    if (_exerciseCompleted) return;
    
    if (_isCorrect == true) {
      // Correct answer: advance to next incomplete item
      final results = await ActivityResultService.getActivityResults();
      final completedIds = <String>{};
      for (final r in results) {
        if (r.lessonId == widget.lesson.id && r.isCorrect) completedIds.add(r.itemId);
      }

      int nextIndex = currentItemIndex;
      for (var i = currentItemIndex + 1; i < widget.lesson.items.length; i++) {
        if (!completedIds.contains(widget.lesson.items[i].id)) {
          nextIndex = i;
          break;
        }
        if (i == widget.lesson.items.length - 1) nextIndex = widget.lesson.items.length - 1;
      }

      setState(() {
        currentItemIndex = nextIndex;
        _selectedAnswerIndex = null;
        _answered = false;
        _isCorrect = null;
        _randomizeOptions(); // Re-randomize for the new item
      });
    } else {
      // Incorrect: reset for retry
      setState(() {
        _selectedAnswerIndex = null;
        _answered = false;
        _isCorrect = null;
      });
    }
  }

  // Navigate back to LessonsScreen after mastery
  void _exitAfterMastery() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Standalone mode: check if animals lesson and navigate to matching
        if (widget.lesson.id == 'animals') {
          _navigateToMatchingExercise();
        } else {
          Navigator.pop(context, true); // Return true to signal state changed
        }
      }
    });
  }

  void _navigateToMatchingExercise() {
    // Build matching items for animals
    final matchingItems = [
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
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchingExerciseScreen(
          lessonId: widget.lesson.id,
          title: widget.lesson.title,
          items: matchingItems,
        ),
      ),
    ).then((result) {
      // When matching exercise returns, pop this screen with true to signal completion
      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.lesson.items;
    
    // If exercise is complete, show completion feedback and stop rendering
    if (_exerciseCompleted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lección')),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '✓ Correcto',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '🎉 Ejercicio completado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (currentItemIndex >= items.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lección')),
        body: const Center(child: Text('Lección completada')),
      );
    }

    final currentItem = items[currentItemIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Lección')),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Consumer<LessonController>(
                builder: (context, lessonController, _) {
                  return LinearProgressIndicator(
                    value: lessonController.progress,
                    backgroundColor: Colors.grey[300],
                    color: Colors.deepPurple,
                    minHeight: 8,
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  status == LessonProgressStatus.notStarted
                      ? 'No iniciada'
                      : status == LessonProgressStatus.inProgress
                          ? 'En progreso'
                          : 'Dominada',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Visual stimulus
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Center(
                      child: currentItem.stimulusImageAsset != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                currentItem.stimulusImageAsset!,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                          : currentItem.stimulusColor != null
                              ? Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    color: currentItem.stimulusColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                    ),
                  ),

                  // Question
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.lesson.question,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Options (only tappable if not answered)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: List.generate(
                        _randomizedOptions.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: (status == LessonProgressStatus.mastered || _answered)
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedAnswerIndex = index;
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedAnswerIndex == index
                                    ? Colors.deepPurple
                                    : Colors.grey[200],
                                disabledBackgroundColor: _answered
                                    ? (_randomizedOptions[index] == _correctAnswerValue
                                        ? Colors.green[300]
                                        : Colors.grey[300])
                                    : Colors.grey[200],
                              ),
                              child: Text(
                                _randomizedOptions[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedAnswerIndex == index && !_answered
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Submit button OR Feedback + Next button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: !_answered
                        ? SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _selectedAnswerIndex != null && status != LessonProgressStatus.mastered
                                  ? () => _handleOptionTap(_selectedAnswerIndex!)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                disabledBackgroundColor: Colors.grey[300],
                              ),
                              child: const Text(
                                'Enviar',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isCorrect! ? Colors.green[100] : Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isCorrect! ? '✓ Correcto' : '✗ Intenta de nuevo',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _isCorrect! ? Colors.green[700] : Colors.red[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: _onNextOrRetry,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                    ),
                                    child: Text(
                                      _isCorrect! ? 'Siguiente' : 'Reintentar',
                                      style: const TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  // Mastered message (only if status is mastered)
                  if (status == LessonProgressStatus.mastered)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🎉 ¡Lección dominada!',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (_badge != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Badge desbloqueado: ${_badge!.icon} ${_badge!.title}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                    ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
