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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pregunta
            Text(
              widget.lesson.question,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Opciones como botones
            ...List.generate(
              widget.lesson.options.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _answered
                        ? null
                        : () {
                            setState(() {
                              _selectedAnswerIndex = index;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        fontSize: 18,
                        color: _selectedAnswerIndex == index
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Botón para enviar respuesta (visible solo antes de responder)
            if (!_answered) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedAnswerIndex != null ? _submitAnswer : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ] else ...[
              // Feedback después de responder
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isCorrect! ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      _isCorrect! ? 'Correct!' : 'Try again',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isCorrect! ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _reset,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
    );
  }
}
