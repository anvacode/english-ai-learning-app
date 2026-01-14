import 'package:flutter/material.dart';
import '../data/lessons_data.dart';
import '../logic/badge_service.dart';
import '../models/badge.dart' as achievement;

/// Pantalla que muestra todos los badges/insignias del usuario.
/// 
/// Muestra badges desbloqueados y bloqueados con información
/// sobre cómo desbloquearlos.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logros'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏆 Badges Desbloqueados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
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
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🎯',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Domina lecciones para desbloquear badges',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: unlockedBadges
                      .map(
                        (badge) => _BadgeCard(
                          badge: badge,
                          isUnlocked: true,
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              '📋 Próximos Badges',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
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
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          '🎉',
                          style: TextStyle(fontSize: 64),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '¡Felicidades! Desbloqueaste todos los badges',
                          style: TextStyle(
                            fontSize: 16,
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
                  spacing: 16,
                  runSpacing: 16,
                  children: lockedBadges
                      .map(
                        (badge) => _BadgeCard(
                          badge: badge,
                          isUnlocked: false,
                        ),
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

  const _BadgeCard({
    required this.badge,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.amber[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 48,
              color: isUnlocked ? null : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.amber[900] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isUnlocked) ...[
            const SizedBox(height: 4),
            Text(
              'Bloqueado',
              style: TextStyle(
                fontSize: 11,
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
