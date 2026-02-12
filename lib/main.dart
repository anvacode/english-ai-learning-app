import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/lesson_controller.dart';
import 'logic/auth_provider.dart';
import 'services/theme_service.dart';
import 'services/firebase_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await FirebaseService().initialize();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    print('🔄 App will continue in offline mode');
  }

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
        ChangeNotifierProvider(
          create: (context) => ThemeService()..initialize(),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'English AI App',
            theme: ThemeService.getThemeData(themeService.activeThemeId),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
