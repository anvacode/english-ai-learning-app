import 'package:flutter/material.dart';

import '../../logic/tutorial_service.dart';
import '../../theme/app_colors.dart';
import '../home_screen.dart';

/// Tutorial interactivo que se muestra después de crear cuenta.
///
/// Diseñado para niños pequeños con:
/// - Textos grandes y simples
/// - Animaciones divertidas (rebote, escalado)
/// - Botones grandes y coloridos
/// - Flechas animadas señalando elementos
/// - 5 páginas explicativas
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 15.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _completeTutorial() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);

    await TutorialService.setTutorialCompleted();

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
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          _buildPage1(),
          _buildPage2(),
          _buildPage3(),
          _buildPage4(),
          _buildPage5(),
        ],
      ),
    );
  }

  /// Página 1: Bienvenida + Pantalla de inicio
  Widget _buildPage1() {
    return _TutorialPage(
      gradientColors: [AppColors.primary, AppColors.primaryLight],
      icon: Icons.home,
      iconColor: Colors.white,
      title: '¡Hola! 👋',
      description: 'Esta es tu pantalla de inicio.\nAquí verás todas tus lecciones.',
      currentPage: _currentPage,
      totalPages: 5,
      onNext: () => _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      showSkip: false,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMockHomeGrid(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildArrowPointer(),
                      const SizedBox(width: 12),
                      Text(
                        '¡Toca aquí para empezar!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Página 2: Cómo elegir lecciones
  Widget _buildPage2() {
    return _TutorialPage(
      gradientColors: [AppColors.success, AppColors.successLight],
      icon: Icons.menu_book,
      iconColor: Colors.white,
      title: 'Elige una lección 📚',
      description: 'Toca cualquier lección para empezar a aprender.',
      currentPage: _currentPage,
      totalPages: 5,
      onNext: () => _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMockLessonList(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildArrowPointer(),
                      const SizedBox(width: 12),
                      Text(
                        'Toca una lección',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.successDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Página 3: Escuchar y repetir
  Widget _buildPage3() {
    return _TutorialPage(
      gradientColors: [AppColors.orangeSun, AppColors.warningLight],
      icon: Icons.mic,
      iconColor: Colors.white,
      title: 'Escucha y repite 🎤',
      description: 'Toca el altavoz para escuchar.\nToca el micrófono para practicar.',
      currentPage: _currentPage,
      totalPages: 5,
      onNext: () => _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAudioButton(),
                      const SizedBox(width: 40),
                      _buildMicButton(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildArrowPointer(),
                      const SizedBox(width: 12),
                      Text(
                        '¡Practica tu pronunciación!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Página 4: Ganar estrellas
  Widget _buildPage4() {
    return _TutorialPage(
      gradientColors: [AppColors.starGold, AppColors.warning],
      icon: Icons.star,
      iconColor: Colors.white,
      title: 'Gana estrellas ⭐',
      description: 'Completa lecciones para ganar estrellas.\n¡Colecciona todas las que puedas!',
      currentPage: _currentPage,
      totalPages: 5,
      onNext: () => _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.star,
                                size: 40,
                                color: AppColors.starGold,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildArrowPointer(),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '¡Completa lecciones para ganar!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warningDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Página 5: Practica cuando quieras
  Widget _buildPage5() {
    return _TutorialPage(
      gradientColors: [AppColors.pinkFun, AppColors.secondaryLight],
      icon: Icons.play_circle,
      iconColor: Colors.white,
      title: '¡A practicar! 🎮',
      description: 'En la sección Práctica puedes repasar\nlo que aprendiste.',
      currentPage: _currentPage,
      totalPages: 5,
      onNext: () => _completeTutorial(),
      isLastPage: true,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.gamepad,
                    size: 60,
                    color: AppColors.pinkFun,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildArrowPointer(),
                      const SizedBox(width: 12),
                      Text(
                        '¡Diviértete practicando!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pinkFun,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMockHomeGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildMockCard('Frutas', Icons.apple, AppColors.success),
        _buildMockCard('Animales', Icons.pets, AppColors.orangeSun),
        _buildMockCard('Números', Icons.looks_one, AppColors.primary),
        _buildMockCard('Familia', Icons.family_restroom, AppColors.pinkFun),
      ],
    );
  }

  Widget _buildMockCard(String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(100), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockLessonList() {
    return Column(
      children: [
        _buildMockLessonItem('Lección 1', 'Frutas', AppColors.success, true),
        const SizedBox(height: 8),
        _buildMockLessonItem('Lección 2', 'Animales', AppColors.orangeSun, false),
        const SizedBox(height: 8),
        _buildMockLessonItem('Lección 3', 'Números', AppColors.primary, false),
      ],
    );
  }

  Widget _buildMockLessonItem(
    String lesson,
    String topic,
    Color color,
    bool completed,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: completed ? color.withAlpha(60) : color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100), width: 2),
      ),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  topic,
                  style: TextStyle(fontSize: 12, color: color.withAlpha(180)),
                ),
              ],
            ),
          ),
          if (completed)
            Icon(Icons.star, size: 20, color: AppColors.starGold),
        ],
      ),
    );
  }

  Widget _buildAudioButton() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(80),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.volume_up,
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Escuchar',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMicButton() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withAlpha(80),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.mic,
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hablar',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildArrowPointer() {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_bounceAnimation.value * 0.5, 0),
          child: Icon(
            Icons.touch_app,
            size: 28,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

/// Widget base para cada página del tutorial
class _TutorialPage extends StatelessWidget {
  final List<Color> gradientColors;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Widget child;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final bool showSkip;
  final bool isLastPage;

  const _TutorialPage({
    required this.gradientColors,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.child,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    this.showSkip = true,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header con icono y título
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(60),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 40,
                            color: iconColor,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Contenido interactivo
            Expanded(child: child),

            // Indicadores de página y botones
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalPages, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentPage == index
                              ? Colors.white
                              : Colors.white.withAlpha(100),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Botones
                  Row(
                    children: [
                      if (showSkip)
                        Expanded(
                          child: TextButton(
                            onPressed: onNext,
                            child: Text(
                              isLastPage ? '¡Empezar!' : 'Saltar',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: gradientColors[0],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            isLastPage ? '¡Listo!' : 'Siguiente',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
