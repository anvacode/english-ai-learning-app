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

  double _getEmojiSize(double width) {
    if (width < 400) return 50;
    if (width < 600) return 60;
    if (width < 900) return 70;
    if (width < 1200) return 60;
    return 50;
  }

  double _getOptionSize(double width) {
    if (width < 400) return 45;
    if (width < 600) return 50;
    if (width < 900) return 60;
    return 50;
  }

  double _getFontSize(double width, {bool isLarge = false}) {
    if (width < 400) return isLarge ? 16 : 18;
    if (width < 600) return isLarge ? 18 : 22;
    if (width < 900) return isLarge ? 20 : 26;
    if (width < 1200) return isLarge ? 18 : 24;
    return isLarge ? 16 : 22;
  }

  double _getSpacing(double width) {
    if (width < 600) return 12;
    if (width < 900) return 20;
    return 16;
  }

  int _getGridColumns(double width) {
    if (width < 600) return 2;
    if (width < 900) return 2;
    if (width < 1200) return 4;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final emojiSize = _getEmojiSize(width);
    final optionSize = _getOptionSize(width);
    final fontSize = _getFontSize(width);
    final largeFontSize = _getFontSize(width, isLarge: true);
    final spacing = _getSpacing(width);
    final gridColumns = _getGridColumns(width);

    final isCompact = width < 600;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4FC3F7), Color(0xFF2196F3)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(isCompact, fontSize, spacing),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildQuestionCard(
                        emojiSize,
                        optionSize,
                        fontSize,
                        largeFontSize,
                        spacing,
                        gridColumns,
                        isCompact,
                        height,
                      ),
                    ),
                  ),
                ),
                _buildBottomNavigation(isCompact, fontSize, spacing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isCompact, double fontSize, double spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 12 : 16,
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
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
    double fontSize,
    double largeFontSize,
    double spacing,
    int gridColumns,
    bool isCompact,
    double height,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height * 0.7),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: spacing),
              Text(
                _currentQuestion.mainEmoji,
                style: TextStyle(fontSize: emojiSize),
              ),
              SizedBox(height: spacing * 1.5),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 500),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing * 1.5,
                  vertical: spacing,
                ),
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
                    fontSize: largeFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: spacing * 2),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: gridColumns,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: 1.8,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(_currentQuestion.options.length, (
                  index,
                ) {
                  return _buildOptionButton(index, optionSize, fontSize);
                }),
              ),
              SizedBox(height: spacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(int index, double size, double fontSize) {
    final isSelected = _answers[_currentQuestionIndex] == index;
    final option = _currentQuestion.options[index];

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF4CAF50).withAlpha(100)
                  : Colors.black.withAlpha(15),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              option,
              style: TextStyle(
                fontSize: size * 0.55,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(
    bool isCompact,
    double fontSize,
    double spacing,
  ) {
    final hasAnswer = _answers[_currentQuestionIndex] != null;
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return Padding(
      padding: EdgeInsets.all(spacing),
      child: SizedBox(
        width: double.infinity,
        height: isCompact ? 50 : 60,
        child: ElevatedButton.icon(
          onPressed: hasAnswer && !_isSubmitting ? _nextQuestion : null,
          icon: _isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isLastQuestion ? Icons.check : Icons.arrow_forward,
                  size: isCompact ? 24 : 28,
                ),
          label: Text(
            isLastQuestion ? 'Finish!' : 'Next',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
          ),
        ),
      ),
    );
  }
}
