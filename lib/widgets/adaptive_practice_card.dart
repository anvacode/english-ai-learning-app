import 'package:english_ai_app/widgets/adaptive_badge.dart';
import 'package:flutter/material.dart';

import '../models/practice_activity.dart';
import '../theme/color_palette.dart';
import '../theme/text_styles.dart';
import '../utils/responsive.dart';

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
    final iconContainerSize = Responsive.scale(context, 56.0, 64.0, 72.0);
    final emojiSize = Responsive.scale(context, 32.0, 40.0, 48.0);
    final padding = Responsive.scale(context, 12.0, 16.0, 20.0);
    final cardElevation = isUnlocked ? 6.0 : 2.0;
    final borderRadius = Responsive.borderRadius(context);

    return Card(
      elevation: cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: iconContainerSize,
                    minHeight: iconContainerSize,
                    maxWidth: iconContainerSize,
                    maxHeight: iconContainerSize,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.all(Responsive.scale(context, 8.0, 10.0, 12.0)),
                    decoration: BoxDecoration(
                      color: isUnlocked ? Colors.blue[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(Responsive.scale(context, 12.0, 14.0, 16.0)),
                      border: Border.all(
                        color: isUnlocked ? Colors.blue[300]! : Colors.grey[300]!,
                        width: 2.0,
                      ),
                      boxShadow: isUnlocked
                          ? [
                              BoxShadow(
                                color: Colors.blue.withAlpha(20),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      activity.iconEmoji,
                      style: TextStyle(
                        fontSize: emojiSize,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.blue[900] : Colors.grey[600],
                        shadows: isUnlocked
                            ? [
                                Shadow(
                                  offset: const Offset(1, 1),
                                  blurRadius: 3,
                                  color: Colors.blue.withAlpha(10),
                                )
                              ]
                            : null,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.scale(context, 6.0, 8.0, 10.0)),
                Text(
                  activity.title,
                  style: context.cardTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.scale(context, 4.0, 6.0, 8.0)),
                Text(
                  activity.description,
                  style: context.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.scale(context, 6.0, 8.0, 10.0)),
                if (isUnlocked) ...[
                  SizedBox(height: Responsive.scale(context, 6.0, 8.0, 8.0)),
                  const AnimatedProgressIndicator(value: 1.0),
                  SizedBox(height: Responsive.scale(context, 6.0, 8.0, 8.0)),
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
    final iconSz = Responsive.scale(context, 14.0, 16.0, 18.0);
    final fontSize = Responsive.scale(context, 11.0, 12.0, 13.0);
    final spacing = Responsive.scale(context, 3.0, 4.0, 5.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_outline, size: iconSz, color: Colors.grey),
            SizedBox(width: spacing),
            Text(
              '0/0',
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.star, size: iconSz, color: Colors.amber),
            SizedBox(width: spacing),
            Text(
              '0',
              style: TextStyle(
                fontSize: fontSize,
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
