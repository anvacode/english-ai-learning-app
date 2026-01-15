import 'package:flutter/material.dart';
import '../models/matching_item.dart';
import '../models/activity_result.dart';
import '../logic/activity_result_service.dart';
import '../widgets/lesson_image.dart';
import '../widgets/speaker_button.dart';
import '../services/audio_service.dart';

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

  @override
  void initState() {
    super.initState();
    _matchedIds = {};
    _resetSelection();
    _audioService.initialize();
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
    final item = widget.items.firstWhere((i) => i.id == _selectedImageId);
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
                  Navigator.pop(context, true); // Return to lessons with true flag
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emparejar palabras con imágenes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: widget.progressOffset + 
                        (_matchedIds.length / widget.items.length) * widget.progressScale,
                    backgroundColor: Colors.grey[300],
                    color: Colors.deepPurple,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_matchedIds.length} / ${widget.items.length} parejas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Images and words layout
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Images column
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: widget.items
                              .map((item) => _buildImageButton(item))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Words column
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: widget.items
                              .map((item) => _buildWordButton(item.correctWord))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Feedback and action button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_feedbackMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        _feedbackMessage!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _lastCorrect! ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          (_selectedImageId != null && _selectedWord != null)
                              ? _attemptMatch
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: const Text(
                        'Emparejar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildImageButton(MatchingItem item) {
    final isMatched = _matchedIds.contains(item.id);
    final isSelected = _selectedImageId == item.id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: isMatched ? null : () => _selectImage(item.id),
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
              width: isSelected ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isMatched ? Colors.green[50] : Colors.white,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: LessonImage(
                  imagePath: item.imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Matched checkmark
              if (isMatched)
                Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(
                      child: Text(
                        '✓',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
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
    final isUsedInMatch =
        _matchedIds.any((id) => widget.items.firstWhere((i) => i.id == id).correctWord == word);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 48,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              if (!isUsedInMatch)
                SpeakerButton(
                  text: word,
                  iconSize: 18,
                  buttonSize: 32,
                  iconColor: isSelected ? Colors.white : Colors.deepPurple,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
