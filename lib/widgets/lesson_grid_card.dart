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
              padding: EdgeInsets.all(Responsive.scale(context, 8, 10, 12)),
              child: _buildLayout(context, theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, LessonTheme theme) {
    final emojiSize = Responsive.scale(context, 32, 36, 40);
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                  style: TextStyle(fontSize: emojiSize * 0.6),
                ),
              ),
            ),
            SizedBox(height: Responsive.scale(context, 6, 8, 10)),
            Text(
              widget.lesson.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.scale(context, 12, 13, 14),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        if (!widget.isLocked)
          Positioned(
            top: -Responsive.scale(context, 4, 5, 6),
            right: -Responsive.scale(context, 4, 5, 6),
            child: _buildStatusBadge(context),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return FutureBuilder<LessonMasteryStatus>(
      future: widget.evaluator.evaluateLesson(widget.lesson.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final status = snapshot.data!;
        
        switch (status) {
          case LessonMasteryStatus.mastered:
            return Container(
              width: Responsive.scale(context, 20, 22, 24),
              height: Responsive.scale(context, 20, 22, 24),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: Responsive.scale(context, 1.5, 2, 2.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withAlpha(100),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                size: Responsive.scale(context, 12, 14, 16),
                color: Colors.white,
              ),
            );
          case LessonMasteryStatus.inProgress:
            return Container(
              width: Responsive.scale(context, 20, 22, 24),
              height: Responsive.scale(context, 20, 22, 24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: Responsive.scale(context, 1.5, 2, 2.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC107).withAlpha(100),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: Responsive.scale(context, 12, 14, 16),
                color: Colors.white,
              ),
            );
          case LessonMasteryStatus.notStarted:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
