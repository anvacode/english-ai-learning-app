import 'package:flutter/material.dart';
import '../../models/diagnostic_question.dart';
import '../../data/diagnostic_questions_data.dart';
import '../../services/diagnostic_service.dart';
import 'diagnostic_result_screen.dart';

class DiagnosticTestScreen extends StatefulWidget {
  const DiagnosticTestScreen({super.key});

  @override
  State<DiagnosticTestScreen> createState() => _DiagnosticTestScreenState();
}

class _DiagnosticTestScreenState extends State<DiagnosticTestScreen>
    with TickerProviderStateMixin {
  final List<DiagnosticQuestion> _questions = DiagnosticQuestionsData.questions;
  final List<int?> _answers = List.filled(
    DiagnosticQuestionsData.questions.length,
    null,
  );

  int _currentQuestionIndex = 0;
  bool _isSubmitting = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  DiagnosticQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  double get _progress => (_currentQuestionIndex + 1) / _questions.length;

  void _selectAnswer(int index) {
    setState(() {
      _answers[_currentQuestionIndex] = index;
    });
  }

  void _nextQuestion() {
    if (_answers[_currentQuestionIndex] == null) return;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _submitTest();
    }
  }

  Future<void> _submitTest() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final result = DiagnosticService.calculateResult(_answers);
    await DiagnosticService.saveDiagnosticResult(result);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DiagnosticResultScreen(result: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final emojiSize = isMobile ? 80.0 : 120.0;
    final optionSize = isMobile ? 60.0 : 80.0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4FC3F7), Color(0xFF2196F3)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(isMobile),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildQuestionCard(
                        emojiSize,
                        optionSize,
                        isMobile,
                      ),
                    ),
                  ),
                ),
                _buildBottomNavigation(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${_currentQuestionIndex + 1} / ${_questions.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white.withAlpha(50),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    double emojiSize,
    double optionSize,
    bool isMobile,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji principal grande
          Text(
            _currentQuestion.mainEmoji,
            style: TextStyle(fontSize: emojiSize),
          ),
          const SizedBox(height: 24),
          // Pregunta
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Text(
              _currentQuestion.question,
              style: TextStyle(
                fontSize: isMobile ? 22 : 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          // Opciones en grid 2x2
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(_currentQuestion.options.length, (index) {
              return _buildOptionButton(index, optionSize);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(int index, double size) {
    final isSelected = _answers[_currentQuestionIndex] == index;
    final option = _currentQuestion.options[index];

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF4CAF50).withAlpha(100)
                  : Colors.black.withAlpha(15),
              blurRadius: isSelected ? 15 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            option,
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final hasAnswer = _answers[_currentQuestionIndex] != null;
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton.icon(
          onPressed: hasAnswer && !_isSubmitting ? _nextQuestion : null,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isLastQuestion ? Icons.check : Icons.arrow_forward,
                  size: 28,
                ),
          label: Text(
            isLastQuestion ? 'Finish!' : 'Next',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
          ),
        ),
      ),
    );
  }
}
