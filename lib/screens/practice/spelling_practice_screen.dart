import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import '../../models/lesson_item.dart';
import '../../models/practice_activity.dart';
import '../../services/audio_service.dart';
import '../../widgets/lesson_image.dart';
import '../../logic/practice_service.dart';
import '../../logic/star_service.dart';
import '../../data/lessons_data.dart';
import '../../utils/responsive.dart';

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
    final userWord = _placedLetters.join('');

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
          // Barra de progreso
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Color(widget.activity.color)),
            minHeight: 6,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Instrucción
                  const Text(
                    '¡Arrastra las letras para formar la palabra!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: context.isMobile ? 30 : 20),

                  // Imagen - responsiva
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: currentItem.stimulusColor != null
                        ? Container(
                            width: context.isMobile ? 200 : (context.isTablet ? 180 : 150),
                            height: context.isMobile ? 200 : (context.isTablet ? 180 : 150),
                            decoration: BoxDecoration(
                              color: currentItem.stimulusColor,
                              borderRadius: BorderRadius.circular(12),
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
                            width: context.isMobile ? 200 : (context.isTablet ? 180 : 150),
                            height: context.isMobile ? 200 : (context.isTablet ? 180 : 150),
                          ),
                  ),

                  SizedBox(height: context.isMobile ? 30 : 20),

                  // Área de respuesta (letras colocadas)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _showFeedback
                            ? (_isCorrect ? Colors.green : Colors.red)
                            : Colors.grey[400]!,
                        width: 3,
                      ),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        if (_placedLetters.isEmpty)
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey[400]!,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.touch_app,
                              color: Colors.grey[400],
                              size: 30,
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

                  // Feedback visual
                  if (_showFeedback) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isCorrect ? Icons.check_circle : Icons.cancel,
                          color: _isCorrect ? Colors.green : Colors.red,
                          size: 40,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isCorrect ? '¡Correcto!' : 'Intenta de nuevo',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Letras disponibles
                  const Text(
                    'Letras disponibles:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _availableLetters
                        .map((letter) => _buildAvailableLetter(letter))
                        .toList(),
                  ),

                  const SizedBox(height: 30),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botón Reset
                      ElevatedButton.icon(
                        onPressed: _placedLetters.isEmpty ? null : _resetWord,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reiniciar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),

                      // Botón Verificar
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
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
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
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
            style: const TextStyle(
              fontSize: 32,
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
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
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
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
