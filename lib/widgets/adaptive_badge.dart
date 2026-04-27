import 'package:flutter/material.dart';
import '../theme/color_palette.dart';
import '../models/practice_activity.dart';

/// Responsive grid layout for badges that adapts to screen size
class ResponsiveBadgeGrid extends StatelessWidget {
  final List<Widget> badges;
  
  const ResponsiveBadgeGrid({required this.badges, super.key});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final mainAxisSpacing = 8.0;
        final crossAxisSpacing = 8.0;
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: badges,
        );
      },
    );
  }
}

class PracticeCardBadge extends StatelessWidget {
  final bool isUnlocked;
  final IconData iconData;

  const PracticeCardBadge({
    required this.isUnlocked,
    required this.iconData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.0,
      height: 48.0,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isUnlocked ? BadgeColors.unlockedLight : BadgeColors.lockedDefault,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 24.0,
        color: isUnlocked ? BadgeColors.unlockedText : BadgeColors.lockedText,
      ),
    );
  }
}

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
    final isMobile = screenWidth < 600;
    final iconSize = isMobile ? 120.0 : 160.0;
    final padding = isMobile ? 16.0 : 24.0;
    final cardElevation = isUnlocked ? 6.0 : 2.0;

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
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    activity.iconEmoji,
                    style: TextStyle(fontSize: isMobile ? 32.0 : 40.0),
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
