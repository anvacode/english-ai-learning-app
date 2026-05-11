import 'package:english_ai_app/widgets/adaptive_badge.dart';
import 'package:flutter/material.dart';

import '../models/practice_activity.dart';
import '../theme/icon_sizes.dart';

/// Widget de tarjeta para mostrar una actividad de práctica
/// Versión adaptativa que mantiene consistencia visual en todos los dispositivos
class PracticeCard extends StatelessWidget {
  final PracticeActivity activity;
  final VoidCallback onTap;
  
  const PracticeCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = activity.isUnlocked;

    return Card(
      elevation: isUnlocked ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isUnlocked ? Colors.white : Colors.grey[300],
      child: InkWell(
        onTap: isUnlocked ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono y estado - Adaptados para consistencia
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        activity.iconEmoji,
                        style: const TextStyle(fontSize: IconSizes.md),
                      ),
                    ),
                    const PracticeCardBadge(
                      isUnlocked: false,
                      iconData: Icons.lock,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Título
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Descripción
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Progreso y estadísticas
                if (isUnlocked) ...[
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '0/0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                  const PracticeCardBadge(
                    isUnlocked: false,
                    iconData: Icons.lock,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
