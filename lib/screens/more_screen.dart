import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Más')),
      body: const Center(
        child: Text(
          'Más funciones próximamente',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
