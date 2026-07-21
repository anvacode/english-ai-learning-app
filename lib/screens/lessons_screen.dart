import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/lessons_data.dart';
import '../logic/badge_service.dart';
import '../logic/lesson_completion_service.dart';
import '../logic/lesson_controller.dart';
import '../logic/mastery_evaluator.dart';
import '../models/lesson.dart';
import '../models/lesson_exercise.dart';
import '../services/diagnostic_service.dart';
import '../utils/responsive.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/level_section.dart';
import '../widgets/progress_header.dart';
import 'lesson_flow_screen.dart';
import 'lesson_screen.dart';

class LessonsScreen extends StatefulWidget {
  final bool showNavBar;

  const LessonsScreen({
    super.key,
    this.showNavBar = true,
  });

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final _evaluator = MasteryEvaluator();
  String? _userLevel;
  int _completedLessons = 0;
  int _totalLessons = 0;

  @override
  void initState() {
    super.initState();
    _calculateProgress();
    _loadUserLevel();
    _evaluator.ensureCacheLoaded();
  }

  Future<void> _calculateProgress() async {
    _totalLessons = lessonLevels.fold(0, (sum, level) => sum + level.lessons.length);
    final completedIds = await LessonCompletionService.getCompletedLessonIds();
    if (mounted) {
      setState(() {
        _completedLessons = completedIds.length;
      });
    }
  }

  Future<void> _loadUserLevel() async {
    final level = await DiagnosticService.getUserLevel();
    if (mounted) {
      setState(() {
        _userLevel = level;
      });
    }
  }

  Future<void> _openLesson(Lesson lesson) async {
    final lessonStateChanged = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final hasMatching = lesson.exercises.any(
            (e) => e.type == ExerciseType.matching,
          );

          if (hasMatching) {
            return ChangeNotifierProvider(
              create: (context) => LessonController(),
              child: LessonFlowScreen(
                key: UniqueKey(),
                lesson: lesson,
                exercises: lesson.exercises,
              ),
            );
          }
          return ChangeNotifierProvider(
            create: (context) => LessonController(),
            child: LessonScreen(key: UniqueKey(), lesson: lesson),
          );
        },
      ),
    );

    if (lessonStateChanged == true) {
      MasteryEvaluator.invalidateCache();
      BadgeService.invalidateCache();
      await _calculateProgress();
    }
  }

  bool _isLevelUnlocked(int levelIndex) {
    if (levelIndex == 0) return true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = context.isMobile;
        final isTablet = context.isTablet;
        final horizontalPadding = Responsive.horizontalPadding(context);

        if (isMobile) {
          return _buildMobileLayout(context, horizontalPadding);
        } else if (isTablet) {
          return _buildTabletLayout(context, constraints, horizontalPadding);
        } else {
          return _buildDesktopLayout(context, constraints, horizontalPadding);
        }
      },
    );

    if (widget.showNavBar) {
      return AppScaffold(
        currentIndex: 1,
        child: content,
      );
    }

    return content;
  }

  Widget _buildMobileLayout(BuildContext context, double horizontalPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: ProgressHeader(
              completedLessons: _completedLessons,
              totalLessons: _totalLessons,
              userLevel: _userLevel,
            ),
          ),
          ..._buildLevelCards(horizontalPadding),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, BoxConstraints constraints, double horizontalPadding) {
    final sidebarWidth = 180.0;

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: sidebarWidth,
              child: ProgressHeader(
                completedLessons: _completedLessons,
                totalLessons: _totalLessons,
                userLevel: _userLevel,
                isSidebar: true,
              ),
            ),
            SizedBox(width: horizontalPadding),
            Expanded(
              child: Column(
                children: List.generate(lessonLevels.length, (i) {
                  return LevelSection(
                    level: lessonLevels[i],
                    levelIndex: i,
                    isUnlocked: _isLevelUnlocked(i),
                    evaluator: _evaluator,
                    onLessonTap: _openLesson,
                    startIndex: lessonLevels.take(i).fold(0, (sum, l) => sum + l.lessons.length),
                    gridColumns: 4,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints, double horizontalPadding) {
    final isWide = context.isWide;
    final sidebarWidth = isWide ? 200.0 : 180.0;
    final gridColumns = isWide ? 8 : 6;

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: sidebarWidth,
              child: ProgressHeader(
                completedLessons: _completedLessons,
                totalLessons: _totalLessons,
                userLevel: _userLevel,
                isSidebar: true,
              ),
            ),
            SizedBox(width: horizontalPadding),
            Expanded(
              child: Column(
                children: List.generate(lessonLevels.length, (i) {
                  return LevelSection(
                    level: lessonLevels[i],
                    levelIndex: i,
                    isUnlocked: _isLevelUnlocked(i),
                    evaluator: _evaluator,
                    onLessonTap: _openLesson,
                    startIndex: lessonLevels.take(i).fold(0, (sum, l) => sum + l.lessons.length),
                    gridColumns: gridColumns,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLevelCards(double horizontalPadding) {
    return List.generate(lessonLevels.length, (i) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: LevelSection(
          level: lessonLevels[i],
          levelIndex: i,
          isUnlocked: _isLevelUnlocked(i),
          evaluator: _evaluator,
          onLessonTap: _openLesson,
          startIndex: lessonLevels.take(i).fold(0, (sum, l) => sum + l.lessons.length),
          gridColumns: 2,
        ),
      );
    });
  }
}
