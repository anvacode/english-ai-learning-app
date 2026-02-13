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
import '../logic/star_service.dart';
import '../models/badge.dart' as achievement;
import '../widgets/lesson_image.dart';
import '../widgets/speaker_button.dart';
import '../widgets/sparkles_overlay.dart';
import '../widgets/translation_popup.dart';
import '../services/audio_service.dart';
import '../services/effects_service.dart';
import '../dialogs/lesson_completion_dialog.dart';
import 'matching_exercise_screen.dart';
import '../utils/responsive.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback?
  onExerciseCompleted; // Callback when this exercise completes
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

  // Audio service
  final AudioService _audioService = AudioService();

  // Sparkles effect state
  bool _showSparkles = false;
  Offset? _sparklesCenter;

  @override
  void initState() {
    super.initState();
    totalCount = widget.lesson.items.length;
    // Initialize audio service
    _audioService.initialize();
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
        if (r.lessonId == widget.lesson.id && r.isCorrect)
          completedIds.add(r.itemId);
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

    // Auto-speak the current word when question appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && currentItemIndex < widget.lesson.items.length) {
        final currentItem = widget.lesson.items[currentItemIndex];
        final wordToSpeak = currentItem.options[currentItem.correctAnswerIndex];
        _audioService.autoSpeak(wordToSpeak);
      }
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

  /// Trigger sparkles effect on correct answer
  Future<void> _triggerSparklesEffect() async {
    final shouldShow = await EffectsService.shouldShowSparkles();
    if (mounted && shouldShow) {
      // Get center of screen for sparkles
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _showSparkles = true;
        _sparklesCenter = Offset(screenSize.width / 2, screenSize.height / 2);
      });
    }
  }

  // Save answer first, then evaluate, then setState (persistence order enforced)
  Future<void> _handleOptionTap(int tappedIndex) async {
    if (status == LessonProgressStatus.mastered || _exerciseCompleted) return;

    final currentItem = widget.lesson.items[currentItemIndex];
    final selectedOption = _randomizedOptions[tappedIndex];
    final isCorrect = selectedOption == _correctAnswerValue;

    // Play click sound
    await _audioService.playClickSound();

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
    final shouldRestart = lessonController.submitAnswer(
      itemId: currentItem.id,
      selectedOption: selectedOption,
      isCorrect: isCorrect,
    );

    // Check if lesson should restart due to too many errors (3 per question)
    if (shouldRestart) {
      await _audioService.playWrongSound();

      // Show dialog informing about restart
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('🔄 Reiniciando lección'),
            content: const Text(
              'Has tenido 3 errores en esta pregunta. '
              'Vamos a empezar la lección de nuevo para que puedas practicar más. '
              '¡Tú puedes!',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  '¡Vamos!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }

      // Restart the lesson
      if (mounted) {
        lessonController.restartLesson();
        setState(() {
          currentItemIndex = 0;
          _selectedAnswerIndex = null;
          _answered = false;
          _isCorrect = null;
          completedCount = 0;
          totalCount = progress.totalCount;
          status = LessonProgressStatus.inProgress;
        });
        _randomizeOptions();
      }
      return;
    }

    setState(() {
      _selectedAnswerIndex = tappedIndex;
      _answered = true;
      _isCorrect = isCorrect;
      completedCount = progress.completedCount;
      totalCount = progress.totalCount;
      status = progress.status;
    });

    // Play feedback sound and show sparkles effect
    if (isCorrect) {
      await _audioService.playCorrectSound();
      // Show sparkles effect if purchased and active
      _triggerSparklesEffect();
    } else {
      await _audioService.playWrongSound();

      // Show number of attempts left for this question
      final attemptsLeft =
          3 -
          lessonController.getIncorrectAttemptsForCurrentQuestion(
            currentItem.id,
          );
      if (attemptsLeft > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Intentos restantes para esta pregunta: $attemptsLeft',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange[700],
          ),
        );
      }
    }

    // 4) Check if exercise is complete using Provider state
    if (lessonController.isLessonCompleted && !_exerciseCompleted) {
      // All items in this exercise are complete - call callback ONCE immediately
      _exerciseCompleted = true; // Prevent looping

      // A lesson is mastered ONLY if the current attempt is perfect (100% correct)
      final isCurrentAttemptPerfect =
          lessonController.correctAnswers == lessonController.totalQuestions;

      // If we are in flow mode (onExerciseCompleted is not null),
      // don't show feedback/dialog yet - let the flow controller handle it
      if (widget.onExerciseCompleted != null) {
        // In flow mode: just signal exercise completion without showing dialog
        // The LessonFlowScreen will show feedback after ALL exercises are done
        if (mounted) {
          widget.onExerciseCompleted!();
        }
      } else {
        // Standalone mode: Show feedback and award stars immediately
        int starsEarned = 0;
        achievement.Badge? badgeToShow;

        if (isCurrentAttemptPerfect) {
          // Check if lesson was already completed before
          final wasAlreadyCompleted =
              await LessonCompletionService.isLessonCompleted(widget.lesson.id);

          // Save lesson completion record (source of truth for mastery)
          await LessonCompletionService.saveCompletion(widget.lesson.id);

          // Award stars only if this is the first time completing the lesson
          if (!wasAlreadyCompleted) {
            const starsForCompletion = 20; // Base stars for completing a lesson
            await StarService.addStars(
              starsForCompletion,
              'lesson_complete',
              lessonId: widget.lesson.id,
              description: 'Completaste la lección "${widget.lesson.title}"',
            );
            starsEarned = starsForCompletion;
          }

          // Award badge (only on first perfect completion)
          final badgeJustAwarded = await BadgeService.checkAndAwardBadge(
            widget.lesson,
          );
          if (badgeJustAwarded && mounted) {
            // Reload badge to show it was just awarded
            final badge = await BadgeService.getBadge(widget.lesson);
            setState(() {
              _badge = badge;
            });
            badgeToShow = badge;
          } else if (mounted) {
            // Show existing badge if any
            final badge = await BadgeService.getBadge(widget.lesson);
            if (badge != null && badge.unlocked) {
              badgeToShow = badge;
            }
          }
        } else {
          // Award partial stars for completing lesson items (even if not perfect)
          // This encourages progress even if not perfect
          const starsForProgress = 5;
          await StarService.addStars(
            starsForProgress,
            'lesson_progress',
            lessonId: widget.lesson.id,
            description: 'Progreso en la lección "${widget.lesson.title}"',
          );
          starsEarned = starsForProgress;
        }

        // Show completion dialog with feedback (only in standalone mode)
        if (mounted) {
          await LessonCompletionDialog.show(
            context,
            lessonTitle: widget.lesson.title,
            starsEarned: starsEarned,
            correctAnswers: lessonController.correctAnswers,
            totalQuestions: lessonController.totalQuestions,
            badgeIcon: badgeToShow?.icon,
            badgeTitle: badgeToShow?.title,
            isPerfectScore: isCurrentAttemptPerfect,
          );
        }

        // Navigate after mastery (only if perfect attempt)
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

      // Auto-speak the new word when advancing
      if (nextIndex < widget.lesson.items.length) {
        final nextItem = widget.lesson.items[nextIndex];
        final wordToSpeak = nextItem.options[nextItem.correctAnswerIndex];
        _audioService.autoSpeak(wordToSpeak);
      }
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Consumer<LessonController>(
                    builder: (context, lessonController, _) {
                      // Calculate progress with offset and scale
                      final adjustedProgress =
                          widget.progressOffset +
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 2.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      status == LessonProgressStatus.notStarted
                          ? 'No iniciada'
                          : status == LessonProgressStatus.inProgress
                          ? 'En progreso'
                          : 'Dominada',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Visual stimulus - responsivo
                      Padding(
                        padding: EdgeInsets.only(
                          top: context.isMobile ? 12.0 : 8.0,
                        ),
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[50],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LessonImage(
                                imagePath: currentItem.stimulusImageAsset,
                                fallbackColor: currentItem.stimulusColor,
                                // Tamaño responsivo: más pequeño en web
                                width: context.isMobile
                                    ? 200
                                    : (context.isTablet ? 180 : 150),
                                height: context.isMobile
                                    ? 200
                                    : (context.isTablet ? 180 : 150),
                                fit: BoxFit
                                    .contain, // Mostrar imagen completa sin recortar
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Question with speaker button and translation helper - responsivo
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: context.isMobile ? 0 : 4.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                widget.lesson.question,
                                style: TextStyle(
                                  fontSize: context.isMobile
                                      ? 18
                                      : 16, // Más pequeño en web
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SpeakerButton(
                              text: currentItem
                                  .options[currentItem.correctAnswerIndex],
                              iconSize: 20,
                              buttonSize: 36,
                            ),
                            const SizedBox(width: 4),
                            // Botón de traducción
                            IconButton(
                              onPressed: () {
                                final word = currentItem
                                    .options[currentItem.correctAnswerIndex];
                                final translation =
                                    TranslationService.translate(word);
                                TranslationPopup.show(
                                  context,
                                  word: word,
                                  translation: translation,
                                );
                              },
                              icon: const Icon(Icons.help_outline),
                              color: Colors.blue[600],
                              iconSize: 24,
                              tooltip: 'Ver traducción',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Options (only tappable if not answered) - responsivo
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: context.isMobile ? 8.0 : 4.0,
                        ),
                        child: Column(
                          children: List.generate(
                            _randomizedOptions.length,
                            (index) => Center(
                              // Centrar botones horizontalmente
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: context.isMobile ? 6.0 : 4.0,
                                ),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    // Más estrecho en web
                                    maxWidth: context.isMobile
                                        ? MediaQuery.of(context).size.width *
                                              0.85
                                        : (context.isTablet ? 400 : 350),
                                    minHeight: context.isMobile
                                        ? 52
                                        : 44, // Más bajo en web
                                    maxHeight: context.isMobile
                                        ? 68
                                        : 56, // Más compacto en web
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        (status ==
                                                LessonProgressStatus.mastered ||
                                            _answered)
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedAnswerIndex = index;
                                            });
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _selectedAnswerIndex == index
                                          ? Colors.deepPurple
                                          : Colors.grey[200],
                                      disabledBackgroundColor: _answered
                                          ? (_selectedAnswerIndex == index
                                                ? (_isCorrect!
                                                      ? Colors.green[300]
                                                      : Colors.red[300])
                                                : Colors.grey[300])
                                          : Colors.grey[200],
                                      padding: EdgeInsets.symmetric(
                                        horizontal: context.isMobile ? 16 : 12,
                                        vertical: context.isMobile ? 12 : 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Centrar contenido
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            _randomizedOptions[index],
                                            style: TextStyle(
                                              fontSize: context.isMobile
                                                  ? 15
                                                  : 14, // Más pequeño en web
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  _selectedAnswerIndex ==
                                                          index &&
                                                      !_answered
                                                  ? Colors.white
                                                  : Colors.black,
                                              height: 1.2,
                                            ),
                                            textAlign: TextAlign
                                                .center, // Centrar texto
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                            maxLines: 2,
                                          ),
                                        ),
                                        if (!_answered &&
                                            status !=
                                                LessonProgressStatus
                                                    .mastered) ...[
                                          const SizedBox(width: 8),
                                          SpeakerButton(
                                            text: _randomizedOptions[index],
                                            iconSize: 16,
                                            buttonSize: 28,
                                            iconColor:
                                                _selectedAnswerIndex == index
                                                ? Colors.white
                                                : Colors.deepPurple,
                                          ),
                                        ],
                                      ],
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: !_answered
                            ? Center(
                                // Centrar botón
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 320,
                                    minHeight: 54,
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        _selectedAnswerIndex != null &&
                                            status !=
                                                LessonProgressStatus.mastered
                                        ? () => _handleOptionTap(
                                            _selectedAnswerIndex!,
                                          )
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      disabledBackgroundColor: Colors.grey[300],
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                    ),
                                    child: const Text(
                                      'Enviar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                // Centrar contenedor de feedback
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 320,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _isCorrect!
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Consumer<LessonController>(
                                        builder: (context, lessonController, _) {
                                          final attempts = lessonController
                                              .getIncorrectAttemptsForCurrentQuestion(
                                                currentItem.id,
                                              );
                                          return Text(
                                            _isCorrect!
                                                ? '✓ Correcto'
                                                : attempts >= 3
                                                ? '✗ La respuesta correcta es: $_correctAnswerValue'
                                                : '✗ Intenta de nuevo',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: _isCorrect!
                                                  ? Colors.green[700]
                                                  : Colors.red[700],
                                            ),
                                            textAlign: TextAlign.center,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: _onNextOrRetry,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 14,
                                          ),
                                          minimumSize: const Size(200, 48),
                                        ),
                                        child: Text(
                                          _isCorrect!
                                              ? 'Siguiente'
                                              : 'Reintentar',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),

                      // Mastered message (only if status is mastered)
                      if (status == LessonProgressStatus.mastered)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '🎉 ¡Lección dominada!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_badge != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Badge desbloqueado: ${_badge!.icon} ${_badge!.title}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
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
          ), // Cierre del SafeArea
          if (_showSparkles && _sparklesCenter != null)
            SparklesOverlay(
              isPlaying: _showSparkles,
              center: _sparklesCenter!,
              onComplete: () {
                setState(() {
                  _showSparkles = false;
                });
              },
            ),
        ], // Cierre de children del Stack
      ),
    );
  }
}
