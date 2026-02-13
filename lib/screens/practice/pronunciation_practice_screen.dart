import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/lessons_data.dart';
import '../../models/lesson_item.dart';
import '../../services/speech_recognition_service.dart';
import '../../theme/app_colors.dart';

/// Pantalla de práctica de pronunciación
/// El niño practica pronunciando palabras en inglés y recibe feedback con estrellas
class PronunciationPracticeScreen extends StatefulWidget {
  const PronunciationPracticeScreen({super.key});

  @override
  State<PronunciationPracticeScreen> createState() =>
      _PronunciationPracticeScreenState();
}

class _PronunciationPracticeScreenState
    extends State<PronunciationPracticeScreen> {
  final SpeechRecognitionService _speechService = SpeechRecognitionService();

  bool _isLoading = true;
  bool _isListening = false;
  bool _hasResult = false;

  List<LessonItem> _practiceWords = [];
  int _currentIndex = 0;

  PronunciationResult? _lastResult;
  String _statusMessage = 'Presiona el micrófono y pronuncia la palabra';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);

    // Inicializar servicio de reconocimiento
    final initialized = await _speechService.initialize();

    if (!initialized) {
      setState(() {
        _statusMessage = '❌ No se pudo acceder al micrófono';
        _isLoading = false;
      });
      return;
    }

    // Seleccionar 3-5 palabras aleatorias de todas las lecciones
    _practiceWords = _selectRandomWords();

    setState(() => _isLoading = false);
  }

  List<LessonItem> _selectRandomWords() {
    final allItems = <LessonItem>[];
    for (final lesson in lessonsList) {
      allItems.addAll(lesson.items);
    }

    // Seleccionar 3-5 palabras aleatorias
    final random = Random();
    final count = 3 + random.nextInt(3); // 3, 4 o 5 palabras

    if (allItems.length <= count) return allItems;

    final selected = <LessonItem>[];
    final indices = <int>{};

    while (indices.length < count) {
      indices.add(random.nextInt(allItems.length));
    }

    for (final index in indices) {
      selected.add(allItems[index]);
    }

    return selected;
  }

  Future<void> _startListening() async {
    if (_practiceWords.isEmpty) return;

    setState(() {
      _isListening = true;
      _hasResult = false;
      _statusMessage = '🎤 Escuchando...';
    });

    final currentWord = _practiceWords[_currentIndex];
    final targetWord = currentWord.options[currentWord.correctAnswerIndex];

    // Escuchar y evaluar
    final result = await _speechService.listenAndEvaluate(targetWord);

    if (mounted) {
      setState(() {
        _isListening = false;
        _hasResult = true;
        _lastResult = result;
        _statusMessage = result.message;
      });
    }
  }

  void _nextWord() {
    if (_currentIndex < _practiceWords.length - 1) {
      setState(() {
        _currentIndex++;
        _hasResult = false;
        _lastResult = null;
        _statusMessage = 'Presiona el micrófono y pronuncia la palabra';
      });
    } else {
      // Mostrar resultados finales
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 ¡Práctica completada!'),
        content: Text(
          'Has practicado ${_practiceWords.length} palabras.\n\n'
          '¡Sigue practicando para mejorar tu pronunciación!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Terminar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartPractice();
            },
            child: const Text('Practicar de nuevo'),
          ),
        ],
      ),
    );
  }

  void _restartPractice() {
    setState(() {
      _practiceWords = _selectRandomWords();
      _currentIndex = 0;
      _hasResult = false;
      _lastResult = null;
      _statusMessage = 'Presiona el micrófono y pronuncia la palabra';
    });
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? AppColors.starGold : Colors.grey,
          size: 40,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Práctica de Pronunciación')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_practiceWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Práctica de Pronunciación')),
        body: const Center(
          child: Text('No hay palabras disponibles para practicar'),
        ),
      );
    }

    final currentWord = _practiceWords[_currentIndex];
    final targetWord = currentWord.options[currentWord.correctAnswerIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 Práctica de Pronunciación'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentIndex + 1}/${_practiceWords.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Barra de progreso
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _practiceWords.length,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 32),

              // Imagen de la palabra
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: currentWord.stimulusImageAsset != null
                      ? Image.asset(
                          currentWord.stimulusImageAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: currentWord.stimulusColor,
                              child: const Icon(
                                Icons.image,
                                size: 80,
                                color: Colors.white,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: currentWord.stimulusColor,
                          child: const Icon(
                            Icons.image,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Palabra objetivo
              Text(
                targetWord,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pronuncia esta palabra',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Resultado o botón de micrófono
              if (_hasResult && _lastResult != null) ...[
                // Mostrar resultado
                _buildStarRating(_lastResult!.starRating),
                const SizedBox(height: 16),
                Text(
                  _lastResult!.message,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _lastResult!.isCorrect
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!_lastResult!.isCorrect) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Escuchado: "${_lastResult!.recognizedText}"',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_lastResult!.isCorrect)
                      ElevatedButton.icon(
                        onPressed: _startListening,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    if (!_lastResult!.isCorrect) const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _nextWord,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        _currentIndex < _practiceWords.length - 1
                            ? 'Siguiente'
                            : 'Finalizar',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Botón de micrófono
                GestureDetector(
                  onTap: _isListening ? null : _startListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? Colors.red : AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : AppColors.primary)
                              .withAlpha(100),
                          blurRadius: _isListening ? 30 : 15,
                          spreadRadius: _isListening ? 10 : 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }
}
