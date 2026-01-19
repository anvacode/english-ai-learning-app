import 'package:flutter/material.dart';

/// Sistema de diseño responsive para la aplicación.
/// 
/// Proporciona breakpoints, métodos helper y configuración
/// para adaptar la UI a diferentes tamaños de pantalla.
class Responsive {
  /// Breakpoints de diseño
  static const double mobileMaxWidth = 768;
  static const double tabletMaxWidth = 1024;
  static const double desktopMaxWidth = 1200;

  /// Obtiene el ancho de la pantalla
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Obtiene el alto de la pantalla
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Verifica si es móvil
  static bool isMobile(BuildContext context) {
    return screenWidth(context) < mobileMaxWidth;
  }

  /// Verifica si es tablet
  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);
    return width >= mobileMaxWidth && width < tabletMaxWidth;
  }

  /// Verifica si es desktop
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= tabletMaxWidth;
  }

  /// Obtiene el padding horizontal apropiado según el dispositivo
  static double horizontalPadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 24.0;
    return 32.0;
  }

  /// Obtiene el padding vertical apropiado según el dispositivo
  static double verticalPadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 20.0;
    return 24.0;
  }

  /// Obtiene el número de columnas para grids según el dispositivo
  static int gridColumns(BuildContext context, {int? mobile, int? tablet, int? desktop}) {
    if (isMobile(context)) return mobile ?? 2;
    if (isTablet(context)) return tablet ?? 3;
    return desktop ?? 4;
  }

  /// Obtiene el espaciado entre elementos del grid
  static double gridSpacing(BuildContext context) {
    if (isMobile(context)) return 12.0;
    if (isTablet(context)) return 16.0;
    return 20.0;
  }

  /// Obtiene el ancho máximo del contenedor principal
  static double maxContainerWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 900.0;
    return desktopMaxWidth;
  }

  /// Tamaño de fuente base según dispositivo
  static double baseFontSize(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 18.0;
    return 20.0;
  }

  /// Tamaño de fuente para títulos según dispositivo
  static double titleFontSize(BuildContext context) {
    if (isMobile(context)) return 24.0;
    if (isTablet(context)) return 28.0;
    return 32.0;
  }

  /// Tamaño de fuente para subtítulos según dispositivo
  static double subtitleFontSize(BuildContext context) {
    if (isMobile(context)) return 18.0;
    if (isTablet(context)) return 20.0;
    return 22.0;
  }

  /// Tamaño de fuente para texto pequeño según dispositivo
  static double smallFontSize(BuildContext context) {
    if (isMobile(context)) return 12.0;
    if (isTablet(context)) return 14.0;
    return 14.0;
  }

  /// Tamaño de íconos según dispositivo
  static double iconSize(BuildContext context) {
    if (isMobile(context)) return 24.0;
    if (isTablet(context)) return 28.0;
    return 32.0;
  }

  /// Tamaño de íconos grandes según dispositivo
  static double largeIconSize(BuildContext context) {
    if (isMobile(context)) return 48.0;
    if (isTablet(context)) return 56.0;
    return 64.0;
  }

  /// Altura de botones según dispositivo
  static double buttonHeight(BuildContext context) {
    if (isMobile(context)) return 48.0;
    if (isTablet(context)) return 52.0;
    return 56.0;
  }

  /// Radio de bordes según dispositivo
  static double borderRadius(BuildContext context) {
    if (isMobile(context)) return 12.0;
    if (isTablet(context)) return 14.0;
    return 16.0;
  }

  /// Valor escalado según dispositivo
  /// Útil para dimensiones personalizadas
  static double scale(BuildContext context, double mobile, double tablet, double desktop) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Widget que retorna diferentes widgets según el dispositivo
  static Widget builder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Obtiene EdgeInsets responsive
  static EdgeInsets padding(BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    final multiplier = isMobile(context) ? 1.0 : isTablet(context) ? 1.25 : 1.5;
    
    if (all != null) {
      return EdgeInsets.all(all * multiplier);
    }
    
    return EdgeInsets.only(
      top: (top ?? vertical ?? 0) * multiplier,
      bottom: (bottom ?? vertical ?? 0) * multiplier,
      left: (left ?? horizontal ?? 0) * multiplier,
      right: (right ?? horizontal ?? 0) * multiplier,
    );
  }

  /// Detecta si el dispositivo soporta hover (mouse)
  static bool hasHover(BuildContext context) {
    // En web o desktop, generalmente hay mouse
    return !isMobile(context);
  }

  /// Aspect ratio para tarjetas según dispositivo
  static double cardAspectRatio(BuildContext context) {
    if (isMobile(context)) return 0.9;
    if (isTablet(context)) return 1.0;
    return 1.1;
  }
}

/// Extension para facilitar el uso de Responsive en widgets
extension ResponsiveExtension on BuildContext {
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  double get screenWidth => Responsive.screenWidth(this);
  double get screenHeight => Responsive.screenHeight(this);
  double get horizontalPadding => Responsive.horizontalPadding(this);
  double get verticalPadding => Responsive.verticalPadding(this);
  double get baseFontSize => Responsive.baseFontSize(this);
  double get titleFontSize => Responsive.titleFontSize(this);
  double get subtitleFontSize => Responsive.subtitleFontSize(this);
  double get smallFontSize => Responsive.smallFontSize(this);
}
