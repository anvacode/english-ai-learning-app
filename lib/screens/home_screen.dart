import 'package:flutter/material.dart';
import 'lessons_screen.dart';
import 'profile/profile_screen.dart';
import 'settings_screen.dart';
import 'achievements_screen.dart';
import 'shop_screen.dart';
import '../widgets/star_display.dart';

/// Pantalla principal de navegación con GridView de opciones.
/// 
/// Muestra 4 opciones principales:
/// - Lecciones
/// - Perfil
/// - Configuración
/// - Logros
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeGridView(),
    const LessonsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Lecciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

/// Widget que muestra el GridView principal con las 4 opciones.
class _HomeGridView extends StatelessWidget {
  const _HomeGridView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('English Learning'),
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: StarDisplay(
                iconSize: 24,
                fontSize: 18,
                showBackground: true,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: [
            _HomeGridItem(
              icon: '📚',
              title: 'Lecciones',
              color: const Color(0xFF6C63FF),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LessonsScreen(),
                  ),
                );
              },
            ),
            _HomeGridItem(
              icon: '👤',
              title: 'Perfil',
              color: const Color(0xFFFF6B6B),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            _HomeGridItem(
              icon: '⚙️',
              title: 'Configuración',
              color: const Color(0xFF4ECDC4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            _HomeGridItem(
              icon: '🏆',
              title: 'Logros',
              color: const Color(0xFFFFD93D),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AchievementsScreen(),
                  ),
                );
              },
            ),
            _HomeGridItem(
              icon: '🏪',
              title: 'Tienda',
              color: const Color(0xFFFF6B9D),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShopScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que representa un ítem del GridView.
class _HomeGridItem extends StatefulWidget {
  final String icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _HomeGridItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  State<_HomeGridItem> createState() => _HomeGridItemState();
}

class _HomeGridItemState extends State<_HomeGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color,
                  widget.color.withOpacity(0.7),
                ],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.icon,
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
