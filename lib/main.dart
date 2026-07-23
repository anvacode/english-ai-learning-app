import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logic/auth_provider.dart';
import 'logic/lesson_controller.dart';
import 'screens/splash_screen.dart';
import 'services/audio_service.dart';
import 'services/connectivity_service.dart';
import 'services/firebase_service.dart';
import 'services/sync_queue_service.dart';
import 'services/sync_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('❌ FlutterError: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('❌ Unhandled error: $error');
    debugPrint('Stack: $stack');
    if (kDebugMode) {
      Error.throwWithStackTrace(error, stack);
    }
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Material(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Algo salió mal. Por favor reinicia la app.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  };

  // Initialize connectivity service (non-blocking)
  ConnectivityService().initialize();

  // Initialize Firebase with error handling
  try {
    await FirebaseService().initialize();
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    debugPrint('🔄 App will continue in offline mode');
  }

  // Register lifecycle observer for cleanup on exit
  AppLifecycleListener(
    onExitRequested: () async {
      AudioService.disposeInstance();
      SyncService.disposeInstance();
      SyncQueueService.disposeInstance();
      ConnectivityService.disposeInstance();
      return AppExitResponse.exit;
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => LessonController()),
        ChangeNotifierProvider.value(
          value: ConnectivityService(),
        ),
      ],
      child: MaterialApp(
        title: 'ELA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: AppFonts.family,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
