import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: const Center(
        child: Text(
          'Perfil del estudiante (próximamente)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
