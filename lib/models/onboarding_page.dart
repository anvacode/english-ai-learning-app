import 'package:flutter/material.dart';

/// Modelo que representa una página del onboarding.
/// 
/// Contiene toda la información necesaria para mostrar
/// una página del proceso de bienvenida.
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
  });
}
