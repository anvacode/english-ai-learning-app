import 'package:flutter/material.dart';

/// Modelo que representa una página del onboarding.
/// 
/// Contiene toda la información necesaria para mostrar
/// una pantalla de bienvenida atractiva.
class OnboardingPageData {
  /// Título principal de la página
  final String title;
  
  /// Descripción detallada
  final String description;
  
  /// Icono principal
  final IconData icon;
  
  /// Color de fondo principal
  final Color primaryColor;
  
  /// Color de acento/gradiente
  final Color accentColor;
  
  /// Color del icono
  final Color iconColor;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.accentColor,
    required this.iconColor,
  });
}

/// Páginas predefinidas del onboarding
class OnboardingPages {
  static const List<OnboardingPageData> pages = [
    OnboardingPageData(
      title: '¡Aprende Inglés Jugando!',
      description: 'Descubre un mundo de diversión mientras aprendes inglés con lecciones interactivas diseñadas especialmente para ti.',
      icon: Icons.school_rounded,
      primaryColor: Color(0xFF6C63FF),
      accentColor: Color(0xFF5A52E0),
      iconColor: Colors.white,
    ),
    OnboardingPageData(
      title: '¡Gana Estrellas!',
      description: 'Completa lecciones y ejercicios para ganar estrellas. ¡Cuantas más estrellas consigas, más premios podrás desbloquear!',
      icon: Icons.star_rounded,
      primaryColor: Color(0xFFFFD93D),
      accentColor: Color(0xFFFFB700),
      iconColor: Colors.white,
    ),
    OnboardingPageData(
      title: '¡Colecciona Insignias!',
      description: 'Domina cada lección y desbloquea insignias especiales. Conviértete en un maestro del inglés.',
      icon: Icons.emoji_events_rounded,
      primaryColor: Color(0xFF4ECDC4),
      accentColor: Color(0xFF44A69E),
      iconColor: Colors.white,
    ),
    OnboardingPageData(
      title: '¡Personaliza tu Avatar!',
      description: 'Usa tus estrellas para comprar avatares únicos y temas de colores. ¡Haz que tu perfil sea especial!',
      icon: Icons.face_rounded,
      primaryColor: Color(0xFFFF6B9D),
      accentColor: Color(0xFFFF5588),
      iconColor: Colors.white,
    ),
  ];
}
