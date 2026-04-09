import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../logic/user_profile_service.dart';
import '../logic/star_service.dart';
import '../models/user_profile.dart';

/// Servicio de sincronización entre almacenamiento local y Firebase
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _lastSyncedStarsKey = 'last_synced_stars';

  final FirebaseService _firebaseService = FirebaseService();
  bool _isSyncing = false;
  Timer? _autoSyncTimer;

  /// Sincronizar datos del usuario actual con Firebase
  Future<bool> syncUserData() async {
    if (_isSyncing) {
      debugPrint('⏳ Ya hay una sincronización en progreso');
      return false;
    }

    _isSyncing = true;

    try {
      final user = _firebaseService.currentUser;
      if (user == null) {
        debugPrint('❌ No hay usuario autenticado para sincronizar');
        return false;
      }

      debugPrint('🔄 Iniciando sincronización para ${user.email}');

      // Cargar datos locales
      final profile = await UserProfileService.loadProfile();
      final stars = await StarService.getTotalStars();

      // Crear referencia al documento del usuario
      final userDoc = _firebaseService.firestore
          .collection('users')
          .doc(user.uid);

      // Subir datos a Firebase
      await userDoc.set({
        'profile': {
          'nickname': profile.nickname,
          'avatarId': profile.avatarId,
          'email': user.email,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        'progress': {
          'stars': stars,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      // Registrar timestamp de última sincronización para evitar duplicaciones
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt(_lastSyncedStarsKey, stars);

      debugPrint('✅ Sincronización completada exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error al sincronizar: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Descargar datos del usuario desde Firebase
  Future<bool> downloadUserData() async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) {
        debugPrint('❌ No hay usuario autenticado');
        return false;
      }

      debugPrint('📥 Descargando datos de ${user.email}');

      final userDoc = await _firebaseService.firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint('ℹ️ No hay datos remotos, usando datos locales');
        return false;
      }

      final data = userDoc.data() as Map<String, dynamic>;

      // Actualizar perfil local si hay datos remotos
      if (data.containsKey('profile')) {
        final profileData = data['profile'] as Map<String, dynamic>;
        final currentProfile = await UserProfileService.loadProfile();

        final updatedProfile = UserProfile(
          nickname: profileData['nickname'] ?? currentProfile.nickname,
          avatarId: profileData['avatarId'] ?? currentProfile.avatarId,
          createdAt: currentProfile.createdAt,
        );

        await UserProfileService.saveProfile(updatedProfile);
      }

      // Actualizar estrellas si hay datos remotos
      if (data.containsKey('progress')) {
        final progressData = data['progress'] as Map<String, dynamic>;
        if (progressData.containsKey('stars')) {
          final remoteStars = progressData['stars'] as int;
          final localStars = await StarService.getTotalStars();

          // Usar el valor mayor (fusión de datos)
          if (remoteStars > localStars) {
            final difference = remoteStars - localStars;
            await StarService.addStars(
              difference,
              'cloud_sync',
              description: 'Sincronización desde la nube',
              applyMultiplier: false,
            );
            debugPrint(
              '⭐ Estrellas actualizadas de $localStars a $remoteStars',
            );
          }
        }
      }

      debugPrint('✅ Datos descargados exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error al descargar datos: $e');
      return false;
    }
  }

  /// Migrar datos de invitado a usuario registrado
  Future<bool> migrateGuestData(String guestId) async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) {
        debugPrint('❌ No hay usuario autenticado');
        return false;
      }

      debugPrint('🔄 Migrando datos de invitado a usuario registrado');

      // Los datos ya están en el almacenamiento local
      // Solo necesitamos subirlos a Firebase
      final success = await syncUserData();

      if (success) {
        debugPrint('✅ Migración completada exitosamente');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error al migrar datos: $e');
      return false;
    }
  }

  /// Configurar sincronización automática
  void setupAutoSync() {
    final user = _firebaseService.currentUser;
    if (user == null) return;

    stopAutoSync();

    _autoSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncUserData();
    });
  }

  /// Detener la sincronización automática
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  /// Libera la instancia singleton (llamar al cerrar la app)
  static void disposeInstance() {
    _instance.stopAutoSync();
  }
}
