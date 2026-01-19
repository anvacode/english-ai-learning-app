import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/lesson_controller.dart';
import 'services/theme_service.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LessonController()),
        ChangeNotifierProvider(create: (context) => ThemeService()..initialize()),
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
