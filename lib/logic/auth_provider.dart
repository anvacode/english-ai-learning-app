import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firebase_service.dart';
import '../services/sync_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, guest }

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final SyncService _syncService = SyncService();

  StreamSubscription<User?>? _authSubscription;
  AuthStatus _status = AuthStatus.uninitialized;
  User? _user;
  String? _guestId;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get guestId => _guestId;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isGuest => _status == AuthStatus.guest;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    // Check if Firebase is initialized
    if (!_firebaseService.isInitialized) {
      print(
        '⚠️ Firebase not initialized. Auth will work in offline/guest mode only.',
      );
      _status = AuthStatus.unauthenticated;
      _checkGuestSession();
      notifyListeners();
      return;
    }

    // Listen to auth state changes
    _authSubscription = _firebaseService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        _status = AuthStatus.authenticated;

        // Si había una sesión de invitado, migrar los datos
        if (_guestId != null) {
          print('🔄 Migrando datos de invitado...');
          await _syncService.migrateGuestData(_guestId!);
          _guestId = null;
        } else {
          // Descargar datos del usuario desde Firebase
          await _syncService.downloadUserData();
        }

        // Iniciar sincronización automática
        _syncService.setupAutoSync();

        // Sincronizar datos actuales
        _syncService.syncUserData();
      } else {
        // Check if there's a guest session
        _checkGuestSession();
      }
      notifyListeners();
    });
  }

  void _checkGuestSession() {
    // TODO: Implement guest session check from local storage
    // For now, we'll assume no guest session exists
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      if (!_firebaseService.isInitialized) {
        throw 'Servicios de autenticación no disponibles. Intenta más tarde.';
      }
      await _firebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Error signing in: ${e.code}');
      throw _getSpanishErrorMessage(e.code);
    } catch (e) {
      print('Error signing in: $e');
      if (e.toString().contains('no disponibles')) {
        rethrow;
      }
      throw 'Error al iniciar sesión. Verifica tu conexión.';
    }
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      if (!_firebaseService.isInitialized) {
        throw 'Servicios de autenticación no disponibles. Intenta más tarde.';
      }
      await _firebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Error creating user: ${e.code}');
      throw _getSpanishErrorMessage(e.code);
    } catch (e) {
      print('Error creating user: $e');
      if (e.toString().contains('no disponibles')) {
        rethrow;
      }
      throw 'Error al crear cuenta. Verifica tu conexión.';
    }
  }

  Future<void> signOut() async {
    try {
      _syncService.stopAutoSync();
      await _firebaseService.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (!_firebaseService.isInitialized) {
        throw 'Servicios de autenticación no disponibles. Intenta más tarde.';
      }
      await _firebaseService.auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset: $e');
      rethrow;
    }
  }

  /// Inicia sesión con Google (soporta web y móvil)
  Future<void> signInWithGoogle() async {
    try {
      if (!_firebaseService.isInitialized) {
        throw 'Servicios de autenticación no disponibles. Intenta más tarde.';
      }

      if (kIsWeb) {
        // Versión web: usar Firebase Auth directamente con popup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();

        // Configurar los scopes necesarios
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        // Usar signInWithPopup para web
        print('🔵 Iniciando Google Sign-In con popup (web)...');
        await _firebaseService.auth.signInWithPopup(googleProvider);

        print('✅ Inicio de sesión con Google exitoso (web)');
      } else {
        // Versión móvil: usar google_sign_in package
        print('🔵 Iniciando Google Sign-In (móvil)...');

        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );

        // Iniciar el flujo de autenticación de Google
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          // El usuario canceló el inicio de sesión
          print('❌ Google Sign-In cancelado por el usuario');
          throw 'Inicio de sesión cancelado';
        }

        // Obtener los detalles de autenticación del usuario
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Crear una credencial de Firebase con los tokens de Google
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Autenticarse con Firebase usando la credencial de Google
        await _firebaseService.auth.signInWithCredential(credential);

        print('✅ Inicio de sesión con Google exitoso (móvil)');
      }
    } on FirebaseAuthException catch (e) {
      print('Error con Google Sign-In (Firebase): ${e.code}');

      // Errores específicos de popup (solo web)
      if (kIsWeb) {
        if (e.code == 'popup-closed-by-user') {
          throw 'Inicio de sesión cancelado';
        }
        if (e.code == 'popup-blocked') {
          throw 'El popup fue bloqueado por el navegador. Habilita popups para este sitio.';
        }
      }

      throw _getSpanishErrorMessage(e.code);
    } catch (e) {
      print('Error con Google Sign-In: $e');
      if (e.toString().contains('no disponibles')) {
        rethrow;
      }
      if (e.toString().contains('cancelado') ||
          e.toString().contains('closed') ||
          e.toString().contains('sign_in_canceled')) {
        throw 'Inicio de sesión cancelado';
      }
      throw 'Error al iniciar sesión con Google. Inténtalo de nuevo.';
    }
  }

  // Guest session methods
  void createGuestSession() {
    // TODO: Generate unique guest ID and save to local storage
    _guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    _status = AuthStatus.guest;
    _user = null;
    notifyListeners();
  }

  void migrateGuestToUser(User newUser) {
    // TODO: Implement migration logic
    _user = newUser;
    _guestId = null;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  /// Convierte códigos de error de Firebase a mensajes en español
  String _getSpanishErrorMessage(String errorCode) {
    switch (errorCode) {
      // Errores de registro
      case 'email-already-in-use':
        return 'Este correo ya está registrado. Intenta iniciar sesión.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'operation-not-allowed':
        return 'Operación no permitida. Contacta soporte.';
      case 'weak-password':
        return 'La contraseña es muy débil. Usa al menos 6 caracteres.';

      // Errores de inicio de sesión
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo. Regístrate primero.';
      case 'wrong-password':
        return 'Contraseña incorrecta. Inténtalo de nuevo.';
      case 'invalid-credential':
        return 'Credenciales inválidas. Verifica tu correo y contraseña.';

      // Errores de red
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos.';

      // Otros errores
      case 'invalid-verification-code':
        return 'Código de verificación inválido.';
      case 'invalid-verification-id':
        return 'ID de verificación inválido.';

      default:
        return 'Error: $errorCode. Contacta soporte si persiste.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
