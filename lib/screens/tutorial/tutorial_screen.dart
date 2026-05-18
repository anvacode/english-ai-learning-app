import 'package:flutter/material.dart';

import '../../services/tutorial_service.dart';
import '../../theme/app_colors.dart';
import '../home_screen.dart';

/// Pantalla de tutorial estático con tarjetas deslizables.
///
/// Explica las funciones principales de la app de forma visual y clara,
/// usando emojis grandes, texto corto y colores vibrantes.
/// Accesible desde Configuración → "Ver tutorial".
class TutorialScreen extends StatefulWidget {
  final bool showPlayButton;

  const TutorialScreen({
    super.key,
    this.showPlayButton = true,
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_TutorialCardData> _cards = const [
    _TutorialCardData(
      emoji: '🏠',
      title: 'Tu Inicio',
      description:
          'Esta es tu casa en la app. Aquí ves tus estrellas, tus lecciones, tu perfil, logros y la tienda.',
      gradient: LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _TutorialCardData(
      emoji: '📚',
      title: 'Lecciones',
      description:
          'Elige entre 3 niveles: Principiante, Intermedio y Avanzado. Cada lección tiene juegos y preguntas.',
      gradient: LinearGradient(
        colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _TutorialCardData(
      emoji: '🎮',
      title: 'Práctica',
      description:
          'Juega a emparejar imágenes, practica tu pronunciación con el micrófono y desafía tu memoria.',
      gradient: LinearGradient(
        colors: [Color(0xFFfa709a), Color(0xFFfee140)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _TutorialCardData(
      emoji: '⭐',
      title: 'Estrellas y Tienda',
      description:
          'Gana estrellas al completar lecciones. Luego gástalas en la tienda para comprar colores y avatares.',
      gradient: LinearGradient(
        colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _TutorialCardData(
      emoji: '🏅',
      title: 'Logros',
      description:
          'Cada vez que terminas una lección, ganas una medalla especial. ¡Colecciona todas!',
      gradient: LinearGradient(
        colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _TutorialCardData(
      emoji: '👤',
      title: 'Tu Perfil',
      description:
          'Cambia tu foto, escoge un apodo, revisa tu historial y ajusta el audio a tu gusto.',
      gradient: LinearGradient(
        colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _cards.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    await TutorialService.markTutorialCompleted();
    if (!mounted) return;
    if (widget.showPlayButton) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _cards.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_currentPage + 1} / ${_cards.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Tarjetas deslizables
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _cards.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildCard(_cards[index]);
                },
              ),
            ),

            // Indicadores y botón
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicadores de página
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_cards.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Botón principal
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastPage ? '¡Empezar a jugar!' : 'Siguiente',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLastPage ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botón para ver tour guiado interactivo (solo en Configuración)
                  if (!widget.showPlayButton && isLastPage)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await TutorialService.requestInteractiveTutorial();
                          if (!context.mounted) return;
                          // Navegar a HomeScreen y el tour aparecerá automáticamente
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.touch_app_outlined, size: 20),
                        label: const Text(
                          'Ver tour guiado interactivo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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

  Widget _buildCard(_TutorialCardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: data.gradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: (data.gradient.colors.first).withAlpha(60),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji gigante
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  data.emoji,
                  style: const TextStyle(fontSize: 80),
                ),
              ),
              const SizedBox(height: 32),

              // Título
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Descripción
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withAlpha(230),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialCardData {
  final String emoji;
  final String title;
  final String description;
  final Gradient gradient;

  const _TutorialCardData({
    required this.emoji,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
