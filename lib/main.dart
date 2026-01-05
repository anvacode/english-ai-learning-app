import 'package:flutter/material.dart';
import 'logic/student_service.dart';
import 'models/student.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English AI App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const StudentInitializer(),
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

        final student = snapshot.data!;

        // Navegar a la pantalla principal con navegación
        return const HomeScreen();
      },
    );
  }
}
