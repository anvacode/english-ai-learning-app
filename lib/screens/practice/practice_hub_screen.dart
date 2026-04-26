import 'package:flutter/material.dart';
import '../../models/practice_activity.dart';
import '../../logic/practice_service.dart';
import '../../logic/star_service.dart';
import "../../widgets/adaptive_practice_card.dart";
import '../../widgets/responsive_container.dart';
import '../../utils/responsive.dart';
import '../../theme/app_colors.dart';
import 'spelling_practice_screen.dart';
import 'listening_practice_screen.dart';
import 'speed_match_screen.dart';
import 'memory_game_screen.dart';
import 'pronunciation_practice_screen.dart';
import 'phrase_practice_screen.dart';

/// Pantalla principal del hub de prácticas
class PracticeHubScreen extends StatefulWidget {
  const PracticeHubScreen({super.key});

  @override
  State<PracticeHubScreen> createState() => _PracticeHubScreenState();
}

class _PracticeHubScreenState extends State<PracticeHubScreen> {
  String? _selectedLessonFilter;
  bool _isLoading = true;
  List<PracticeActivity> _activities = [];
  Map<String, dynamic> _progressMap = {};
  int _totalStars = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Cargar actividades con estado de desbloqueo
      final activities =
          await PracticeService.getAllActivitiesWithUnlockStatus();

      // Cargar progreso de todas las actividades
      final progressMap = await PracticeService.getAllProgress();

      // Obtener estrellas totales globales
      final totalStars = await StarService.getTotalStars();

      setState(() {
        _activities = activities;
        _progressMap = progressMap;
        _totalStars = totalStars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar actividades: $e')),
        );
      }
    }
  }

  List<PracticeActivity> get _filteredActivities {
    if (_selectedLessonFilter == null) return _activities;
    return _activities
        .where((a) => a.lessonId == _selectedLessonFilter)
        .toList();
  }

  void _onActivityTap(PracticeActivity activity) {
    if (!activity.isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta actividad aún no está desbloqueada'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navegar a la pantalla correspondiente según el tipo
    switch (activity.type) {
      case PracticeActivityType.spelling:
        _navigateToSpelling(activity);
        break;
      case PracticeActivityType.listening:
        _navigateToListening(activity);
        break;
      case PracticeActivityType.speedMatch:
        _navigateToSpeedMatch(activity);
        break;
      case PracticeActivityType.wordScramble:
        _showComingSoon('Word Scramble');
        break;
      case PracticeActivityType.fillBlanks:
        _showComingSoon('Fill the Blanks');
        break;
      case PracticeActivityType.pictureMemory:
        _navigateToMemory(activity);
        break;
      case PracticeActivityType.trueFalse:
        _showComingSoon('True or False');
        break;
      case PracticeActivityType.pronunciation:
        _navigateToPronunciation();
        break;
    }
  }

  void _navigateToSpelling(PracticeActivity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpellingPracticeScreen(activity: activity),
      ),
    ).then((_) {
      // Recargar datos cuando vuelve de la actividad
      _loadData();
    });
  }

  void _navigateToListening(PracticeActivity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ListeningPracticeScreen(lessonId: activity.lessonId),
      ),
    ).then((_) {
      // Recargar datos cuando vuelve de la actividad
      _loadData();
    });
  }

  void _navigateToSpeedMatch(PracticeActivity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeedMatchScreen(lessonId: activity.lessonId),
      ),
    ).then((_) {
      // Recargar datos cuando vuelve de la actividad
      _loadData();
    });
  }

  void _navigateToMemory(PracticeActivity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryGameScreen(lessonId: activity.lessonId),
      ),
    ).then((_) {
      // Recargar datos cuando vuelve de la actividad
      _loadData();
    });
  }

  void _navigateToPronunciation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PronunciationPracticeScreen(),
      ),
    ).then((_) {
      _loadData();
    });
  }

  void _navigateToPhrasePractice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PhrasePracticeScreen()),
    ).then((_) {
      _loadData();
    });
  }

  void _showComingSoon(String activityName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚧 Próximamente'),
        content: Text('$activityName estará disponible pronto!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = Responsive.gridColumns(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Práctica y Juegos'),
        actions: [
          // Contador de estrellas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 4),
                Text(
                  '$_totalStars',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ResponsiveContainer(
                child: CustomScrollView(
                  slivers: [
                    // Header con estadísticas
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildStatsHeader(),
                      ),
                    ),

                    // Filtro por lección
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildLessonFilter(),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // Grid de actividades
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: _filteredActivities.isEmpty
                          ? SliverToBoxAdapter(child: _buildEmptyState())
                          : SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    // Aspect ratio responsivo: móvil más alto, web más cuadrado
                                    childAspectRatio:
                                        Responsive.isMobile(context)
                                        ? 0.75
                                        : (Responsive.isTablet(context)
                                              ? 0.95
                                              : 1.1),
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final activity = _filteredActivities[index];
                                final progress = _progressMap[activity.id];
                                return AdaptivePracticeCard(
                                  activity: activity,
                                  isUnlocked: progress != null,
                                  onTap: () => _onActivityTap(activity),
                                );
                              }, childCount: _filteredActivities.length),
                            ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToPhrasePractice,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text(
          'Práctica de Frases',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatsHeader() {
    final completedCount = _progressMap.values
        .where((p) => p.isCompleted)
        .length;
    final totalCount = _activities.where((a) => a.isUnlocked).length;
    final practiceStars = _progressMap.values.fold(
      0,
      (sum, p) => sum + (p.starsEarned as int),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(76),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Tu Progreso',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.check_circle,
                value: '$completedCount/$totalCount',
                label: 'Completadas',
              ),
              _buildStatItem(
                icon: Icons.star,
                value: '$practiceStars',
                label: 'Estrellas',
              ),
              _buildStatItem(
                icon: Icons.lock_open,
                value: '${_activities.where((a) => a.isUnlocked).length}',
                label: 'Desbloqueadas',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLessonFilter() {
    // Obtener lecciones únicas
    final lessonIds = _activities.map((a) => a.lessonId).toSet().toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Opción "Todas"
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Todas'),
              selected: _selectedLessonFilter == null,
              onSelected: (selected) {
                setState(() => _selectedLessonFilter = null);
              },
            ),
          ),
          // Opciones por lección
          ...lessonIds.map((lessonId) {
            final activity = _activities.firstWhere(
              (a) => a.lessonId == lessonId,
            );
            final lessonTitle = activity.title.split(':').last.trim();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(lessonTitle),
                selected: _selectedLessonFilter == lessonId,
                onSelected: (selected) {
                  setState(() {
                    _selectedLessonFilter = selected ? lessonId : null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay actividades disponibles',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completa más lecciones para desbloquear actividades',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
