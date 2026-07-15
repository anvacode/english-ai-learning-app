import 'dart:async';
import 'dart:math' show Random;

import 'package:flutter/material.dart';

import '../../data/lessons_data.dart';
import '../../logic/activity_result_service.dart';
import '../../logic/practice_service.dart';
import '../../logic/star_service.dart';
import '../../models/activity_result.dart';
import '../../models/lesson_item.dart';
import '../../services/audio_service.dart';
import '../../theme/text_styles.dart';
import '../../utils/responsive.dart';
import '../../widgets/lesson_image.dart';

/// Pantalla de Speed Match:
/// - Juego de matching contra el tiempo
/// - El jugador debe emparejar imágenes con palabras lo más rápido posible
/// - Bonos por tiempo restante
class SpeedMatchScreen extends StatefulWidget {
  final String lessonId;

  const SpeedMatchScreen({super.key, required this.lessonId});

  @override
  State<SpeedMatchScreen> createState() => _SpeedMatchScreenState();
}

class _SpeedMatchScreenState extends State<SpeedMatchScreen> {
  late List<LessonItem> _items;
  late Set<String> _matchedIds;

  String? _selectedImageId;
  String? _selectedWord;

  int _correctMatches = 0;

  // Timer
  late int _secondsRemaining;
  Timer? _timer;
  bool _isCompleted = false;

  final AudioService _audioService = AudioService();

