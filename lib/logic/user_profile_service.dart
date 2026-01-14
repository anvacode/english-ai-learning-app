import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Servicio para manejar el perfil del usuario.
/// 
/// Gestiona la carga y guardado del perfil del usuario
/// usando SharedPreferences.
class UserProfileService {
  static const String _profileKey = 'user_profile';

  /// Carga el perfil del usuario desde SharedPreferences.
  /// 
  /// Si no existe un perfil guardado, retorna un perfil por defecto.
  static Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_profileKey);

    if (jsonString == null || jsonString.isEmpty) {
      // Si no existe perfil, crear uno por defecto y guardarlo
      final defaultProfile = UserProfile.defaultProfile();
      await saveProfile(defaultProfile);
      return defaultProfile;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProfile.fromJson(json);
    } catch (e) {
      // Si hay error al deserializar, retornar perfil por defecto
      print('Error loading user profile: $e');
      final defaultProfile = UserProfile.defaultProfile();
      await saveProfile(defaultProfile);
      return defaultProfile;
    }
  }

  /// Guarda el perfil del usuario en SharedPreferences.
  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(profile.toJson());
    await prefs.setString(_profileKey, jsonString);
  }

  /// Actualiza el nickname del usuario.
  static Future<void> updateNickname(String nickname) async {
    final profile = await loadProfile();
    final updatedProfile = profile.copyWith(nickname: nickname);
    await saveProfile(updatedProfile);
  }

  /// Actualiza el avatar del usuario.
  static Future<void> updateAvatar(int avatarId) async {
    if (avatarId < 0 || avatarId > 7) {
      throw ArgumentError('avatarId must be between 0 and 7');
    }
    final profile = await loadProfile();
    final updatedProfile = profile.copyWith(avatarId: avatarId);
    await saveProfile(updatedProfile);
  }

  /// Resetea el perfil a valores por defecto.
  static Future<void> resetProfile() async {
    final defaultProfile = UserProfile.defaultProfile();
    await saveProfile(defaultProfile);
  }
}
