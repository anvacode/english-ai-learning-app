import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Mock de una lección individual con interacción.
///
/// Muestra una palabra, botones de audio/micrófono y opciones de respuesta.
/// Usado en los pasos 3 y 4 del tutorial.
class TutorialLessonDetailMock extends StatefulWidget {
  final bool showInteraction;
  final VoidCallback? onAudioTap;
  final VoidCallback? onAnswerTap;
  final VoidCallback? onStarsTap;

  const TutorialLessonDetailMock({
    super.key,
    this.showInteraction = true,
    this.onAudioTap,
    this.onAnswerTap,
    this.onStarsTap,
  });

  @override
  State<TutorialLessonDetailMock> createState() =>
      TutorialLessonDetailMockState();
}

class TutorialLessonDetailMockState extends State<TutorialLessonDetailMock>
    with TickerProviderStateMixin {
  int? _selectedAnswer;
  bool _isCorrect = false;
  bool _showFeedback = false;
  bool _audioPlaying = false;
  bool _micActive = false;

  late AnimationController _audioController;
  late AnimationController _micController;

  final List<String> _options = ['Apple', 'Banana', 'Orange', 'Grape'];
  final int _correctIndex = 0;

  final GlobalKey _audioButtonKey = GlobalKey();
  final GlobalKey _starsKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _audioController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _micController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    // Detener controllers antes de dispose
    _micController.stop();
    _audioController.stop();
    _audioController.dispose();
    _micController.dispose();
    super.dispose();
  }

  void _handleAudioTap() {
    if (_audioPlaying) return;
    setState(() => _audioPlaying = true);
    _audioController.forward().then((_) => _audioController.reverse()).then((_) {
      if (mounted) {
        setState(() => _audioPlaying = false);
      }
    });
    widget.onAudioTap?.call();
  }

  void _handleMicTap() {
    if (!mounted) return;
    setState(() => _micActive = !_micActive);
    if (_micActive) {
      _micController.repeat(reverse: true);
    } else {
      _micController.stop();
    }
  }

  void _handleAnswerTap(int index) {
    if (_showFeedback) return;
    setState(() {
      _selectedAnswer = index;
      _isCorrect = index == _correctIndex;
      _showFeedback = true;
    });
    if (index == _correctIndex) {
      widget.onAnswerTap?.call();
    }
  }

  void _handleStarsTap() {
    widget.onStarsTap?.call();
  }

  Rect getAudioButtonRect(BuildContext context) {
    final renderBox = _audioButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final topLeft = renderBox.localToGlobal(Offset.zero);
      return Rect.fromLTWH(
        topLeft.dx,
        topLeft.dy,
        renderBox.size.width,
        renderBox.size.height,
      );
    }
    // Fallback a posición estimada
    final size = MediaQuery.of(context).size;
    return Rect.fromCenter(
      center: Offset(size.width * 0.35, size.height * 0.52),
      width: 80,
      height: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frutas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        actions: [
          GestureDetector(
            key: _starsKey,
            onTap: _handleStarsTap,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 4),
                  Text('0', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de progreso
          Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.25,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          // Imagen/emoji de la palabra
          Expanded(
            flex: 3,
            child: Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🍎', style: TextStyle(fontSize: 80)),
                ),
              ),
            ),
          ),

          // Botones de audio y micrófono
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón de altavoz
                GestureDetector(
                  key: _audioButtonKey,
                  onTap: widget.showInteraction ? _handleAudioTap : null,
                  child: AnimatedBuilder(
                    animation: _audioController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + _audioController.value * 0.2,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: _audioPlaying
                                ? AppColors.primary.withAlpha(51)
                                : AppColors.primary.withAlpha(20),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.volume_up,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 40),

                // Botón de micrófono
                GestureDetector(
                  onTap: widget.showInteraction ? _handleMicTap : null,
                  child: AnimatedBuilder(
                    animation: _micController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + _micController.value * 0.15,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: _micActive
                                ? AppColors.secondary.withAlpha(51)
                                : AppColors.secondary.withAlpha(20),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.secondary,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.mic,
                            size: 32,
                            color: AppColors.secondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Opciones de respuesta
          if (widget.showInteraction)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Qué es esto?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(_options.length, (index) {
                      final isSelected = _selectedAnswer == index;
                      final isCorrectOption = index == _correctIndex;
                      final showCorrect = _showFeedback && isCorrectOption;
                      final showWrong = _showFeedback && isSelected && !_isCorrect;

                      Color borderColor = Colors.grey[300]!;
                      Color bgColor = Colors.white;
                      Color textColor = const Color(0xFF2D3748);

                      if (showCorrect) {
                        borderColor = Colors.green;
                        bgColor = Colors.green.withAlpha(30);
                        textColor = Colors.green[700]!;
                      } else if (showWrong) {
                        borderColor = Colors.red;
                        bgColor = Colors.red.withAlpha(30);
                        textColor = Colors.red[700]!;
                      } else if (isSelected) {
                        borderColor = AppColors.primary;
                        bgColor = AppColors.primary.withAlpha(20);
                      }

                      return GestureDetector(
                        onTap: () => _handleAnswerTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _options[index],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (showCorrect)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              if (showWrong)
                                const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