  static const int _totalSeconds = 60; // 1 minute per round

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _audioService.initialize();
    _startTimer();
  }

  void _initializeGame() {
    // Find the lesson
    final lesson = lessonsList.firstWhere(
      (l) => l.id == widget.lessonId,
      orElse: () => lessonsList.first,
    );

    // Take first 6 items (or all if less than 6)
    _items = lesson.items.take(6).toList();
    _items.shuffle(Random());
    _matchedIds = {};
    _secondsRemaining = _totalSeconds;
    _isCompleted = false;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0 && !_isCompleted) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        if (!_isCompleted) {
          _finishGame();
        }
      }
    });
  }

  void _selectImage(String itemId) {
    if (_matchedIds.contains(itemId) || _isCompleted) return;

    setState(() {
      _selectedImageId = itemId;
    });

    _audioService.playClickSound();

    if (_selectedWord != null) {
      _attemptMatch();
    }
  }

  void _selectWord(String word) {
    // Check if this word is already matched
    final alreadyMatched = _items.any(
      (item) =>
          _matchedIds.contains(item.id) &&
          item.options[item.correctAnswerIndex] == word,
    );

    if (alreadyMatched || _isCompleted) return;

    setState(() {
      _selectedWord = word;
    });

    _audioService.playClickSound();

    if (_selectedImageId != null) {
      _attemptMatch();
    }
  }

  Future<void> _attemptMatch() async {
    if (_selectedImageId == null || _selectedWord == null) return;

    final item = _items.firstWhere(
      (i) => i.id == _selectedImageId,
      orElse: () => _items.first,
    );
    final correctWord = item.options[item.correctAnswerIndex];
    final isCorrect = correctWord == _selectedWord;

    if (isCorrect) {
      await _audioService.playCorrectSound();

      setState(() {
        _matchedIds.add(_selectedImageId!);
        _correctMatches++;
        _selectedImageId = null;
        _selectedWord = null;
      });

      // Save result
      await ActivityResultService.saveActivityResult(
        ActivityResult(
          lessonId: widget.lessonId,
          itemId: '${item.id}_speedmatch',
          isCorrect: true,
          timestamp: DateTime.now(),
        ),
      );

      // Check if all matched
      if (_matchedIds.length == _items.length) {
        _finishGame();
      }
    } else {
      await _audioService.playWrongSound();

      setState(() {
        _selectedImageId = null;
        _selectedWord = null;
      });
    }
  }

  Future<void> _finishGame() async {
    if (_isCompleted) return;

    _timer?.cancel();
    setState(() {
      _isCompleted = true;
    });

    // Calculate score and award stars
    final timeBonus = _secondsRemaining ~/ 5; // 1 star per 5 seconds remaining
    final matchBonus = _correctMatches * 2; // 2 stars per correct match
    final totalStars = timeBonus + matchBonus;

    // Update practice progress
    final activityId = '${widget.lessonId}_speedmatch';
    await PracticeService.updateProgress(
      activityId: activityId,
      totalExercises: _items.length,
      exercisesCompleted: _correctMatches,
      starsEarned: totalStars,
      newScore: _correctMatches,
    );

    if (totalStars > 0) {
      await StarService.addStars(
        totalStars,
        'speed_match',
        lessonId: widget.lessonId,
        description: 'Speed Match completado',
      );
    }

    if (!mounted) return;

    // Show results dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⚡ ¡Tiempo Terminado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Emparejamientos correctos: $_correctMatches/${_items.length}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tiempo restante: $_secondsRemaining seg',
              style: const TextStyle(fontSize: 16),
            ),
            if (totalStars > 0) ...[
              const SizedBox(height: 16),
              Text(
                '¡+$totalStars estrellas!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Salir'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _initializeGame();
                _startTimer();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _correctMatches / _items.length;
    final columns = Responsive.gridColumns(context, mobile: 2, tablet: 3, desktop: 3, wide: 3);
    final hPadding = Responsive.horizontalPadding(context);
    final vPadding = Responsive.verticalPadding(context);
    final gridSpacing = Responsive.gridSpacing(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ Speed Match'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: hPadding),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.scale(context, 10, 12, 14),
                  vertical: Responsive.scale(context, 5, 6, 7),
                ),
                decoration: BoxDecoration(
                  color: _secondsRemaining <= 10 ? Colors.red : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.white, size: Responsive.scale(context, 18, 20, 22)),
                    SizedBox(width: Responsive.scale(context, 3, 4, 5)),
                    Text(
                      '$_secondsRemaining',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.scale(context, 16, 18, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            minHeight: Responsive.scale(context, 6, 8, 10),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
              child: Column(
                children: [
                  Text(
                    '¡Empareja las imágenes con las palabras lo más rápido posible!',
                    style: context.bodyTextLarge.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.scale(context, 12, 16, 20)),
                  Text(
                    'Correctos: $_correctMatches/${_items.length}',
                    style: TextStyle(
                      fontSize: Responsive.scale(context, 16, 18, 20),
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: Responsive.scale(context, 16, 24, 28)),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: gridSpacing,
                      mainAxisSpacing: gridSpacing,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final isMatched = _matchedIds.contains(item.id);
                      final isSelected = _selectedImageId == item.id;

                      return GestureDetector(
                        onTap: () => _selectImage(item.id),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isMatched
                                  ? Colors.green
                                  : isSelected
                                      ? Colors.orange
                                      : Colors.grey[300]!,
                              width: isSelected || isMatched ? 4 : 2,
                            ),
                            borderRadius: BorderRadius.circular(Responsive.borderRadius(context)),
                            color: isMatched ? Colors.green[100] : Colors.white,
                          ),
                          child: isMatched
                              ? Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: Responsive.scale(context, 36, 42, 48),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(Responsive.borderRadius(context) - 2),
                                  child: LessonImage(
                                    imagePath: item.stimulusImageAsset,
                                    fallbackColor: item.stimulusColor,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: Responsive.scale(context, 16, 24, 28)),
                  Wrap(
                    spacing: Responsive.scale(context, 6, 8, 10),
                    runSpacing: Responsive.scale(context, 6, 8, 10),
                    alignment: WrapAlignment.center,
                    children: _items.map((item) {
                      final word = item.options[item.correctAnswerIndex];
                      final isMatched = _matchedIds.contains(item.id);
                      final isSelected = _selectedWord == word;

                      return GestureDetector(
                        onTap: () => _selectWord(word),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.scale(context, 16, 20, 24),
                            vertical: Responsive.scale(context, 10, 12, 14),
                          ),
                          decoration: BoxDecoration(
                            color: isMatched
                                ? Colors.green[100]
                                : isSelected
                                    ? Colors.orange
                                    : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isMatched
                                  ? Colors.green
                                  : isSelected
                                      ? Colors.orange
                                      : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            word,
                            style: TextStyle(
                              fontSize: Responsive.scale(context, 14, 16, 18),
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : isMatched
                                      ? Colors.green[900]
                                      : Colors.black87,
                              decoration: isMatched
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
