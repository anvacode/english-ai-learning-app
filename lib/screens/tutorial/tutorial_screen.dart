import 'package:flutter/material.dart';

import '../../logic/tutorial_service.dart';
import '../../widgets/coach_mark_overlay.dart';
import '../../widgets/tutorial_confetti.dart';
import '../../widgets/tutorial_mascot.dart';
import '../../widgets/tutorial_progress_bar.dart';
import '../home_screen.dart';
import 'mocks/tutorial_home_mock.dart';
import 'mocks/tutorial_lesson_detail_mock.dart';
import 'mocks/tutorial_lessons_mock.dart';

/// Tutorial interactivo con coach marks sobre pantallas mock.
///
/// Diseñado para niños pequeños con:
/// - Pantallas mock que se ven como la app real
/// - Búho guía con bocadillo de diálogo
/// - Overlay oscuro con highlight pulsante
/// - El niño debe TOCAR para avanzar
/// - Celebraciones con confetti
/// - 7 pasos interactivos
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isCompleting = false;
  bool _showCelebration = false;
  bool _showFinalConfetti = false;
  bool _mascotJump = false;

  final List<_TutorialStep> _steps = [
    _TutorialStep(
      instruction: '¡Toca aquí para ver tus lecciones!',
      screenType: ScreenType.home,
      highlightType: HighlightType.lessonsCard,
      isCircular: false,
      requiresSpecificTap: false,
    ),
    _TutorialStep(
      instruction: '¡Toca una lección para empezar!',
      screenType: ScreenType.lessons,
      highlightType: HighlightType.firstLesson,
      isCircular: false,
      requiresSpecificTap: false,
    ),
    _TutorialStep(
      instruction: '¡Toca el altavoz para escuchar!',
      screenType: ScreenType.lessonDetail,
      highlightType: HighlightType.audioButton,
      isCircular: true,
      requiresSpecificTap: true,
    ),
    _TutorialStep(
      instruction: '¡Toca la respuesta correcta!',
      screenType: ScreenType.lessonDetail,
      highlightType: HighlightType.answerOptions,
      isCircular: false,
      requiresSpecificTap: true,
    ),
    _TutorialStep(
      instruction: '¡Toca las estrellas para recogerlas!',
      screenType: ScreenType.home,
      highlightType: HighlightType.stars,
      isCircular: true,
      requiresSpecificTap: true,
    ),
    _TutorialStep(
      instruction: '¡Toca aquí para ir a la tienda!',
      screenType: ScreenType.home,
      highlightType: HighlightType.shopCard,
      isCircular: false,
      requiresSpecificTap: false,
    ),
    _TutorialStep(
      instruction: '¡Toca aquí para practicar!',
      screenType: ScreenType.home,
      highlightType: HighlightType.practiceTab,
      isCircular: false,
      requiresSpecificTap: false,
    ),
  ];

  @override
  void dispose() {
    super.dispose();
  }

  void _handleTapOutsideHighlight(Offset tapPosition) {
    final step = _steps[_currentStep];

    // Para pasos que requieren tap específico, no hacer nada
    // (el tap pasa al botón interactivo)
    if (step.requiresSpecificTap) {
      return;
    }

    // Verificar si el tap está fuera del highlight
    final highlight = _getHighlightRect(context, step);
    final expanded = highlight.inflate(step.isCircular ? 12 : 16);

    if (!expanded.contains(tapPosition)) {
      _advanceStep();
    }
  }

  void _advanceStep() {
    setState(() {
      _mascotJump = true;
      _showCelebration = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      if (_currentStep < _steps.length - 1) {
        setState(() {
          _currentStep++;
          _showCelebration = false;
          _mascotJump = false;
        });
      } else {
        _completeTutorial();
      }
    });
  }

  Future<void> _completeTutorial() async {
    if (_isCompleting) return;
    setState(() {
      _isCompleting = true;
      _showCelebration = false;
      _showFinalConfetti = true;
    });

    await TutorialService.setTutorialCompleted();

    await Future.delayed(const Duration(milliseconds: 3000));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _steps[_currentStep];

    return Scaffold(
      body: Stack(
        children: [
          // Pantalla mock
          _buildCurrentScreen(currentStep),

          // Overlay visual (solo dibuja, NO captura gestos)
          CoachMarkVisual(
            highlightRect: _getHighlightRect(context, currentStep),
            isCircular: currentStep.isCircular,
            showPulse: true,
          ),

          // Capturador de taps FUERA del highlight
          // Para pasos que NO requieren tap específico, avanza al tocar fuera
          if (!currentStep.requiresSpecificTap)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (details) {
                _handleTapOutsideHighlight(details.localPosition);
              },
              child: const SizedBox.expand(),
            ),

          // Barra de progreso con estrellas
          TutorialProgressBar(
            currentStep: _currentStep,
            totalSteps: _steps.length,
          ),

          // Búho guía
          TutorialMascot(
            instruction: currentStep.instruction,
            animateJump: _mascotJump,
          ),

          // Celebración mini
          if (_showCelebration)
            Center(child: MiniCelebration(onComplete: () {})),

          // Confetti final
          if (_showFinalConfetti)
            TutorialConfetti(
              duration: const Duration(seconds: 3),
              onComplete: () {},
            ),

          // Botón de saltar
          Positioned(
            top: 40,
            right: 16,
            child: TextButton(
              onPressed: _completeTutorial,
              child: Text(
                'Saltar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha(150),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen(_TutorialStep step) {
    // Usar ValueKey para forzar recreación limpia al cambiar de paso
    // Esto previene errores de AnimationController entre pantallas
    switch (step.screenType) {
      case ScreenType.home:
        return TutorialHomeMock(key: ValueKey('home_$_currentStep'));
      case ScreenType.lessons:
        return TutorialLessonsMock(key: ValueKey('lessons_$_currentStep'));
      case ScreenType.lessonDetail:
        return TutorialLessonDetailMock(
          key: ValueKey('lesson_detail_$_currentStep'),
          showInteraction: true,
          onAudioTap: step.highlightType == HighlightType.audioButton
              ? _advanceStep
              : null,
          onAnswerTap: step.highlightType == HighlightType.answerOptions
              ? _advanceStep
              : null,
          onStarsTap: step.highlightType == HighlightType.stars
              ? _advanceStep
              : null,
        );
    }
  }

  Rect _getHighlightRect(BuildContext context, _TutorialStep step) {
    final size = MediaQuery.of(context).size;
    final type = step.highlightType;

    switch (type) {
      case HighlightType.lessonsCard:
        return Rect.fromCenter(
          center: Offset(size.width * 0.26, size.height * 0.29),
          width: size.width * 0.43,
          height: size.height * 0.27,
        );

      case HighlightType.firstLesson:
        return Rect.fromCenter(
          center: Offset(size.width * 0.50, size.height * 0.30),
          width: size.width * 0.85,
          height: size.height * 0.10,
        );

      case HighlightType.audioButton:
        return Rect.fromCenter(
          center: Offset(size.width * 0.35, size.height * 0.52),
          width: 90,
          height: 90,
        );

      case HighlightType.answerOptions:
        return Rect.fromCenter(
          center: Offset(size.width * 0.50, size.height * 0.72),
          width: size.width * 0.85,
          height: size.height * 0.25,
        );

      case HighlightType.stars:
        return Rect.fromCenter(
          center: Offset(size.width * 0.88, 50),
          width: 80,
          height: 40,
        );

      case HighlightType.shopCard:
        return Rect.fromCenter(
          center: Offset(size.width * 0.74, size.height * 0.58),
          width: size.width * 0.43,
          height: size.height * 0.27,
        );

      case HighlightType.practiceTab:
        return Rect.fromCenter(
          center: Offset(size.width * 0.62, size.height - 35),
          width: 90,
          height: 55,
        );
    }
  }
}

enum ScreenType { home, lessons, lessonDetail }

enum HighlightType {
  lessonsCard,
  firstLesson,
  audioButton,
  answerOptions,
  stars,
  shopCard,
  practiceTab,
}

class _TutorialStep {
  final String instruction;
  final ScreenType screenType;
  final HighlightType highlightType;
  final bool isCircular;
  final bool requiresSpecificTap;

  _TutorialStep({
    required this.instruction,
    required this.screenType,
    required this.highlightType,
    this.isCircular = false,
    this.requiresSpecificTap = false,
  });
}
