import 'package:flutter/material.dart';
import '../theme/color_palette.dart';
import 'package:english_ai_app/widgets/adaptive_badge.dart';
import '../models/practice_activity.dart';

/// Tarjeta adaptativa para actividades de práctica con tamaño de iconos mejorado
class AdaptivePracticeCard extends StatelessWidget {
  final PracticeActivity activity;
  final bool isUnlocked;
  final VoidCallback onTap;

  const AdaptivePracticeCard({
    required this.activity,
    required this.isUnlocked,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Coeficiente responsive basado en ancho
    final double widthFactor = screenWidth.clamp(320, 1920) / 375;
    
    // Tamaños escalables - AUMENTADOS para mejor visibilidad
    final iconSize = (120.0 * widthFactor).clamp(80.0, 160.0);
    final padding = (16.0 * widthFactor).clamp(12.0, 24.0);
    final cardElevation = isUnlocked ? 6.0 : 2.0;
    
    // Tamaño de emoji aumentado: 32% en lugar de 25%
    final emojiSize = (iconSize * 0.32).clamp(20.0, 64.0);

    return Card(
      elevation: cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isUnlocked ? Colors.blue[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isUnlocked ? Colors.blue[200]! : Colors.grey[300]!,
                      width: 2.0,
                    ),
                    boxShadow: isUnlocked ? [
                      BoxShadow(
                        color: Colors.blue.withAlpha(20),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ] : null,
                  ),
                  child: Text(
                    activity.iconEmoji,
                    style: TextStyle(
                      fontSize: emojiSize,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.blue[900] : Colors.grey[500],
                      shadows: isUnlocked ? [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.blue.withAlpha(10),
                        )
                      ] : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
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
                if (isUnlocked) ...[
                  const SizedBox(height: 8),
                  const AnimatedProgressIndicator(
                    value: 1.0,
                  ),
                  const SizedBox(height: 8),
                  const PracticeStatsRow(),
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

class AnimatedProgressIndicator extends StatelessWidget {
  final double value;

  const AnimatedProgressIndicator({required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 500),
      builder: (context, currentValue, child) {
        return LinearProgressIndicator(
          value: currentValue,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(
            BadgeColors.unlockedPrimary,
          ),
        );
      },
    );
  }
}

class PracticeStatsRow extends StatelessWidget {
  const PracticeStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
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
    );
  }
}
