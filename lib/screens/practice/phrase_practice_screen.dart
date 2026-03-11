import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/pronunciation_phrases_data.dart';
import '../../services/speech_recognition_service.dart';
import '../../services/audio_service.dart';
import '../../theme/app_colors.dart';

class PhrasePracticeScreen extends StatefulWidget {
  const PhrasePracticeScreen({super.key});

  @override
  State<PhrasePracticeScreen> createState() => _PhrasePracticeScreenState();
}

class _PhrasePracticeScreenState extends State<PhrasePracticeScreen>
    with SingleTickerProviderStateMixin {
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  final AudioService _audioService = AudioService();

  bool _isLoading = true;
  bool _isListening = false;
  bool _hasResult = false;

  List<PronunciationPhrase> _phrases = [];
  int _currentIndex = 0;

  PronunciationResult? _lastResult;
  String _statusMessage = 'Presiona el micrófono y pronuncia la frase';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initialize();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);

    final initialized = await _speechService.initialize();

    if (!initialized) {
      setState(() {
        _statusMessage = '❌ No se pudo acceder al micrófono';
        _isLoading = false;
      });
      return;
    }

    _phrases = _selectRandomPhrases();

    setState(() => _isLoading = false);
  }

  List<PronunciationPhrase> _selectRandomPhrases() {
    final allPhrases = List<PronunciationPhrase>.from(
      PronunciationPhrasesData.phrases,
    );
    final random = Random();

    final beginnerCount = 3 + random.nextInt(3);
    final intermediateCount = 2 + random.nextInt(2);

    final beginnerPhrases =
        allPhrases.where((p) => p.level == PhraseLevel.beginner).toList()
          ..shuffle(random);

    final intermediatePhrases =
        allPhrases.where((p) => p.level == PhraseLevel.intermediate).toList()
          ..shuffle(random);

    return [
      ...beginnerPhrases.take(beginnerCount),
      ...intermediatePhrases.take(intermediateCount),
    ]..shuffle(random);
  }

  Future<void> _startListening() async {
    if (_phrases.isEmpty) return;

    setState(() {
      _isListening = true;
      _hasResult = false;
      _statusMessage = '🎤 Escuchando...';
    });

    final currentPhrase = _phrases[_currentIndex];

    final result = await _speechService.listenAndEvaluatePhrase(
      currentPhrase.phrase,
      timeout: const Duration(seconds: 8),
    );

    if (mounted) {
      setState(() {
        _isListening = false;
        _hasResult = true;
        _lastResult = result;
        _statusMessage = result.message;
      });
    }
  }

  void _nextPhrase() {
    if (_currentIndex < _phrases.length - 1) {
      setState(() {
        _currentIndex++;
        _hasResult = false;
        _lastResult = null;
        _statusMessage = 'Presiona el micrófono y pronuncia la frase';
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎉 ', style: TextStyle(fontSize: 28)),
            Text('¡Práctica completada!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Has practicado ${_phrases.length} frases.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              '¡Sigue practicando para mejorar tu inglés!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Practicar de nuevo'),
          ),
        ],
      ),
    );
  }

  void _restartPractice() {
    setState(() {
      _currentIndex = 0;
      _hasResult = false;
      _lastResult = null;
      _statusMessage = 'Presiona el micrófono y pronuncia la frase';
    });
    _phrases = _selectRandomPhrases();
  }

  void _speakPhrase(String phrase) {
    _audioService.speak(phrase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Práctica de Frases'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_phrases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No hay frases disponibles'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      );
    }

    final currentPhrase = _phrases[_currentIndex];
    final progress = (_currentIndex + 1) / _phrases.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(progress),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildPhraseCard(currentPhrase),
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Frase ${_currentIndex + 1} de ${_phrases.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _phrases[_currentIndex].levelName,
                  style: TextStyle(
                    color: _phrases[_currentIndex].levelColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withAlpha(30),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhraseCard(PronunciationPhrase phrase) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          if (phrase.emoji != null)
            Text(phrase.emoji!, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: phrase.levelColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              phrase.levelName,
              style: TextStyle(
                color: phrase.levelColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Di esta frase:',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '"${phrase.phrase}"',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _speakPhrase(phrase.phrase),
                icon: const Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.primary,
                ),
                tooltip: 'Escuchar frase',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            phrase.translation,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          if (_hasResult && _lastResult != null) ...[
            const SizedBox(height: 24),
            _buildResultSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    final result = _lastResult!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: result.isCorrect
            ? Colors.green.withAlpha(20)
            : Colors.orange.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: result.isCorrect
              ? Colors.green.withAlpha(50)
              : Colors.orange.withAlpha(50),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < result.starRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32,
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            result.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: result.isCorrect ? Colors.green[700] : Colors.orange[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tú dijiste: "${result.recognizedText}"',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            _statusMessage,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_hasResult) ...[
                OutlinedButton.icon(
                  onPressed: _restartPractice,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Repetir',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isListening ? _pulseAnimation.value : 1.0,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: _isListening || _hasResult ? null : _startListening,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isListening
                          ? Colors.red
                          : (_hasResult ? Colors.grey : Colors.white),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.white : AppColors.primary,
                      size: 40,
                    ),
                  ),
                ),
              ),
              if (_hasResult) ...[
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _nextPhrase,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    _currentIndex < _phrases.length - 1
                        ? 'Siguiente'
                        : 'Finalizar',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
