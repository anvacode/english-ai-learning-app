import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/auth_provider.dart';
import '../../logic/tutorial_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/coach_mark_overlay.dart';
import '../../widgets/tutorial_confetti.dart';
import '../home/home_grid_view.dart';
import '../home_screen.dart';
import '../lessons_screen.dart';
import '../practice/practice_hub_screen.dart';

/// Tutorial interactivo con coach marks sobre la app real.
///
/// Diseñado para niños pequeños con interacción táctil:
/// - Overlay oscuro que resalta elementos importantes
/// - El niño debe TOCAR el elemento para avanzar
/// - Celebraciones con confetti en cada paso
/// - 5 pasos interactivos sobre pantallas reales
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

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<_TutorialStep> _steps = [
    _TutorialStep(
      instruction: '¡Toca una lección para empezar!',
      screenIndex: 0,
      highlightType: HighlightType.gridCards,
    ),
    _TutorialStep(
      instruction: '¡Toca la primera lección!',
      screenIndex: 1,
      highlightType: HighlightType.firstLesson,
    ),
    _TutorialStep(
      instruction: '¡Toca el altavoz para escuchar!',
      screenIndex: 1,
      highlightType: HighlightType.audioButton,
    ),
    _TutorialStep(
      instruction: '¡Toca las estrellas para recogerlas!',
      screenIndex: 0,
      highlightType: HighlightType.stars,
    ),
    _TutorialStep(
      instruction: '¡Toca aquí para practicar!',
      screenIndex: 2,
      highlightType: HighlightType.practiceTab,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleStepComplete() {
    setState(() {
      _showCelebration = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      if (_currentStep < _steps.length - 1) {
        setState(() {
          _currentStep++;
          _showCelebration = false;
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

    await Future.delayed(const Duration(milliseconds: 2500));

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
          // Pantalla real de la app
          _buildCurrentScreen(currentStep.screenIndex),

          // Overlay con coach mark
          CoachMarkOverlay(
            highlightRect: _getHighlightRect(context, currentStep.highlightType),
            instruction: currentStep.instruction,
            onTap: _handleStepComplete,
            isCircular: currentStep.highlightType == HighlightType.stars,
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

          // Indicador de progreso
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == _currentStep ? 32 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? AppColors.starGold
                        : Colors.white.withAlpha(100),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: index == _currentStep
                        ? [
                            BoxShadow(
                              color: AppColors.starGold.withAlpha(100),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ),
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
                      color: Colors.black.withAlpha(100),
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

  Widget _buildCurrentScreen(int screenIndex) {
    switch (screenIndex) {
      case 0:
        return const HomeGridView();
      case 1:
        return const LessonsScreen();
      case 2:
        return const PracticeHubScreen();
      default:
        return const HomeGridView();
    }
  }

  Rect _getHighlightRect(BuildContext context, HighlightType type) {
    final size = MediaQuery.of(context).size;

    switch (type) {
      case HighlightType.gridCards:
        // Resaltar el centro del grid de lecciones
        return Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2 - 40),
          width: size.width * 0.7,
          height: size.height * 0.35,
        );

      case HighlightType.firstLesson:
        // Resaltar la primera lección en la lista
        return Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.35),
          width: size.width * 0.85,
          height: 70,
        );

      case HighlightType.audioButton:
        // Resaltar área donde estaría el botón de audio
        return Rect.fromCenter(
          center: Offset(size.width * 0.35, size.height * 0.45),
          width: 80,
          height: 80,
        );

      case HighlightType.stars:
        // Resaltar el contador de estrellas (esquina superior)
        return Rect.fromCenter(
          center: Offset(size.width * 0.85, 50),
          width: 100,
          height: 50,
        );

      case HighlightType.practiceTab:
        // Resaltar el tab de Práctica en el bottom nav
        return Rect.fromCenter(
          center: Offset(size.width * 0.62, size.height - 50),
          width: 100,
          height: 70,
        );
    }
  }
}

enum HighlightType {
  gridCards,
  firstLesson,
  audioButton,
  stars,
  practiceTab,
}

class _TutorialStep {
  final String instruction;
  final int screenIndex;
  final HighlightType highlightType;

  _TutorialStep({
    required this.instruction,
    required this.screenIndex,
    required this.highlightType,
  });
}
