import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../logic/user_profile_service.dart';
import '../logic/star_service.dart';
import '../models/user_profile.dart';

/// Servicio de sincronización entre almacenamiento local y Firebase
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  bool _isSyncing = false;

  /// Sincronizar datos del usuario actual con Firebase
  Future<bool> syncUserData() async {
    if (_isSyncing) {
      print('⏳ Ya hay una sincronización en progreso');
      return false;
    }

    _isSyncing = true;

    try {
      final user = _firebaseService.currentUser;
      if (user == null) {
        print('❌ No hay usuario autenticado para sincronizar');
        return false;
      }

      print('🔄 Iniciando sincronización para ${user.email}');

      // Cargar datos locales
      final profile = await UserProfileService.loadProfile();
      final stars = await StarService.getTotalStars();

      // Crear referencia al documento del usuario
      final userDoc = _firebaseService.firestore.collection('users').doc(user.uid);

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

      print('✅ Sincronización completada exitosamente');
      return true;
    } catch (e) {
      print('❌ Error al sincronizar: $e');
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
        print('❌ No hay usuario autenticado');
        return false;
      }

      print('📥 Descargando datos de ${user.email}');

      final userDoc = await _firebaseService.firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        print('ℹ️ No hay datos remotos, usando datos locales');
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
          // Nota: StarService no tiene método setStars directo, 
          // necesitaríamos agregar transacciones para ajustar
          if (remoteStars > localStars) {
            final difference = remoteStars - localStars;
            await StarService.addStars(
              difference,
              'cloud_sync',
              description: 'Sincronización desde la nube',
              applyMultiplier: false,
            );
            print('⭐ Estrellas actualizadas de $localStars a $remoteStars');
          }
        }
      }

      print('✅ Datos descargados exitosamente');
      return true;
    } catch (e) {
      print('❌ Error al descargar datos: $e');
      return false;
    }
  }

  /// Migrar datos de invitado a usuario registrado
  Future<bool> migrateGuestData(String guestId) async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) {
        print('❌ No hay usuario autenticado');
        return false;
      }

      print('🔄 Migrando datos de invitado a usuario registrado');

      // Los datos ya están en el almacenamiento local
      // Solo necesitamos subirlos a Firebase
      final success = await syncUserData();

      if (success) {
        print('✅ Migración completada exitosamente');
      }

      return success;
    } catch (e) {
      print('❌ Error al migrar datos: $e');
      return false;
    }
  }

  /// Configurar sincronización automática
  void setupAutoSync() {
    final user = _firebaseService.currentUser;
    if (user == null) return;

    // Sincronizar cada 5 minutos
    Future.delayed(const Duration(minutes: 5), () {
      syncUserData().then((_) {
        setupAutoSync(); // Reprogramar
      });
    });
  }
}
