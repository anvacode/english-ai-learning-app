import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/star_display.dart';
import '../achievements_screen.dart';
import '../lessons_screen.dart';
import '../profile/profile_screen.dart';
import '../shop_screen.dart';
import '../tutorial/tutorial_keys.dart';

class HomeGridView extends StatelessWidget {
  const HomeGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: context.isMobile ? 80 : 120,
            pinned: context.isMobile ? false : true,
            elevation: context.isMobile ? 0 : 4,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: context.horizontalPadding, bottom: 16),
              title: Row(
                children: [
                  Text(
                    'English Learning',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.scale(context, 20, 22, 24),
                    ),
                  ),
                  const Spacer(),
                  if (context.isMobile)
                    Container(
                      key: TutorialKeys.starCounter,
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.scale(context, 10, 12, 14),
                        vertical: Responsive.scale(context, 4, 6, 8),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(Responsive.scale(context, 16, 18, 20)),
                      ),
                      child: const StarDisplay(),
                    ),
                  SizedBox(width: Responsive.scale(context, 6, 8, 10)),
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
                      padding: EdgeInsets.only(right: context.horizontalPadding),
                      child: Center(
                        child: Container(
                          key: TutorialKeys.starCounter,
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.scale(context, 10, 12, 14),
                            vertical: Responsive.scale(context, 4, 6, 8),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(Responsive.scale(context, 16, 18, 20)),
                          ),
                          child: StarDisplay(
                            iconSize: Responsive.scale(context, 20, 24, 28),
                            fontSize: Responsive.scale(context, 16, 18, 20),
                          ),
                        ),
                      ),
                    ),
                  ],
          ),
          SliverPadding(
            padding: EdgeInsets.all(context.horizontalPadding),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.gridColumns(context, mobile: 2, tablet: 3, desktop: 4, wide: 5),
                childAspectRatio: Responsive.cardAspectRatio(context),
                crossAxisSpacing: Responsive.gridSpacing(context),
                mainAxisSpacing: Responsive.gridSpacing(context),
              ),
              delegate: SliverChildListDelegate([
                _buildMenuCard(
                  context,
                  cardKey: TutorialKeys.lessonsCard,
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
                  cardKey: TutorialKeys.profileCard,
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
                  cardKey: TutorialKeys.achievementsCard,
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
                  cardKey: TutorialKeys.shopCard,
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
    Key? cardKey,
    required String emoji,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: cardKey,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(Responsive.scale(context, 20, 24, 28)),
          boxShadow: [
            BoxShadow(
              color: (gradient as LinearGradient).colors.first.withAlpha(60),
              blurRadius: Responsive.scale(context, 16, 20, 24),
              offset: Offset(0, Responsive.scale(context, 6, 8, 10)),
              spreadRadius: Responsive.scale(context, -4, -5, -6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Responsive.scale(context, 20, 24, 28)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(Responsive.scale(context, 12, 16, 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: Responsive.scale(context, 10, 16, 20),
                      ),
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: Responsive.scale(context, 48, 56, 64)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.scale(context, 18, 20, 22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 3, 4, 6)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withAlpha(80),
                        fontSize: Responsive.scale(context, 13, 14, 15),
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
