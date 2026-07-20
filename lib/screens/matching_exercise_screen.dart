import 'dart:math' show Random;

import 'package:flutter/material.dart';

import '../logic/activity_result_service.dart';
import '../models/activity_result.dart';
import '../models/matching_item.dart';
import '../services/audio_service.dart';
import '../theme/text_styles.dart';
import '../utils/responsive.dart';
import '../widgets/lesson_image.dart';
import '../widgets/responsive_container.dart';
import '../widgets/speaker_button.dart';

class MatchingExerciseScreen extends StatefulWidget {
  final String lessonId;
  final String title;
  final List<MatchingItem> items;
  final VoidCallback? onComplete; // Optional callback for flow orchestration
  final double progressOffset; // Progress offset when used in flow (0.0-1.0)
  final double progressScale; // Progress scale when used in flow (0.0-1.0)

  const MatchingExerciseScreen({
    super.key,
    required this.lessonId,
    required this.title,
    required this.items,
    this.onComplete,
    this.progressOffset = 0.0,
    this.progressScale = 1.0,
  });

  @override
  State<MatchingExerciseScreen> createState() => _MatchingExerciseScreenState();
}

class _MatchingExerciseScreenState extends State<MatchingExerciseScreen> {
  // Track matched pairs
  late Set<String> _matchedIds;

  // Current selection state
  String? _selectedImageId;
  String? _selectedWord;

  // Feedback state
  String? _feedbackMessage;
  bool? _lastCorrect;

  // Audio service
  final AudioService _audioService = AudioService();

  // Shuffled words for randomization
  late List<String> _shuffledWords;

  @override
  void initState() {
    super.initState();
    _matchedIds = {};
    _resetSelection();
    _audioService.initialize();
    _shuffleWords();
  }

  /// Mezcla las palabras para que no aparezcan en el mismo orden que las imágenes
  void _shuffleWords() {
    _shuffledWords = widget.items.map((item) => item.correctWord).toList();
    _shuffledWords.shuffle(Random());
  }

  void _resetSelection() {
    setState(() {
      _selectedImageId = null;
      _selectedWord = null;
      _feedbackMessage = null;
      _lastCorrect = null;
    });
  }

  void _selectImage(String itemId) {
    setState(() {
      _selectedImageId = itemId;
      _feedbackMessage = null;
    });
  }

  void _selectWord(String word) {
    setState(() {
      _selectedWord = word;
      _feedbackMessage = null;
    });
  }

