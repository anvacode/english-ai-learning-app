import 'package:flutter/material.dart';
import '../theme/color_palette.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Tamaños uniformes por breakpoint
    late final double badgeSize;
    late final double iconSize;
    late final EdgeInsets padding;
    
    if (screenWidth < 414) {
      // Mobile: 48px para accesibilidad WCAG
      badgeSize = 48.0;
      iconSize = 24.0;
      padding = const EdgeInsets.all(8.0);
    } else if (screenWidth < 1200) {
      // Tablet: 40px
      badgeSize = 40.0;
      iconSize = 20.0;
      padding = const EdgeInsets.all(6.0);
    } else {
      // Web/Desktop: 40px para consistencia con tablet
      badgeSize = 40.0;
      iconSize = 20.0;
      padding = const EdgeInsets.all(6.0);
    }
    
    // Usar ConstrainedBox para forzar tamaño mínimo
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: badgeSize,
        minHeight: badgeSize,
      ),
      child: Container(
        width: badgeSize,
        height: badgeSize,
        padding: padding,
        decoration: BoxDecoration(
          color: isUnlocked ? BadgeColors.unlockedLight : BadgeColors.lockedDefault,
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          size: iconSize,
          color: isUnlocked ? BadgeColors.unlockedText : BadgeColors.lockedText,
        ),
      ),
    );
  }
}
