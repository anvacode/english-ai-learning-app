import 'package:flutter/material.dart';
import '../logic/first_time_service.dart';
import '../logic/student_service.dart';
import '../models/student.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

/// Pantalla de splash que se muestra al iniciar la aplicación.
/// 
/// Muestra el logo con animación fade-in durante 3 segundos,
/// inicializa el estudiante, luego verifica si es la primera vez
/// del usuario y navega a OnboardingScreen o HomeScreen según corresponda.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configurar animación fade-in
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    // Iniciar animación
    _animationController.forward();

    // Inicializar estudiante y navegar después de 3 segundos
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Inicializar estudiante (necesario para mantener funcionalidad existente)
    await StudentService.initializeStudent();
    
    // Esperar 3 segundos totales (incluyendo tiempo de inicialización)
    await Future.delayed(const Duration(seconds: 3));

    // Verificar si es la primera vez
    final isFirstTime = await FirstTimeService.isFirstTime();

    // Navegar a la pantalla correspondiente
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => isFirstTime
            ? const OnboardingScreen()
            : const HomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/logo.png',
            width: 200,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              // Si el logo no existe, mostrar un placeholder
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school,
                  size: 100,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
