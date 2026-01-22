import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' show Random;
import '../../models/lesson_item.dart';
import '../../models/activity_result.dart';
import '../../logic/activity_result_service.dart';
import '../../logic/star_service.dart';
import '../../services/audio_service.dart';
import '../../widgets/lesson_image.dart';
import '../../data/lessons_data.dart';

/// Pantalla de Speed Match:
/// - Juego de matching contra el tiempo
/// - El jugador debe emparejar imágenes con palabras lo más rápido posible
/// - Bonos por tiempo restante
class SpeedMatchScreen extends StatefulWidget {
  final String lessonId;
  
  const SpeedMatchScreen({
    super.key,
    required this.lessonId,
  });
  
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
    final alreadyMatched = _items.any((item) =>
        _matchedIds.contains(item.id) &&
        item.options[item.correctAnswerIndex] == word);
    
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
    
    final item = _items.firstWhere((i) => i.id == _selectedImageId);
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ Speed Match'),
        actions: [
          // Timer display
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _secondsRemaining <= 10 ? Colors.red : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$_secondsRemaining',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            minHeight: 8,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Instruction
                  const Text(
                    '¡Empareja las imágenes con las palabras lo más rápido posible!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Score
                  Text(
                    'Correctos: $_correctMatches/${_items.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Images grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
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
                            borderRadius: BorderRadius.circular(12),
                            color: isMatched ? Colors.green[100] : Colors.white,
                          ),
                          child: isMatched
                              ? const Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 48,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LessonImage(
                                    imagePath: item.stimulusImageAsset,
                                    fallbackColor: item.stimulusColor,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Words list
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _items.map((item) {
                      final word = item.options[item.correctAnswerIndex];
                      final isMatched = _matchedIds.contains(item.id);
                      final isSelected = _selectedWord == word;
                      
                      return GestureDetector(
                        onTap: () => _selectWord(word),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
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
                              fontSize: 16,
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
