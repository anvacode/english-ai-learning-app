import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../logic/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../services/firestore_progress_service.dart';
import '../utils/web_download.dart' as web_download;
import '../widgets/responsive_container.dart';
import '../widgets/responsive_snack_bar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<UserSummary> _users = [];
  List<UserSummary> _filteredUsers = [];
  GlobalStats _stats = const GlobalStats();
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final users = await FirestoreProgressService().getAllUsers();
    final stats = await FirestoreProgressService().getGlobalStats();
    if (mounted) {
      setState(() {
        _users = users;
        _filteredUsers = users;
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((u) {
          return u.email.toLowerCase().contains(query.toLowerCase()) ||
              (u.nickname?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _exportCsv() async {
    try {
      final csvContent = await FirestoreProgressService().exportUsersCsv();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'users_export_$timestamp.csv';

      if (kIsWeb) {
        await _downloadCsvWeb(csvContent, fileName);
      } else {
        await _downloadCsvMobile(csvContent, fileName);
      }

      if (mounted) {
        ResponsiveSnackBar.showSuccess(
          context,
          message: '✅ CSV exportado correctamente',
        );
      }
    } catch (e) {
      if (mounted) {
        ResponsiveSnackBar.showError(
          context,
          message: 'Error al exportar: $e',
        );
      }
    }
  }

  Future<void> _downloadCsvWeb(String content, String fileName) async {
    if (!kIsWeb) return;

    try {
      web_download.triggerWebDownload(content, fileName);
    } catch (_) {
      if (mounted) {
        ResponsiveSnackBar.showInfo(
          context,
          message: 'Descarga web no disponible. Contenido CSV generado para $fileName',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _downloadCsvMobile(String content, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);

    if (mounted) {
      ResponsiveSnackBar.showSuccess(
        context,
        message: '📁 Guardado en: ${file.path}',
        duration: const Duration(seconds: 5),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Nunca';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Panel de Admin'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exportar CSV',
            onPressed: _exportCsv,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text(
                    '¿Estás seguro de que quieres cerrar sesión?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                try {
                  await context.read<AuthProvider>().signOut();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ResponsiveSnackBar.showError(
                      context,
                      message: 'Error al cerrar sesión: $e',
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveContainer(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    _buildStatsGrid(),
                    const SizedBox(height: 14),
                    _buildSearchBar(),
                    const SizedBox(height: 8),
                    _buildUsersList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      children: [
        _StatCard(
          icon: Icons.people,
          label: 'Usuarios',
          value: _stats.totalUsers.toString(),
          color: Colors.blue,
        ),
        _StatCard(
          icon: Icons.play_circle,
          label: 'Sesiones',
          value: _stats.totalSessions.toString(),
          color: Colors.purple,
        ),
        _StatCard(
          icon: Icons.check_circle,
          label: 'Completadas',
          value: _stats.totalCompletedLessons.toString(),
          color: Colors.green,
        ),
        _StatCard(
          icon: Icons.local_fire_department,
          label: 'Activos hoy',
          value: _stats.activeToday.toString(),
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Buscar usuario...',
        hintStyle: const TextStyle(fontSize: 15),
        prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  _filterUsers('');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: _filterUsers,
    );
  }

  Widget _buildUsersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            'Usuarios (${_filteredUsers.length})',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        if (_filteredUsers.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.person_off, size: 36, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    _searchController.text.isNotEmpty
                        ? 'Sin resultados'
                        : 'Sin usuarios registrados',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: _filteredUsers.map((user) {
                return _UserTile(
                  user: user,
                  formatDate: _formatDate,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailScreen(
                          uid: user.uid,
                          email: user.email,
                          nickname: user.nickname,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class UserDetailScreen extends StatefulWidget {
  final String uid;
  final String email;
  final String? nickname;

  const UserDetailScreen({
    super.key,
    required this.uid,
    required this.email,
    this.nickname,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  UserMetrics? _metrics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    final metrics = await FirestoreProgressService().getUserMetricsByUid(
      widget.uid,
    );
    if (mounted) {
      setState(() {
        _metrics = metrics;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Nunca';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nickname ?? widget.email),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMetrics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _metrics == null
              ? const Center(
                  child: Text('No se pudieron cargar las métricas.'),
                )
              : RefreshIndicator(
                  onRefresh: _loadMetrics,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildUserHeader(),
                      const SizedBox(height: 20),
                      _buildSessionCard(),
                      const SizedBox(height: 20),
                      _buildLessonProgressList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildUserHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.nickname ?? widget.email,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.nickname != null)
                        Text(
                          widget.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'UID: ${widget.uid}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text(
                  'Frecuencia de Uso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    icon: Icons.play_circle,
                    label: 'Sesiones totales',
                    value: _metrics!.totalSessions.toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBox(
                    icon: Icons.schedule,
                    label: 'Última actividad',
                    value: _formatDate(_metrics!.lastActive),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonProgressList() {
    final lessons = _metrics!.progress.entries.toList();

    if (lessons.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.school_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'Aún no hay progreso de lecciones',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Progreso por Lección (${lessons.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(
            children: lessons.map((entry) {
              final lessonId = entry.key;
              final progress = entry.value;
              return _LessonProgressTile(
                lessonId: lessonId,
                progress: progress,
                formatDate: _formatDate,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserSummary user;
  final String Function(DateTime?) formatDate;
  final VoidCallback onTap;

  const _UserTile({
    required this.user,
    required this.formatDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person, color: Colors.deepPurple, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nickname ?? user.email,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.play_circle_outline, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 3),
                          Text('${user.totalSessions}', style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 10),
                          Icon(Icons.school_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 3),
                          Text('${user.completedLessons}/${user.totalLessons}', style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 10),
                          Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 3),
                          Text(
                            formatDate(user.lastActive),
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _LessonProgressTile extends StatelessWidget {
  final String lessonId;
  final dynamic progress;
  final String Function(DateTime?) formatDate;

  const _LessonProgressTile({
    required this.lessonId,
    required this.progress,
    required this.formatDate,
  });

  String _formatLessonId(String id) {
    return id
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            progress.completed ? Icons.check_circle : Icons.pending,
            color: progress.completed ? Colors.green : Colors.orange,
          ),
          title: Text(
            _formatLessonId(lessonId),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text('${progress.stars} estrellas'),
                  const SizedBox(width: 16),
                  const Icon(Icons.trending_up, color: Colors.blue, size: 16),
                  const SizedBox(width: 4),
                  Text('${progress.bestAccuracy.toStringAsFixed(0)}%'),
                  const SizedBox(width: 16),
                  const Icon(Icons.replay, color: Colors.purple, size: 16),
                  const SizedBox(width: 4),
                  Text('${progress.attempts} intentos'),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Última vez: ${formatDate(progress.lastPlayed)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          isThreeLine: true,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
