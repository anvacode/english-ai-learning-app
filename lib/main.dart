import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/student_service.dart';
import 'logic/lesson_controller.dart';
import 'models/student.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LessonController(),
      child: MaterialApp(
        title: 'English AI App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const StudentInitializer(),
      ),
    );
  }
}

/// Widget que inicializa el estudiante de forma asíncrona
class StudentInitializer extends StatefulWidget {
  const StudentInitializer({super.key});

  @override
  State<StudentInitializer> createState() => _StudentInitializerState();
}

class _StudentInitializerState extends State<StudentInitializer> {
  late Future<Student> _studentFuture;

  @override
  void initState() {
    super.initState();
    _studentFuture = StudentService.initializeStudent();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Student>(
      future: _studentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Inicializando...')),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        // Navegar a la pantalla principal con navegación
        return const HomeScreen();
      },
    );
  }
}
