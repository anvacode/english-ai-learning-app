import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para manejar la verificación de primera vez del usuario.
/// 
/// Utiliza SharedPreferences para persistir si el usuario ya ha usado
/// la aplicación anteriormente.
class FirstTimeService {
  static const String _isFirstTimeKey = 'is_first_time';

  /// Verifica si es la primera vez que el usuario usa la aplicación.
  /// 
  /// Retorna `true` si es la primera vez, `false` si ya ha usado la app.
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    // Si la clave no existe, es la primera vez (retorna true)
    return prefs.getBool(_isFirstTimeKey) ?? true;
  }

  /// Marca que el usuario ya no es nuevo (ha completado el onboarding).
  /// 
  /// Debe llamarse después de que el usuario complete el onboarding
  /// para que en futuras ejecuciones vaya directamente a HomeScreen.
  static Future<void> setFirstTimeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, false);
  }

  /// Resetea el estado de primera vez (útil para testing).
  /// 
  /// Esto hará que la próxima vez que se abra la app, se muestre
  /// el onboarding nuevamente.
  static Future<void> resetFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isFirstTimeKey);
  }
}
