import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/lessons_data.dart';
import '../logic/mastery_evaluator.dart';
import '../logic/badge_service.dart';
import '../logic/lesson_controller.dart';
import '../models/lesson.dart';
import '../models/lesson_exercise.dart';
import '../models/badge.dart' as achievement;
import '../widgets/star_display.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_container.dart';
import '../theme/text_styles.dart';
import '../services/diagnostic_service.dart';
import 'lesson_screen.dart';
import 'lesson_flow_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final _evaluator = MasteryEvaluator();
  late Future<void> _lessonStatusesFuture;
  String? _userLevel;
  List<String> _recommendedLessonIds = [];

  @override
  void initState() {
    super.initState();
    _lessonStatusesFuture = Future.value();
    _loadUserLevel();
  }

  Future<void> _loadUserLevel() async {
    final level = await DiagnosticService.getUserLevel();

    if (mounted) {
      setState(() {
        _userLevel = level;
        _recommendedLessonIds = _getRecommendedLessons(level);
      });
    }
  }

  List<String> _getRecommendedLessons(String? level) {
    switch (level) {
      case 'beginner':
        return ['colors', 'fruits', 'animals', 'numbers'];
      case 'intermediate':
        return ['daily_routines', 'weather_seasons', 'occupations'];
      case 'advanced':
        return ['verb_tenses', 'prepositions', 'adjectives_opposites'];
      default:
        return [];
    }
  }

  Color _getLevelColor() {
    switch (_userLevel) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(LessonMasteryStatus status) {
    switch (status) {
      case LessonMasteryStatus.notStarted:
        return Colors.grey;
      case LessonMasteryStatus.inProgress:
        return Colors.amber;
      case LessonMasteryStatus.mastered:
        return Colors.green;
    }
  }

  IconData _getLevelIcon(int levelIndex) {
    switch (levelIndex) {
      case 0:
        return Icons.school; // Principiante
      case 1:
        return Icons.auto_awesome; // Intermedio
      case 2:
        return Icons.workspace_premium; // Avanzado
      default:
        return Icons.book;
    }
  }

  String _getStatusText(LessonMasteryStatus status) {
    switch (status) {
      case LessonMasteryStatus.notStarted:
        return 'No iniciado';
      case LessonMasteryStatus.inProgress:
        return 'En progreso';
      case LessonMasteryStatus.mastered:
        return 'Dominado';
    }
  }

  Future<void> _openLesson(Lesson lesson) async {
    final lessonStateChanged = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          // Check if lesson has matching exercise
          final hasMatching = lesson.exercises.any(
            (e) => e.type == ExerciseType.matching,
          );

          // Use LessonFlowScreen for lessons with matching exercise (Animals, Family)
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
          // Use standard LessonScreen for lessons with only multiple-choice
          return ChangeNotifierProvider(
            create: (context) => LessonController(),
            child: LessonScreen(key: UniqueKey(), lesson: lesson),
          );
        },
      ),
    );

    // If lesson state changed (completed), rebuild lesson statuses
    if (lessonStateChanged == true) {
      setState(() {
        // Recreate the future to force FutureBuilder to re-evaluate lesson statuses
        _lessonStatusesFuture = Future.value();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lecciones', style: context.headline2),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: context.horizontalPadding),
            child: Center(
              child: StarDisplay(
                iconSize: context.isMobile ? 24 : 28,
                fontSize: context.isMobile ? 18 : 20,
                showBackground: true,
              ),
            ),
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: FutureBuilder<void>(
          future: _lessonStatusesFuture,
          builder: (context, snapshot) {
            if (lessonLevels.isEmpty) {
              return const Center(child: Text('No lessons available'));
            }

            final hasRecommendations =
                _userLevel != null && _recommendedLessonIds.isNotEmpty;

            return CustomScrollView(
              slivers: [
                if (hasRecommendations) ...[
                  SliverToBoxAdapter(child: _buildRecommendationBanner()),
                ],
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final level = lessonLevels[index];
                    final levelIndex = index;
                    final isBeginnerLevel = levelIndex == 0;

                    return FutureBuilder<bool>(
                      future: Future.value(true),
                      builder: (context, snapshot) {
                        final isLevelUnlocked = snapshot.data ?? false;

                        final lockIcon = (!isLevelUnlocked && !isBeginnerLevel)
                            ? ' 🔒'
                            : '';

                        Widget tileContent;
                        if (level.lessons.isEmpty) {
                          tileContent = Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'No lessons available',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          );
                        } else if (!isLevelUnlocked && !isBeginnerLevel) {
                          tileContent = Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              'Completa el nivel anterior para desbloquear',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          );
                        } else {
                          tileContent = Column(
                            children: level.lessons
                                .map(
                                  (lesson) => LessonListItem(
                                    lesson: lesson,
                                    evaluator: _evaluator,
                                    getStatusColor: _getStatusColor,
                                    getStatusText: _getStatusText,
                                    isLocked:
                                        !isLevelUnlocked && !isBeginnerLevel,
                                    onTap: () => _openLesson(lesson),
                                  ),
                                )
                                .toList(),
                          );
                        }

                        return Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(20),
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(51),
                                width: 2,
                              ),
                            ),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary.withAlpha(76),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _getLevelIcon(levelIndex),
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${level.title}$lockIcon',
                                      style: TextStyle(
                                        fontSize: context.isMobile
                                            ? 18
                                            : (context.isTablet ? 20 : 22),
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.horizontalPadding,
                                    vertical: 8.0,
                                  ),
                                  child: tileContent,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }, childCount: lessonLevels.length),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecommendationBanner() {
    return Container(
      margin: EdgeInsets.only(
        left: context.horizontalPadding,
        right: context.horizontalPadding,
        bottom: 16,
        top: context.horizontalPadding,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getLevelColor().withAlpha(30),
            _getLevelColor().withAlpha(10),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getLevelColor().withAlpha(50), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getLevelColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recomendado para ti',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getLevelColor(),
                      ),
                    ),
                    Text(
                      'Basado en tu nivel ${_getLevelDisplayName()}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recommendedLessonIds.map((lessonId) {
              final lesson = _findLessonById(lessonId);
              if (lesson == null) return const SizedBox.shrink();

              return InkWell(
                onTap: () => _openLesson(lesson),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getLevelColor().withAlpha(50)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 18,
                        color: _getLevelColor(),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        lesson.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _getLevelColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getLevelDisplayName() {
    switch (_userLevel) {
      case 'beginner':
        return 'Principiante';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      default:
        return '';
    }
  }

  Lesson? _findLessonById(String id) {
    for (final level in lessonLevels) {
      for (final lesson in level.lessons) {
        if (lesson.id == id) {
          return lesson;
        }
      }
    }
    return null;
  }
}

/// Widget que representa un ítem de lección en la lista.
class LessonListItem extends StatelessWidget {
  final Lesson lesson;
  final MasteryEvaluator evaluator;
  final Function(LessonMasteryStatus) getStatusColor;
  final Function(LessonMasteryStatus) getStatusText;
  final bool isLocked;
  final VoidCallback onTap;

  const LessonListItem({
    super.key,
    required this.lesson,
    required this.evaluator,
    required this.getStatusColor,
    required this.getStatusText,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Opacity(
            opacity: isLocked ? 0.6 : 1.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Título/ID de la lección
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lesson.title,
                              style: TextStyle(
                                fontSize: context.isMobile
                                    ? 16
                                    : (context.isTablet ? 17 : 18),
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Badge icon if mastered
                          FutureBuilder<achievement.Badge?>(
                            future: BadgeService.getBadge(lesson),
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data != null &&
                                  snapshot.data!.unlocked) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    snapshot.data!.icon,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${lesson.id}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Badge de estado de dominio o lock
                if (isLocked)
                  const Text('🔒', style: TextStyle(fontSize: 24))
                else
                  FutureBuilder<LessonMasteryStatus>(
                    future: evaluator.evaluateLesson(lesson.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }

                      final status = snapshot.data!;
                      final statusColor = getStatusColor(status);
                      final statusText = getStatusText(status);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(230),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
