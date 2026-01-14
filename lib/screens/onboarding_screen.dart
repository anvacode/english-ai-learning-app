import 'package:flutter/material.dart';
import '../logic/first_time_service.dart';
import '../models/onboarding_page.dart';
import 'home_screen.dart';

/// Pantalla de onboarding con PageView que se muestra a usuarios nuevos.
/// 
/// Presenta 4 páginas explicando las características principales
/// de la aplicación de aprendizaje de inglés.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Datos de las páginas de onboarding
  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: 'Aprende inglés con juegos divertidos',
      description: 'Diviértete mientras aprendes nuevas palabras en inglés con actividades interactivas y emocionantes.',
      icon: Icons.games,
      backgroundColor: Color(0xFFFFE082), // Amarillo claro
    ),
    OnboardingPage(
      title: 'Relaciona imágenes con palabras',
      description: 'Mejora tu vocabulario relacionando imágenes coloridas con sus palabras en inglés.',
      icon: Icons.image_search,
      backgroundColor: Color(0xFFB2DFDB), // Turquesa claro
    ),
    OnboardingPage(
      title: 'Gana insignias completando lecciones',
      description: 'Completa lecciones y obtén insignias especiales por tus logros. ¡Conviértete en un experto!',
      icon: Icons.emoji_events,
      backgroundColor: Color(0xFFFFCCBC), // Naranja claro
    ),
    OnboardingPage(
      title: '¡Comienza tu viaje en inglés!',
      description: 'Estás listo para empezar. ¡Vamos a aprender juntos y hacer que aprender inglés sea divertido!',
      icon: Icons.rocket_launch,
      backgroundColor: Color(0xFFC5E1A5), // Verde claro
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    // Marcar que el usuario ya no es nuevo
    await FirstTimeService.setFirstTimeCompleted();
    
    // Navegar a HomeScreen
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Botón Skip (arriba a la derecha)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Omitir',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // PageView con las páginas de onboarding
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Indicadores de página (dots)
            _buildPageIndicators(),

            const SizedBox(height: 24),

            // Botón Next / Get Started
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Comenzar' : 'Siguiente',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      color: page.backgroundColor,
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustración (icono grande con fondo decorativo)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(height: 48),

          // Título
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Descripción
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => _buildIndicator(index == _currentPage),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
