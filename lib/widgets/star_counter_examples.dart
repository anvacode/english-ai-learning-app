import 'package:flutter/material.dart';
import 'star_counter.dart';

/// Ejemplos de uso del widget StarCounter en diferentes contextos.
/// 
/// Este archivo demuestra cómo usar StarCounter en:
/// - AppBar
/// - Pantallas de perfil
/// - Pantallas de tienda
/// - Diálogos y modales
/// - Botones y acciones

// ============================================================================
// EJEMPLO 1: StarCounter en AppBar
// ============================================================================

class ExampleAppBarWithStars extends StatelessWidget implements PreferredSizeWidget {
  const ExampleAppBarWithStars({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Mi Aplicación'),
      centerTitle: true,
      actions: [
        // Versión compacta para AppBar
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Center(
            child: StarCounter(
              iconSize: 20,
              fontSize: 16,
              showBackground: true,
              refreshInterval: 3, // Actualizar cada 3 segundos
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// EJEMPLO 2: StarCounter en pantalla de perfil
// ============================================================================

class ExampleProfileScreen extends StatelessWidget {
  const ExampleProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar del usuario
            const CircleAvatar(
              radius: 50,
              child: Text('👤', style: TextStyle(fontSize: 50)),
            ),
            const SizedBox(height: 16),
            
            // Nombre del usuario
            const Text(
              'Juan Pérez',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // StarCounter grande y destacado
            const StarCounter(
              iconSize: 32,
              fontSize: 28,
              showBackground: true,
              animateChanges: true,
            ),
            const SizedBox(height: 8),
            
            Text(
              'Estrellas totales',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EJEMPLO 3: StarCounter en pantalla de tienda
// ============================================================================

class ExampleShopScreen extends StatelessWidget {
  const ExampleShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
        actions: [
          // Mostrar estrellas disponibles con botón de recarga
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Center(
              child: StarCounterWithRefresh(
                iconSize: 22,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildShopItem(
            context,
            emoji: '🎨',
            name: 'Tema Arcoíris',
            price: 100,
          ),
          const SizedBox(height: 12),
          _buildShopItem(
            context,
            emoji: '⭐',
            name: 'Avatar Estrella',
            price: 250,
          ),
          const SizedBox(height: 12),
          _buildShopItem(
            context,
            emoji: '🏆',
            name: 'Avatar Campeón',
            price: 500,
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(
    BuildContext context, {
    required String emoji,
    required String name,
    required int price,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 40)),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber[700], size: 20),
            const SizedBox(width: 4),
            Text(
              price.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () {
          // Lógica de compra
        },
      ),
    );
  }
}

// ============================================================================
// EJEMPLO 4: StarCounter en diálogo de recompensa
// ============================================================================

class ExampleRewardDialog extends StatelessWidget {
  final int starsEarned;

  const ExampleRewardDialog({
    super.key,
    required this.starsEarned,
  });

  static Future<void> show(BuildContext context, int starsEarned) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExampleRewardDialog(starsEarned: starsEarned),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¡Felicitaciones! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Ganaste $starsEarned estrellas',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            
            // Mostrar total de estrellas actualizado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber[300]!, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'Total de estrellas:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const StarCounter(
                    iconSize: 28,
                    fontSize: 24,
                    showBackground: false,
                    animateChanges: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EJEMPLO 5: StarCounter en banner flotante
// ============================================================================

class ExampleStarBanner extends StatelessWidget {
  const ExampleStarBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber[400]!,
            Colors.amber[600]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withAlpha(102),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tus estrellas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¡Sigue aprendiendo para ganar más!',
                  style: TextStyle(
                    color: Colors.white.withAlpha(230),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const StarCounter(
            iconSize: 24,
            fontSize: 20,
            showBackground: true,
            iconColor: Colors.white,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EJEMPLO 6: StarCounter con callback para notificaciones
// ============================================================================

class ExampleScreenWithNotifications extends StatefulWidget {
  const ExampleScreenWithNotifications({super.key});

  @override
  State<ExampleScreenWithNotifications> createState() =>
      _ExampleScreenWithNotificationsState();
}

class _ExampleScreenWithNotificationsState
    extends State<ExampleScreenWithNotifications> {
  int _lastStarCount = 0;

  void _onStarsUpdated(int newCount) {
    // Si aumentaron las estrellas, mostrar notificación
    if (newCount > _lastStarCount && _lastStarCount > 0) {
      final gained = newCount - _lastStarCount;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Ganaste $gained estrellas! ⭐'),
          backgroundColor: Colors.amber[700],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    _lastStarCount = newCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Lecciones'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: StarCounter(
                iconSize: 20,
                fontSize: 16,
                showBackground: true,
                onStarsUpdated: _onStarsUpdated,
              ),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text('Completa lecciones para ganar estrellas'),
      ),
    );
  }
}

// ============================================================================
// EJEMPLO 7: StarCounter sin actualización automática (manual)
// ============================================================================

class ExampleManualRefreshScreen extends StatelessWidget {
  const ExampleManualRefreshScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refresco Manual'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Usar el widget StarCounterWithRefresh que incluye botón de refresh
            StarCounterWithRefresh(
              iconSize: 32,
              fontSize: 28,
            ),
            SizedBox(height: 16),
            Text(
              'Presiona el botón de actualizar para refrescar',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EJEMPLO 8: Integración completa en pantalla de lecciones
// ============================================================================

class ExampleLessonsScreenWithStars extends StatelessWidget {
  const ExampleLessonsScreenWithStars({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecciones de Inglés'),
        centerTitle: true,
        elevation: 2,
        actions: [
          // StarCounter en AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: StarCounter(
                iconSize: 22,
                fontSize: 18,
                showBackground: true,
                refreshInterval: 2,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner informativo con estrellas
          const ExampleStarBanner(),
          
          // Lista de lecciones
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text('${index + 1}'),
                    ),
                    title: Text('Lección ${index + 1}'),
                    subtitle: const Text('10 preguntas'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 16),
                        const SizedBox(width: 4),
                        const Text('+50'),
                      ],
                    ),
                    onTap: () {
                      // Navegar a la lección
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
