import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar el estado del tutorial interactivo.
///
/// Controla si el usuario ya completó el tutorial y permite
/// resetearlo para que pueda repetirlo desde Ajustes.
class TutorialService {
  static const String _tutorialCompletedKey = 'tutorial_completed';

  /// Verifica si el tutorial ya fue completado
  static Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }

  /// Marca el tutorial como completado
  static Future<void> setTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }

  /// Resetea el tutorial para que pueda repetirse
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialCompletedKey);
  }
}
