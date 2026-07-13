import 'package:flutter/material.dart';

import '../../data/lessons_data.dart';
import '../../logic/practice_service.dart';
import '../../logic/star_service.dart';
import '../../models/lesson.dart';
import '../../models/lesson_item.dart';
import '../../models/practice_activity.dart';
import '../../services/audio_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/lesson_image.dart';

/// Pantalla de práctica de ortografía (Spelling Game)
/// El niño debe arrastrar letras para formar la palabra correcta
class SpellingPracticeScreen extends StatefulWidget {
  final PracticeActivity activity;

  const SpellingPracticeScreen({
    super.key,
    required this.activity,
  });

  @override
  State<SpellingPracticeScreen> createState() => _SpellingPracticeScreenState();
}

class _SpellingPracticeScreenState extends State<SpellingPracticeScreen>
    with SingleTickerProviderStateMixin {
  late List<LessonItem> _items;
  late Lesson _lesson;
  int _currentIndex = 0;
  int _correctCount = 0;
  List<String> _placedLetters = [];
  List<String> _availableLetters = [];
  bool _isCorrect = false;
  bool _showFeedback = false;
  final AudioService _audioService = AudioService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadLesson();
    _audioService.initialize();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  void _loadLesson() {
    // Buscar la lección correspondiente al activity
    final allLessons = lessonLevels.expand((level) => level.lessons).toList();
    _lesson = allLessons.firstWhere(
      (lesson) => lesson.id == widget.activity.lessonId,
    );
    
    _items = List.from(_lesson.items);
    _items.shuffle();
    _setupLetters();
  }

  void _setupLetters() {
    final word = _items[_currentIndex].title.toUpperCase();
    _placedLetters = [];
    _availableLetters = word.split('')..shuffle();
    _isCorrect = false;
    _showFeedback = false;
  }

  Future<void> _checkAnswer() async {
    final correctWord = _items[_currentIndex].title.toUpperCase();
    final userWord = _placedLetters.join();

    setState(() {
      _isCorrect = userWord == correctWord;
      _showFeedback = true;
    });

    if (_isCorrect) {
      _correctCount++;
      _audioService.playCorrectSound();
      _animationController.forward(from: 0);
      
      // Agregar estrellas al usuario
      await StarService.addStars(
        1,
        'practice_spelling',
        description: 'Spelling correcto: ${_items[_currentIndex].title}',
      );

      Future.delayed(const Duration(milliseconds: 1500), _nextItem);
    } else {
      _audioService.playWrongSound();
    }
  }

  void _nextItem() {
    if (_currentIndex < _items.length - 1) {
      setState(() {
        _currentIndex++;
        _setupLetters();
      });
    } else {
      _completeActivity();
    }
  }

  Future<void> _completeActivity() async {
    // Calcular estrellas ganadas
    final starsEarned = _correctCount + (_correctCount == _items.length ? 5 : 0);
    
    // Guardar progreso final - actualizar con el número de ejercicios completados
    await PracticeService.updateProgress(
      activityId: widget.activity.id,
      totalExercises: _items.length,
      exercisesCompleted: _correctCount, // Número de palabras correctas
      starsEarned: starsEarned,
      newScore: _correctCount,
    );

    // Bonus por completar toda la actividad
    if (_correctCount == _items.length) {
      await StarService.addStars(
        5,
        'practice_complete',
        description: 'Spelling completado: ${_lesson.title}',
      );
    }

    if (mounted) {
      // Mostrar diálogo de completado
      final totalStars = _correctCount + (_correctCount == _items.length ? 5 : 0);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('¡Actividad Completada!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                size: 64,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              Text(
                'Palabras correctas: $_correctCount/${_items.length}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Estrellas ganadas: $totalStars ⭐',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver al hub
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    }
  }

  void _onLetterTapped(String letter) {
    setState(() {
      _availableLetters.remove(letter);
      _placedLetters.add(letter);
      _showFeedback = false;
    });
  }

  void _onPlacedLetterTapped(int index) {
    setState(() {
      final letter = _placedLetters.removeAt(index);
      _availableLetters.add(letter);
      _showFeedback = false;
    });
  }

  void _resetWord() {
    setState(() {
      _availableLetters.addAll(_placedLetters);
      _placedLetters.clear();
      _showFeedback = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = _items[_currentIndex];
    final progress = (_currentIndex + 1) / _items.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.title),
        backgroundColor: Color(widget.activity.color),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentIndex + 1}/${_items.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Color(widget.activity.color)),
            minHeight: Responsive.scale(context, 5, 6, 8),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.scale(context, 12, 16, 20)),
              child: Column(
                children: [
                  SizedBox(height: Responsive.scale(context, 16, 20, 24)),
                  Text(
                    '¡Arrastra las letras para formar la palabra!',
                    style: TextStyle(
                      fontSize: Responsive.scale(context, 18, 20, 22),
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.scale(context, 20, 30, 32)),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: currentItem.stimulusColor != null
                        ? Container(
                            width: Responsive.scale(context, 180, 200, 220),
                            height: Responsive.scale(context, 180, 200, 220),
                            decoration: BoxDecoration(
                              color: currentItem.stimulusColor,
                              borderRadius: BorderRadius.circular(Responsive.borderRadius(context)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(26),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          )
                        : LessonImage(
                            imagePath: currentItem.stimulusImageAsset,
                            fallbackColor: Colors.grey[300],
                            width: Responsive.scale(context, 180, 200, 220),
                            height: Responsive.scale(context, 180, 200, 220),
                          ),
                  ),
                  SizedBox(height: Responsive.scale(context, 20, 30, 32)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: Responsive.scale(context, 16, 20, 24),
                      horizontal: Responsive.scale(context, 12, 16, 20),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(Responsive.borderRadius(context)),
                      border: Border.all(
                        color: _showFeedback
                            ? (_isCorrect ? Colors.green : Colors.red)
                            : Colors.grey[400]!,
                        width: 3,
                      ),
                    ),
                    child: Wrap(
                      spacing: Responsive.scale(context, 6, 8, 10),
                      runSpacing: Responsive.scale(context, 6, 8, 10),
                      alignment: WrapAlignment.center,
                      children: [
                        if (_placedLetters.isEmpty)
                          Container(
                            width: Responsive.scale(context, 52, 60, 68),
                            height: Responsive.scale(context, 52, 60, 68),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey[400]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(Responsive.scale(context, 10, 12, 14)),
                            ),
                            child: Icon(
                              Icons.touch_app,
                              color: Colors.grey[400],
                              size: Responsive.scale(context, 24, 30, 36),
                            ),
                          )
                        else
                          ...List.generate(
                            _placedLetters.length,
                            (index) => _buildPlacedLetter(
                              _placedLetters[index],
                              index,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_showFeedback) ...[
                    SizedBox(height: Responsive.scale(context, 16, 20, 24)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isCorrect ? Icons.check_circle : Icons.cancel,
                          color: _isCorrect ? Colors.green : Colors.red,
                          size: Responsive.scale(context, 32, 40, 48),
                        ),
                        SizedBox(width: Responsive.scale(context, 8, 10, 12)),
                        Text(
                          _isCorrect ? '¡Correcto!' : 'Intenta de nuevo',
                          style: TextStyle(
                            fontSize: Responsive.scale(context, 20, 24, 28),
                            fontWeight: FontWeight.bold,
                            color: _isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: Responsive.scale(context, 24, 30, 32)),
                  Text(
                    'Letras disponibles:',
                    style: TextStyle(
                      fontSize: Responsive.scale(context, 14, 16, 18),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: Responsive.scale(context, 12, 16, 20)),
                  Wrap(
                    spacing: Responsive.scale(context, 10, 12, 14),
                    runSpacing: Responsive.scale(context, 10, 12, 14),
                    alignment: WrapAlignment.center,
                    children: _availableLetters
                        .map((letter) => _buildAvailableLetter(letter))
                        .toList(),
                  ),
                  SizedBox(height: Responsive.scale(context, 24, 30, 32)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _placedLetters.isEmpty ? null : _resetWord,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reiniciar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.scale(context, 16, 20, 24),
                            vertical: Responsive.scale(context, 10, 12, 14),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _placedLetters.length ==
                                currentItem.title.length
                            ? _checkAnswer
                            : null,
                        icon: const Icon(Icons.check),
                        label: const Text('Verificar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.scale(context, 16, 20, 24),
                            vertical: Responsive.scale(context, 10, 12, 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.scale(context, 16, 20, 24)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableLetter(String letter) {
    return GestureDetector(
      onTap: () => _onLetterTapped(letter),
      child: Container(
        width: Responsive.scale(context, 52, 60, 68),
        height: Responsive.scale(context, 52, 60, 68),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Responsive.scale(context, 10, 12, 14)),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withAlpha(76),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: Responsive.scale(context, 28, 32, 36),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlacedLetter(String letter, int index) {
    return GestureDetector(
      onTap: () => _onPlacedLetterTapped(index),
      child: Container(
        width: Responsive.scale(context, 52, 60, 68),
        height: Responsive.scale(context, 52, 60, 68),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Responsive.scale(context, 10, 12, 14)),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withAlpha(76),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: Responsive.scale(context, 28, 32, 36),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
