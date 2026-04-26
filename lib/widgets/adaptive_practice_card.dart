import 'package:flutter/material.dart';
import '../theme/icon_sizes.dart';
import 'package:english_ai_app/widgets/adaptive_badge.dart';
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
    final iconSize = isMobile ? IconSizes.sm : IconSizes.md;
    final padding = isMobile ? 8.0 : 12.0;
    final cardElevation = isMobile ? 2.0 : 4.0;

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
                        style: TextStyle(fontSize: iconSize),
                      ),
                    ),
                    const PracticeCardBadge(
                      isUnlocked: false,
                      iconData: Icons.lock,
                    ),
                  ],
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
                if (activity.isUnlocked) ...[
                  const SizedBox(height: 8),
                  Row(
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
