import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda y Soporte'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFaqSection(
            context,
            '¿Cómo funciona la app?',
            'English Learning es una aplicación para niños de 5-8 años que les ayuda a aprender inglés de forma divertida mediante lecciones interactivas, juegos y prácticas de pronunciación.',
          ),
          _buildFaqSection(
            context,
            '¿Cómo gano estrellas?',
            'Puedes ganar estrellas al completar lecciones, responder correctamente preguntas y lograr buenos resultados en los ejercicios de práctica.',
          ),
          _buildFaqSection(
            context,
            '¿Qué son los badges?',
            'Los badges son logros que obtienes al completar lecciones. Cada badge tiene un icono único que se muestra en tu perfil cuando lo desbloqueas.',
          ),
          _buildFaqSection(
            context,
            '¿Cómo funciona la práctica de pronunciación?',
            'La práctica de pronunciación usa el micrófono de tu dispositivo para escucharte y evaluar si pronuncias las palabras correctamente en inglés.',
          ),
          _buildFaqSection(
            context,
            '¿Puedo cambiar el idioma de la app?',
            'Por ahora la app está disponible en español como idioma de interfaz, pero las lecciones son en inglés.',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            '¿Necesitas más ayuda?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Email de soporte',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'support@englishlearning.app',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Versión',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('1.0.0', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(
    BuildContext context,
    String question,
    String answer,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey[700], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
