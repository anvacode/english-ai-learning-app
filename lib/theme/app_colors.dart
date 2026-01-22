import 'package:flutter/material.dart';

/// Paleta de colores moderna de la aplicación.
/// 
/// Diseño moderno con tonos azules profundos y acentos cálidos,
/// equilibrando profesionalismo con diversión para una app educativa.
class AppColors {
  // Colores primarios - Azul profundo moderno
  static const Color primaryDark = Color(0xFF1E3A5F); // Azul oscuro elegante
  static const Color primary = Color(0xFF2E5984); // Azul medio profesional
  static const Color primaryLight = Color(0xFF4A7BA7); // Azul claro
  static const Color primaryLighter = Color(0xFF7BA3C9); // Azul muy claro

  // Colores secundarios - Acentos cálidos
  static const Color secondary = Color(0xFFFF6B6B); // Coral vibrante pero no agresivo
  static const Color secondaryLight = Color(0xFFFF8E8E); // Coral claro
  static const Color accent = Color(0xFFFFB347); // Naranja cálido

  // Colores de éxito/progreso - Verde natural
  static const Color success = Color(0xFF51CF66); // Verde fresco
  static const Color successLight = Color(0xFF8CE99A); // Verde claro
  static const Color successDark = Color(0xFF37B24D); // Verde oscuro

  // Colores de advertencia/atención - Amarillo cálido
  static const Color warning = Color(0xFFFFAB40); // Amarillo-naranja
  static const Color warningLight = Color(0xFFFFCC80); // Amarillo claro

  // Colores de error - Rojo suave
  static const Color error = Color(0xFFE63946); // Rojo vibrante pero no agresivo
  static const Color errorLight = Color(0xFFFF6B7A); // Rojo claro

  // Colores de información - Azul cielo
  static const Color info = Color(0xFF339AF0); // Azul información
  static const Color infoLight = Color(0xFF74C0FC); // Azul claro

  // Colores neutros modernos
  static const Color background = Color(0xFFF8F9FA); // Gris muy claro, casi blanco
  static const Color surface = Color(0xFFFFFFFF); // Blanco puro
  static const Color surfaceVariant = Color(0xFFF1F3F5); // Gris ultra claro

  // Colores de texto - Jerarquía clara
  static const Color textPrimary = Color(0xFF212529); // Casi negro, fácil de leer
  static const Color textSecondary = Color(0xFF495057); // Gris oscuro
  static const Color textTertiary = Color(0xFF868E96); // Gris medio
  static const Color textDisabled = Color(0xFFADB5BD); // Gris claro

  // Bordes y divisores
  static const Color border = Color(0xFFDEE2E6); // Gris muy claro
  static const Color divider = Color(0xFFE9ECEF); // Gris ultra claro

  // Colores especiales para estrellas/recompensas
  static const Color starGold = Color(0xFFFFD93D); // Dorado brillante
  static const Color starGoldDark = Color(0xFFFFB700); // Dorado oscuro

  // Gradientes predefinidos
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successDark, success],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFFFCC80)],
  );

  // Sombras modernas
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withAlpha(20),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withAlpha(31),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: Colors.black.withAlpha(41),
      blurRadius: 28,
      offset: const Offset(0, 8),
    ),
  ];

  // Colores específicos por contexto
  
  /// Color para encabezados de lecciones
  static const Color lessonHeader = primary;
  
  /// Color para badges y logros
  static const Color badgeColor = accent;
  
  /// Color para botones primarios
  static const Color buttonPrimary = primary;
  
  /// Color para botones secundarios
  static const Color buttonSecondary = secondary;
  
  /// Color de fondo para cards
  static const Color cardBackground = surface;
  
  /// Color para elementos interactivos
  static const Color interactive = primary;
  
  /// Color para elementos deshabilitados
  static const Color disabled = Color(0xFFCED4DA);

  // Métodos helper para opacidad
  static Color withOpacity(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }

  /// Obtiene un color más claro
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Obtiene un color más oscuro
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
