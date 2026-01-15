import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../models/activity_result.dart';
import '../models/matching_item.dart';
import '../logic/activity_result_service.dart';
import '../logic/lesson_progress_evaluator.dart';
import '../logic/lesson_completion_service.dart';
import '../logic/badge_service.dart';
import '../logic/lesson_controller.dart';
import '../models/badge.dart' as achievement;
import '../widgets/lesson_image.dart';
import 'matching_exercise_screen.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback? onExerciseCompleted; // Callback when this exercise completes
  final double progressOffset; // Progress offset when used in flow (0.0-1.0)
  final double progressScale; // Progress scale when used in flow (0.0-1.0)

  const LessonScreen({
    super.key,
    required this.lesson,
    this.onExerciseCompleted,
    this.progressOffset = 0.0,
    this.progressScale = 1.0,
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
    // Defer controller initialization to after the frame to avoid assertion errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LessonController>().initializeLesson(totalCount);
      }
    });
    _loadProgressAndPosition();
  }

  Future<void> _loadProgressAndPosition() async {
    final service = LessonProgressService();
    final progress = await service.evaluate(widget.lesson);
    
    // Load badge
    final badge = await BadgeService.getBadge(widget.lesson);

    // Determine starting question index based on lesson status
    // Key distinction:
    // - notStarted: Always start from question 0 (new attempt)
    // - inProgress: Resume from first incomplete (continuation)
    // - mastered: Start from first incomplete for review
    int firstIncomplete = 0;
    
    if (progress.status == LessonProgressStatus.notStarted) {
      // New attempt: always start from question 0
      firstIncomplete = 0;
    } else {
      // Resume attempt: find first incomplete from persisted results
      final results = await ActivityResultService.getActivityResults();
      final completedIds = <String>{};
      for (final r in results) {
        if (r.lessonId == widget.lesson.id && r.isCorrect) completedIds.add(r.itemId);
      }

      for (var i = 0; i < widget.lesson.items.length; i++) {
        if (!completedIds.contains(widget.lesson.items[i].id)) {
          firstIncomplete = i;
          break;
        }
      }
      // If all items are completed, start from the last item
      if (completedIds.length == widget.lesson.items.length) {
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
    lessonController.submitAnswer(
      itemId: currentItem.id,
      selectedOption: selectedOption,
      isCorrect: isCorrect,
    );
    
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
      
      // A lesson is mastered ONLY if the current attempt is perfect (100% correct)
      final isCurrentAttemptPerfect = lessonController.correctAnswers == lessonController.totalQuestions;
      
      if (isCurrentAttemptPerfect) {
        // Save lesson completion record (source of truth for mastery)
        await LessonCompletionService.saveCompletion(widget.lesson.id);
        
        // Award badge (only on first perfect completion)
        final badgeJustAwarded = await BadgeService.checkAndAwardBadge(widget.lesson);
        if (badgeJustAwarded && mounted) {
          // Reload badge to show it was just awarded
          final badge = await BadgeService.getBadge(widget.lesson);
          setState(() {
            _badge = badge;
          });
        }
      }
      
      if (widget.onExerciseCompleted != null) {
        // In flow mode: signal exercise completion immediately
        if (mounted) {
          widget.onExerciseCompleted!();
        }
      } else {
        // Standalone mode: navigate after mastery (only if perfect attempt)
        if (isCurrentAttemptPerfect) {
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
      // Correct answer: advance to next question sequentially
      // Do NOT use persisted results - they only control initial positioning
      int nextIndex = currentItemIndex + 1;
      
      // If we've answered all questions, stay at the last one
      if (nextIndex >= widget.lesson.items.length) {
        nextIndex = widget.lesson.items.length - 1;
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
      // Decrement controller's question index to allow retry of same question
      final lessonController = context.read<LessonController>();
      lessonController.decrementQuestionIndex();
      
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
        // Check if lesson has matching exercise and navigate to it
        if (widget.lesson.id == 'animals' || widget.lesson.id == 'family_1') {
          _navigateToMatchingExercise();
        } else {
          Navigator.pop(context, true); // Return true to signal state changed
        }
      }
    });
  }

  void _navigateToMatchingExercise() {
    // Build matching items based on lesson
    List<MatchingItem> matchingItems = [];
    
    if (widget.lesson.id == 'animals') {
      // Animals matching items
      matchingItems = [
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
    } else if (widget.lesson.id == 'family_1') {
      // Family matching items
      matchingItems = [
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
                  // Calculate progress with offset and scale
                  final adjustedProgress = widget.progressOffset + 
                      (lessonController.progress * widget.progressScale);
                  return LinearProgressIndicator(
                    value: adjustedProgress,
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LessonImage(
                          imagePath: currentItem.stimulusImageAsset,
                          fallbackColor: currentItem.stimulusColor,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
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
