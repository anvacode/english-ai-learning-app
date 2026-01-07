import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../models/activity_result.dart';
import '../logic/activity_result_service.dart';
import '../logic/lesson_progress_evaluator.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  // Core state fields (single source of truth)
  int completedCount = 0;
  int totalCount = 0;
  LessonProgressStatus status = LessonProgressStatus.notStarted;
  int currentItemIndex = 0;

  // Temporary UI interaction state (reset per item)
  int? _selectedAnswerIndex;
  bool _answered = false;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    totalCount = widget.lesson.items.length;
    _loadProgressAndPosition();
  }

  Future<void> _loadProgressAndPosition() async {
    final service = LessonProgressService();
    final progress = await service.evaluate(widget.lesson);

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
    });
  }

  // Save answer first, then evaluate, then setState (persistence order enforced)
  Future<void> _handleOptionTap(int tappedIndex) async {
    if (status == LessonProgressStatus.mastered) return;

    final currentItem = widget.lesson.items[currentItemIndex];
    final isCorrect = tappedIndex == currentItem.correctAnswerIndex;

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

    // 3) Update UI with feedback
    setState(() {
      _selectedAnswerIndex = tappedIndex;
      _answered = true;
      _isCorrect = isCorrect;
      completedCount = progress.completedCount;
      totalCount = progress.totalCount;
      status = progress.status;
    });
  }

  // Handle advancing to next item or retry
  Future<void> _onNextOrRetry() async {
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

  @override
  Widget build(BuildContext context) {
    final items = widget.lesson.items;
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
              child: LinearProgressIndicator(
                value: totalCount > 0 ? (completedCount / totalCount) : 0,
                backgroundColor: Colors.grey[300],
                color: Colors.deepPurple,
                minHeight: 8,
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
                        currentItem.options.length,
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
                                    ? (index == currentItem.correctAnswerIndex
                                        ? Colors.green[300]
                                        : Colors.grey[300])
                                    : Colors.grey[200],
                              ),
                              child: Text(
                                currentItem.options[index],
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
                      child: const Text(
                        '🎉 ¡Lección dominada!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
