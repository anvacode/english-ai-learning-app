import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Estilos de texto responsive para la aplicación.
/// 
/// Proporciona TextStyle que se adaptan al tamaño de pantalla,
/// asegurando legibilidad óptima en todos los dispositivos.
class AppTextStyles {
  /// Título principal (headlines)
  static TextStyle headline1(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.titleFontSize(context),
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      height: 1.2,
    );
  }

  /// Título secundario
  static TextStyle headline2(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.subtitleFontSize(context),
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      height: 1.3,
    );
  }

  /// Título de tarjetas
  static TextStyle cardTitle(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.scale(context, 18, 20, 22),
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
  }

  /// Texto base
  static TextStyle bodyText(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.baseFontSize(context),
      fontWeight: FontWeight.normal,
      color: Colors.black87,
      height: 1.5,
    );
  }

  /// Texto secundario (subtítulos, descripciones)
  static TextStyle bodyText2(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.scale(context, 14, 16, 18),
      fontWeight: FontWeight.normal,
      color: Colors.grey[700],
      height: 1.4,
    );
  }

  /// Texto pequeño (captions, hints)
  static TextStyle caption(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.smallFontSize(context),
      fontWeight: FontWeight.normal,
      color: Colors.grey[600],
      height: 1.3,
    );
  }

  /// Texto de botones
  static TextStyle button(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.scale(context, 16, 18, 18),
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 0.5,
    );
  }

  /// Texto de botones grandes
  static TextStyle largeButton(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.scale(context, 18, 20, 22),
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 0.5,
    );
  }

  /// Número grande (contador de estrellas, puntos, etc.)
  static TextStyle largeNumber(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.scale(context, 32, 36, 40),
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      height: 1.0,
    );
  }

  /// Etiqueta (labels, tags)
  static TextStyle label(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.scale(context, 12, 13, 14),
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      letterSpacing: 0.3,
    );
  }

  /// Texto de AppBar
  static TextStyle appBarTitle(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.scale(context, 20, 22, 24),
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  /// Título de onboarding
  static TextStyle onboardingTitle(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.scale(context, 28, 32, 36),
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      height: 1.2,
    );
  }

  /// Descripción de onboarding
  static TextStyle onboardingDescription(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.scale(context, 16, 18, 20),
      fontWeight: FontWeight.normal,
      color: Colors.grey[700],
      height: 1.5,
    );
  }

  /// Texto de lista (items)
  static TextStyle listItem(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.scale(context, 16, 17, 18),
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );
  }

  /// Texto de precio/estrellas
  static TextStyle price(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.scale(context, 18, 20, 22),
      fontWeight: FontWeight.bold,
      color: Colors.amber[700],
    );
  }
}

/// Extension para facilitar el uso de estilos en widgets
extension TextStyleExtension on BuildContext {
  TextStyle get headline1 => AppTextStyles.headline1(this);
  TextStyle get headline2 => AppTextStyles.headline2(this);
  TextStyle get cardTitle => AppTextStyles.cardTitle(this);
  TextStyle get bodyText => AppTextStyles.bodyText(this);
  TextStyle get bodyText2 => AppTextStyles.bodyText2(this);
  TextStyle get caption => AppTextStyles.caption(this);
  TextStyle get buttonText => AppTextStyles.button(this);
  TextStyle get largeButtonText => AppTextStyles.largeButton(this);
  TextStyle get largeNumber => AppTextStyles.largeNumber(this);
  TextStyle get label => AppTextStyles.label(this);
  TextStyle get listItem => AppTextStyles.listItem(this);
  TextStyle get price => AppTextStyles.price(this);
}
