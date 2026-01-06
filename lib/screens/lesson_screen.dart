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
  late int _currentItemIndex = 0;
  int? _selectedAnswerIndex;
  bool _answered = false;
  bool? _isCorrect;

  Future<void> _submitAnswer() async {
    if (_selectedAnswerIndex == null) return;

    final currentItem = widget.lesson.items[_currentItemIndex];
    final isCorrect = _selectedAnswerIndex == currentItem.correctAnswerIndex;

    // Registrar resultado en almacenamiento local (usando lessonId, no itemId)
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

  void _nextItem() {
    if (_currentItemIndex < widget.lesson.items.length - 1) {
      setState(() {
        _currentItemIndex++;
        _selectedAnswerIndex = null;
        _answered = false;
        _isCorrect = null;
      });
    } else {
      // Si es el último ítem, regresar a pantalla anterior
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener item actual
    final currentItem = widget.lesson.items[_currentItemIndex];
    final itemProgress = '${_currentItemIndex + 1}/${widget.lesson.items.length}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                itemProgress,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final stimulusHeight = screenHeight * 0.35;
          final contentHeight = screenHeight * 0.45;
          final actionHeight = screenHeight * 0.2;

          return Column(
            children: [
              // ZONA 1: Estímulo visual (35%)
              SizedBox(
                height: stimulusHeight,
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

              // ZONA 2: Contenido (pregunta + opciones) (45%)
              SizedBox(
                height: contentHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pregunta (sin título del item para evitar spoiler)
                      Flexible(
                        flex: 1,
                        child: Center(
                          child: Text(
                            widget.lesson.question,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Opciones como botones
                      Flexible(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            currentItem.options.length,
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
                                      ? (index == currentItem.correctAnswerIndex
                                          ? Colors.green
                                          : Colors.grey[300])
                                      : Colors.grey[300],
                                ),
                                child: Text(
                                  currentItem.options[index],
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
                                  onPressed: _nextItem,
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
