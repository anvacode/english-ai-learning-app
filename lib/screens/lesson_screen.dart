import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../models/activity_result.dart';
import '../logic/activity_result_service.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int? _selectedAnswerIndex;
  bool _answered = false;
  bool? _isCorrect;

  Future<void> _submitAnswer() async {
    if (_selectedAnswerIndex == null) return;

    final isCorrect = _selectedAnswerIndex == widget.lesson.correctAnswerIndex;

    // Registrar resultado en almacenamiento local
    final result = ActivityResult(
      lessonId: widget.lesson.id,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
    );
    await ActivityResultService.saveActivityResult(result);

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
    });
  }

  void _reset() {
    setState(() {
      _selectedAnswerIndex = null;
      _answered = false;
      _isCorrect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final stimulusHeight = screenHeight * 0.4;
          final contentHeight = screenHeight * 0.4;
          final actionHeight = screenHeight * 0.2;

          return Column(
            children: [
              // ZONA 1: Estímulo visual (40%)
              SizedBox(
                height: stimulusHeight,
                child: Center(
                  child: widget.lesson.stimulusColor != null
                      ? Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: widget.lesson.stimulusColor,
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

              // ZONA 2: Contenido (pregunta + opciones) (40%)
              SizedBox(
                height: contentHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pregunta
                      Flexible(
                        flex: 1,
                        child: Center(
                          child: Text(
                            widget.lesson.question,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Opciones como botones
                      Flexible(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            widget.lesson.options.length,
                            (index) => SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: _answered
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedAnswerIndex = index;
                                        });
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedAnswerIndex == index
                                      ? Colors.deepPurple
                                      : Colors.grey[300],
                                  disabledBackgroundColor: _answered
                                      ? (index == widget.lesson.correctAnswerIndex
                                          ? Colors.green
                                          : Colors.grey[300])
                                      : Colors.grey[300],
                                ),
                                child: Text(
                                  widget.lesson.options[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedAnswerIndex == index
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ZONA 3: Acciones (Submit/Feedback/Next) (20%)
              SizedBox(
                height: actionHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_answered) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _selectedAnswerIndex != null
                                ? _submitAnswer
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isCorrect!
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isCorrect! ? 'Correct!' : 'Try again',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _isCorrect!
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: _reset,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text(
                                    'Next',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