  Future<void> _attemptMatch() async {
    if (_selectedImageId == null || _selectedWord == null) return;

    // Play click sound
    await _audioService.playClickSound();

    // Find the matching item
    final item = widget.items.firstWhere(
      (i) => i.id == _selectedImageId,
      orElse: () => widget.items.first,
    );
    final isCorrect = item.correctWord == _selectedWord;

    if (isCorrect) {
      // Play correct sound
      await _audioService.playCorrectSound();

      // Lock the pair
      setState(() {
        _matchedIds.add(_selectedImageId!);
        _lastCorrect = true;
        _feedbackMessage = '✓ ¡Correcto!';
      });

      // Check if all pairs are matched
      if (_matchedIds.length == widget.items.length) {
        _onExerciseComplete();
      } else {
        // Reset selection after success
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _resetSelection();
          }
        });
      }
    } else {
      // Play wrong sound
      await _audioService.playWrongSound();

      // Incorrect attempt
      setState(() {
        _lastCorrect = false;
        _feedbackMessage = '✗ Intenta de nuevo';
      });
    }
  }

  Future<void> _onExerciseComplete() async {
    // Save the result
    final result = ActivityResult(
      lessonId: widget.lessonId,
      itemId: 'matching_exercise',
      isCorrect: true,
      timestamp: DateTime.now(),
    );

    await ActivityResultService.saveActivityResult(result);

    // Exercise completed successfully
    // Evaluate lesson progress happens automatically when next item is attempted

    // If onComplete callback is provided (flow mode), call it
    if (widget.onComplete != null) {
      if (mounted) {
        widget.onComplete!();
      }
    } else {
      // Standalone mode: show completion dialog and return
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('¡Felicidades!'),
            content: const Text('Completaste el ejercicio de matching.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(
                    context,
                    true,
                  ); // Return to lessons with true flag
                },
                child: const Text('Continuar'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPadding = Responsive.scale(context, 10, 12, 16);
    final vPadding = Responsive.scale(context, 8, 12, 14);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ResponsiveContainer(
        child: SafeArea(
          child: Column(
            children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPadding, vPadding, hPadding, vPadding * 0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emparejar palabras con imágenes',
                    style: context.bodyText2.copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: Responsive.scale(context, 4, 6, 8)),
                  LinearProgressIndicator(
                    value:
                        widget.progressOffset +
                        (_matchedIds.length / widget.items.length) *
                            widget.progressScale,
                    backgroundColor: Colors.grey[300],
                    color: Colors.deepPurple,
                    minHeight: Responsive.scale(context, 5, 6, 8),
                  ),
                  SizedBox(height: Responsive.scale(context, 2, 3, 4)),
                  Text(
                    '${_matchedIds.length} / ${widget.items.length} parejas',
                    style: context.caption,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: widget.items
                              .map((item) => _buildImageButton(item))
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.scale(context, 8, 12, 16)),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: _shuffledWords
                              .map((word) => _buildWordButton(word))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPadding, vPadding * 0.6, hPadding, vPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_feedbackMessage != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: Responsive.scale(context, 6, 8, 10)),
                      child: Text(
                        _feedbackMessage!,
                        style: TextStyle(
                          fontSize: Responsive.scale(context, 13, 14, 15),
                          fontWeight: FontWeight.bold,
                          color: _lastCorrect!
                              ? Colors.green[700]
                              : Colors.red[700],
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: Responsive.buttonHeight(context) * 0.85,
                    child: ElevatedButton(
                      onPressed:
                          (_selectedImageId != null && _selectedWord != null)
                          ? _attemptMatch
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: Text(
                        'Emparejar',
                        style: context.buttonText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildImageButton(MatchingItem item) {
    final isMatched = _matchedIds.contains(item.id);
    final isSelected = _selectedImageId == item.id;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.scale(context, 4, 5, 6)),
      child: GestureDetector(
        onTap: isMatched ? null : () => _selectImage(item.id),
        child: Container(
          width: double.infinity,
          height: Responsive.scale(context, 85, 90, 95),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
              width: isSelected ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(Responsive.borderRadius(context) - 4),
            color: isMatched ? Colors.green[50] : Colors.white,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.deepPurple.withAlpha(76),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Container(
                color: Colors.grey[50],
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Responsive.borderRadius(context) - 5),
                  child: LessonImage(
                    imagePath: item.imagePath,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              if (isMatched)
                Center(
                  child: Container(
                    width: Responsive.scale(context, 36, 40, 44),
                    height: Responsive.scale(context, 36, 40, 44),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(Responsive.scale(context, 18, 20, 22)),
                    ),
                    child: Center(
                      child: Text(
                        '✓',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.scale(context, 22, 26, 30),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordButton(String word) {
    final isSelected = _selectedWord == word;
    final isUsedInMatch = _matchedIds.any(
      (id) =>
          widget.items
              .firstWhere((i) => i.id == id, orElse: () => widget.items.first)
              .correctWord ==
          word,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.scale(context, 4, 5, 6)),
      child: SizedBox(
        width: double.infinity,
        height: Responsive.scale(context, 44, 50, 54),
        child: ElevatedButton(
          onPressed: isUsedInMatch ? null : () => _selectWord(word),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.deepPurple : Colors.grey[200],
            disabledBackgroundColor: Colors.green[100],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                word,
                style: TextStyle(
                  fontSize: Responsive.scale(context, 14, 16, 18),
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              if (!isUsedInMatch)
                SpeakerButton(
                  text: word,
                  iconSize: Responsive.scale(context, 16, 18, 20),
                  buttonSize: Responsive.scale(context, 28, 32, 36),
                  iconColor: isSelected ? Colors.white : Colors.deepPurple,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
