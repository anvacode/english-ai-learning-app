import 'package:flutter/material.dart';

import '../../data/lesson_themes.dart';
import '../../logic/mastery_evaluator.dart';
import '../../models/lesson.dart';
import '../../utils/responsive.dart';

class LessonGridCard extends StatefulWidget {
  final Lesson lesson;
  final MasteryEvaluator evaluator;
  final bool isLocked;
  final VoidCallback? onTap;
  final int index;

  const LessonGridCard({
    super.key,
    required this.lesson,
    required this.evaluator,
    required this.isLocked,
    required this.onTap,
    required this.index,
  });

  @override
  State<LessonGridCard> createState() => _LessonGridCardState();
}

class _LessonGridCardState extends State<LessonGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = getLessonTheme(widget.lesson.id);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: _buildCard(context, theme),
      ),
    );
  }

  Widget _buildCard(BuildContext context, LessonTheme theme) {
    final borderRadius = Responsive.scale(context, 10, 12, 14);
    final isMobile = context.isMobile;

    return Container(
      decoration: BoxDecoration(
        gradient: widget.isLocked
            ? LinearGradient(
                colors: [Colors.grey[400]!, Colors.grey[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : theme.gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: widget.isLocked
                ? Colors.grey.withAlpha(30)
                : theme.gradientColors.first.withAlpha(_isHovered ? 60 : 35),
            blurRadius: _isHovered ? 12 : 8,
            offset: Offset(0, _isHovered ? 4 : 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLocked ? null : widget.onTap,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 8 : Responsive.scale(context, 10, 12, 14)),
              child: isMobile ? _buildMobileLayout(context, theme) : _buildDesktopLayout(context, theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, LessonTheme theme) {
    final emojiSize = 24.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: emojiSize,
          height: emojiSize,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(widget.isLocked ? 60 : 35),
            borderRadius: BorderRadius.circular(emojiSize * 0.3),
          ),
          child: Center(
            child: Text(
              widget.isLocked ? '🔒' : theme.emoji,
              style: TextStyle(fontSize: emojiSize * 0.65),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          widget.lesson.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2),
        Row(
          children: [
            Text(
              '#${widget.index + 1}',
              style: TextStyle(
                color: Colors.white.withAlpha(140),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            _buildStatusIcon(context),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, LessonTheme theme) {
    final emojiSize = Responsive.scale(context, 36, 40, 44);
    
    return Row(
      children: [
        Container(
          width: emojiSize,
          height: emojiSize,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(widget.isLocked ? 60 : 35),
            borderRadius: BorderRadius.circular(emojiSize * 0.3),
          ),
          child: Center(
            child: Text(
              widget.isLocked ? '🔒' : theme.emoji,
              style: TextStyle(fontSize: emojiSize * 0.6),
            ),
          ),
        ),
        SizedBox(width: Responsive.scale(context, 8, 10, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.lesson.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.scale(context, 12, 13, 14),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              Text(
                '#${widget.index + 1}',
                style: TextStyle(
                  color: Colors.white.withAlpha(140),
                  fontSize: Responsive.scale(context, 10, 11, 11),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
        SizedBox(width: 6),
        _buildStatusIcon(context),
      ],
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    if (widget.isLocked) {
      return Text(
        '🔒',
        style: TextStyle(fontSize: Responsive.scale(context, 14, 16, 18)),
      );
    }

    return FutureBuilder<LessonMasteryStatus>(
      future: widget.evaluator.evaluateLesson(widget.lesson.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            width: 16,
            height: 16,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          );
        }

        final status = snapshot.data!;
        late IconData icon;
        late Color iconColor;

        switch (status) {
          case LessonMasteryStatus.notStarted:
            icon = Icons.play_arrow_rounded;
            iconColor = Colors.white.withAlpha(180);
            break;
          case LessonMasteryStatus.inProgress:
            icon = Icons.refresh_rounded;
            iconColor = Colors.amber;
            break;
          case LessonMasteryStatus.mastered:
            icon = Icons.check_circle_rounded;
            iconColor = Colors.green;
            break;
        }

        return Icon(
          icon,
          size: Responsive.scale(context, 18, 20, 22),
          color: iconColor,
        );
      },
    );
  }
}
