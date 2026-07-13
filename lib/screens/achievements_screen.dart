import 'package:flutter/material.dart';
import '../data/lessons_data.dart';
import '../logic/badge_service.dart';
import '../models/badge.dart' as achievement;
import '../theme/text_styles.dart';
import '../utils/responsive.dart';

/// Pantalla que muestra todos los badges/insignias del usuario.
///
/// Muestra badges desbloqueados y bloqueados con información
/// sobre cómo desbloquearlos.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logros'), elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.scale(context, 12, 16, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏆 Badges Desbloqueados',
              style: context.headline3.copyWith(color: Colors.deepPurple),
            ),
            SizedBox(height: Responsive.scale(context, 12, 16, 20)),
            FutureBuilder<List<achievement.Badge>>(
              future: BadgeService.getBadges(lessonsList),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final badges = snapshot.data ?? [];
                final unlockedBadges = badges.where((b) => b.unlocked).toList();

                if (unlockedBadges.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(Responsive.scale(context, 16, 24, 28)),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(Responsive.borderRadius(context)),
                    ),
                    child: Column(
                      children: [
                        Text('🎯', style: TextStyle(fontSize: Responsive.scale(context, 48, 64, 72))),
                        SizedBox(height: Responsive.scale(context, 12, 16, 20)),
                        Text(
                          'Domina lecciones para desbloquear badges',
                          style: context.bodyText.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Wrap(
                  spacing: Responsive.scale(context, 12, 16, 20),
                  runSpacing: Responsive.scale(context, 12, 16, 20),
                  children: unlockedBadges
                      .map(
                        (badge) => _BadgeCard(badge: badge, isUnlocked: true),
                      )
                      .toList(),
                );
              },
            ),
            SizedBox(height: Responsive.scale(context, 24, 32, 36)),
            Text(
              '📋 Próximos Badges',
              style: context.headline3.copyWith(color: Colors.deepPurple),
            ),
            SizedBox(height: Responsive.scale(context, 12, 16, 20)),
            FutureBuilder<List<achievement.Badge>>(
              future: BadgeService.getBadges(lessonsList),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final badges = snapshot.data ?? [];
                final lockedBadges = badges.where((b) => !b.unlocked).toList();

                if (lockedBadges.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(Responsive.scale(context, 16, 24, 28)),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(Responsive.borderRadius(context)),
                    ),
                    child: Column(
                      children: [
                        Text('🎉', style: TextStyle(fontSize: Responsive.scale(context, 48, 64, 72))),
                        SizedBox(height: Responsive.scale(context, 12, 16, 20)),
                        Text(
                          '¡Felicidades! Desbloqueaste todos los badges',
                          style: TextStyle(
                            fontSize: Responsive.scale(context, 14, 16, 18),
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Wrap(
                  spacing: Responsive.scale(context, 12, 16, 20),
                  runSpacing: Responsive.scale(context, 12, 16, 20),
                  children: lockedBadges
                      .map(
                        (badge) => _BadgeCard(badge: badge, isUnlocked: false),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que representa una tarjeta de badge.
class _BadgeCard extends StatelessWidget {
  final achievement.Badge badge;
  final bool isUnlocked;

  const _BadgeCard({required this.badge, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    final badgeWidth = Responsive.scale(context, 80.0, 100.0, 120.0);
    final iconSize = Responsive.scale(context, 36.0, 44.0, 48.0);

    return Container(
      width: badgeWidth,
      padding: EdgeInsets.all(Responsive.scale(context, 8, 12, 14)),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.amber[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(Responsive.borderRadius(context)),
        border: Border.all(
          color: isUnlocked ? Colors.amber[400]! : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            badge.icon,
            style: TextStyle(
              fontSize: iconSize,
              color: isUnlocked ? null : Colors.grey[400],
            ),
          ),
          SizedBox(height: Responsive.scale(context, 6, 8, 10)),
          Text(
            badge.title,
            style: TextStyle(
              fontSize: Responsive.scale(context, 12, 14, 15),
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.amber[900] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isUnlocked) ...[
            SizedBox(height: Responsive.scale(context, 3, 4, 5)),
            Text(
              'Bloqueado',
              style: TextStyle(
                fontSize: Responsive.scale(context, 10, 11, 12),
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
