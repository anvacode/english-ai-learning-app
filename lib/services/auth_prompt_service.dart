import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para manejar el prompt de autenticación que se muestra
/// a usuarios no autenticados.
///
/// Lógica:
/// - Después del onboarding, siempre muestra el prompt una vez
/// - Para usuarios recurrentes no autenticados, muestra cada 5 aperturas
class AuthPromptService {
  static const String _appOpenCountKey = 'app_open_count';
  static const String _promptShownAfterOnboardingKey =
      'auth_prompt_shown_after_onboarding';
  static const String _lastPromptCountKey = 'last_prompt_count';
  static const int _promptInterval = 5;

  /// Incrementa el contador de aperturas de la app.
  static Future<void> incrementOpenCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_appOpenCountKey) ?? 0;
    await prefs.setInt(_appOpenCountKey, currentCount + 1);
  }

  /// Obtiene el contador actual de aperturas.
  static Future<int> getOpenCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_appOpenCountKey) ?? 0;
  }

  /// Verifica si ya se mostró el prompt después del onboarding.
  static Future<bool> wasPromptShownAfterOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_promptShownAfterOnboardingKey) ?? false;
  }

  /// Marca que el prompt ya se mostró después del onboarding.
  static Future<void> markPromptShownAfterOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_promptShownAfterOnboardingKey, true);
  }

  /// Obtiene el contador en el que se mostró el último prompt.
  static Future<int> _getLastPromptCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastPromptCountKey) ?? -1;
  }

  /// Marca que el prompt ya se mostró en el ciclo actual.
  static Future<void> markPromptShownForCurrentCycle() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = await getOpenCount();
    await prefs.setInt(_lastPromptCountKey, currentCount);
  }

  /// Determina si se debe mostrar el prompt de autenticación.
  ///
  /// Retorna true si:
  /// - Es la primera vez después del onboarding (no se ha mostrado antes)
  /// - El contador de aperturas es múltiplo de 5 Y no se ha mostrado en este ciclo
  static Future<bool> shouldShowAuthPrompt({
    required bool isAuthenticated,
    required bool isGuest,
  }) async {
    if (isAuthenticated) return false;

    final shownAfterOnboarding = await wasPromptShownAfterOnboarding();

    if (!shownAfterOnboarding) {
      return true;
    }

    if (isGuest) {
      final openCount = await getOpenCount();
      final lastPromptCount = await _getLastPromptCount();

      if (openCount > 0 &&
          openCount % _promptInterval == 0 &&
          openCount != lastPromptCount) {
        return true;
      }
    }

    return false;
  }

  /// Resetea todos los valores (útil para testing).
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appOpenCountKey);
    await prefs.remove(_promptShownAfterOnboardingKey);
    await prefs.remove(_lastPromptCountKey);
  }
}
