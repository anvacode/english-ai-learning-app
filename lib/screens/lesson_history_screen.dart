import 'package:flutter/material.dart';
import '../logic/activity_result_service.dart';
import '../models/activity_result.dart';
import '../models/lesson.dart';
import '../data/lessons_data.dart';
import '../theme/app_colors.dart';

class LessonHistoryScreen extends StatefulWidget {
  const LessonHistoryScreen({super.key});

  @override
  State<LessonHistoryScreen> createState() => _LessonHistoryScreenState();
}

class _LessonHistoryScreenState extends State<LessonHistoryScreen> {
  List<ActivityResult> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final results = await ActivityResultService.getActivityResults();

    // Agrupar por lessonId y mostrar un resumen por lección
    final Map<String, List<ActivityResult>> groupedByLesson = {};
    for (final result in results) {
      if (result.lessonId.isNotEmpty) {
        groupedByLesson.putIfAbsent(result.lessonId, () => []).add(result);
      }
    }

    // Convertir a lista de resúmenes
    List<MapEntry<String, List<ActivityResult>>> entries = groupedByLesson
        .entries
        .toList();

    // Ordenar por fecha más reciente (usar el timestamp del último resultado)
    entries.sort((a, b) {
      final aTime = a.value.last.timestamp;
      final bTime = b.value.last.timestamp;
      return bTime.compareTo(aTime);
    });

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Lecciones'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
          ? _buildEmptyState()
          : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Sin historial todavía',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completa lecciones para ver tu progreso aquí',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    // Agrupar resultados por lessonId
    final Map<String, List<ActivityResult>> groupedByLesson = {};
    for (final result in _results) {
      groupedByLesson.putIfAbsent(result.lessonId, () => []).add(result);
    }

    final entries = groupedByLesson.entries.toList();

    // Ordenar por fecha más reciente
    entries.sort((a, b) {
      final aTime = a.value.last.timestamp;
      final bTime = b.value.last.timestamp;
      return bTime.compareTo(aTime);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final lessonResults = entry.value;
        final lessonId = entry.key;

        // Calcular métricas de esta lección
        final totalAttempts = lessonResults.length;
        final correctAttempts = lessonResults.where((r) => r.isCorrect).length;
        final accuracy = totalAttempts > 0
            ? (correctAttempts / totalAttempts * 100).round()
            : 0;
        final lastActivity = lessonResults.last.timestamp;

        // Buscar información de la lección
        Lesson? lesson;
        try {
          lesson = lessonsList.firstWhere((l) => l.id == lessonId);
        } catch (_) {
          lesson = null;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withAlpha(25),
              child: Text(
                lesson?.title.isNotEmpty == true
                    ? lesson!.title[0].toUpperCase()
                    : lessonId.replaceAll('lesson_', '')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            title: Text(
              lesson?.title ?? 'Lección ${lessonId.replaceAll("lesson_", "")}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  _formatDate(lastActivity),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      accuracy >= 70 ? Icons.check_circle : Icons.info_outline,
                      size: 16,
                      color: accuracy >= 70
                          ? Colors.green[600]
                          : Colors.orange[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$accuracy% acierto',
                      style: TextStyle(
                        fontSize: 12,
                        color: accuracy >= 70
                            ? Colors.green[600]
                            : Colors.orange[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$totalAttempts intentos',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            trailing: accuracy >= 70
                ? const Chip(label: Text('✅'), padding: EdgeInsets.zero)
                : null,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hoy';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
