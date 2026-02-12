import 'package:flutter/material.dart';
import 'lessons_screen.dart';
import 'profile/profile_screen.dart';
import 'settings_screen.dart';
import 'achievements_screen.dart';
import 'shop_screen.dart';
import 'practice/practice_hub_screen.dart';
import '../widgets/star_display.dart';
import '../utils/responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

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
    const PracticeHubScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 0 ? AppIcons.home : Icons.home_outlined,
              ),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 1 ? AppIcons.book : Icons.menu_book_outlined,
              ),
              label: 'Lecciones',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 2
                    ? AppIcons.game
                    : Icons.sports_esports_outlined,
              ),
              label: 'Práctica',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 3
                    ? AppIcons.settings
                    : Icons.settings_outlined,
              ),
              label: 'Configuración',
            ),
          ],
        ),
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: context.isMobile ? 80 : 120,
            floating: false,
            pinned: context.isMobile ? false : true,
            snap: false,
            elevation: context.isMobile ? 0 : 4,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Row(
                children: [
                  Text(
                    'English Learning',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: context.isMobile ? 20 : 24,
                    ),
                  ),
                  const Spacer(),
                  if (context.isMobile)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: StarDisplay(
                        iconSize: 20,
                        fontSize: 16,
                        showBackground: false,
                      ),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(10),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: context.isMobile
                ? []
                : [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: StarDisplay(
                            iconSize: 24,
                            fontSize: 18,
                            showBackground: false,
                          ),
                        ),
                      ),
                    ),
                  ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: context.isMobile
                    ? 2
                    : (context.isTablet ? 3 : 4),
                childAspectRatio: context.isMobile ? 0.9 : 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildListDelegate([
                _buildMenuCard(
                  context,
                  emoji: '📚',
                  title: 'Lecciones',
                  subtitle: 'Aprende inglés',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LessonsScreen()),
                  ),
                ),
                _buildMenuCard(
                  context,
                  emoji: '👤',
                  title: 'Perfil',
                  subtitle: 'Tu progreso',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                ),
                _buildMenuCard(
                  context,
                  emoji: '🏆',
                  title: 'Logros',
                  subtitle: 'Tus medallas',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFfa709a), Color(0xFFfee140)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AchievementsScreen(),
                    ),
                  ),
                ),
                _buildMenuCard(
                  context,
                  emoji: '🏪',
                  title: 'Tienda',
                  subtitle: 'Compra items',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShopScreen()),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (gradient as LinearGradient).colors.first.withAlpha(60),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(context.isMobile ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Solo el emoji, grande y destacado
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: context.isMobile ? 12 : 20,
                      ),
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: context.isMobile ? 56 : 72),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withAlpha(80),
                        fontSize: context.isMobile ? 13 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
