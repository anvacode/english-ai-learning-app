import 'package:flutter/material.dart';
import '../../logic/user_profile_service.dart';
import '../../logic/badge_service.dart';
import '../../logic/mastery_evaluator.dart';
import '../../data/lessons_data.dart';
import '../../models/user_profile.dart';
import '../../models/badge.dart' as achievement;
import '../../widgets/avatar_widget.dart';
import '../../dialogs/edit_nickname_dialog.dart';
import 'avatar_selection_screen.dart';

/// Pantalla de perfil del usuario.
/// 
/// Muestra información del usuario, estadísticas de progreso
/// y una vista previa de badges.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _profileFuture;
  late Future<double> _progressFuture;
  late Future<List<achievement.Badge>> _badgesFuture;
  bool _isSaving = false;
  String? _saveMessage;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _profileFuture = UserProfileService.loadProfile();
      _progressFuture = _calculateGlobalProgress();
      _badgesFuture = BadgeService.getBadges(lessonsList);
    });
  }

  Future<double> _calculateGlobalProgress() async {
    if (lessonsList.isEmpty) return 0.0;

    final evaluator = MasteryEvaluator();
    double totalProgress = 0.0;

    for (final lesson in lessonsList) {
      final status = await evaluator.evaluateLesson(lesson.id);

      // Map status to progress value
      final lessonProgress = switch (status) {
        LessonMasteryStatus.notStarted => 0.0,
        LessonMasteryStatus.inProgress => 0.5,
        LessonMasteryStatus.mastered => 1.0,
      };

      totalProgress += lessonProgress;
    }

    return totalProgress / lessonsList.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Avatar Section
            FutureBuilder<UserProfile>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const AvatarWidget(avatarId: 0, size: 100);
                }

                final profile = snapshot.data!;
                return Column(
                  children: [
                    // Avatar tappable
                    GestureDetector(
                      onTap: () => _editAvatar(profile),
                      child: AvatarWidget(
                        avatarId: profile.avatarId,
                        size: 100,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Nickname with edit icon (tappable)
                    GestureDetector(
                      onTap: () => _editNickname(profile),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile.nickname,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                    // Save status message
                    if (_saveMessage != null) ...[
                      const SizedBox(height: 12),
                      AnimatedOpacity(
                        opacity: _showSuccess ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _showSuccess
                                ? Colors.green[100]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isSaving)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else if (_showSuccess)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                )
                              else
                                const Icon(
                                  Icons.error,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                              const SizedBox(width: 8),
                              Text(
                                _saveMessage!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _showSuccess
                                      ? Colors.green[900]
                                      : Colors.orange[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Progress Statistics Section
            _buildProgressSection(),

            const SizedBox(height: 32),

            // Badges Preview Section
            _buildBadgesPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progreso',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<double>(
              future: _progressFuture,
              builder: (context, snapshot) {
                final progress = snapshot.data ?? 0.0;
                final percentage = (progress * 100).toStringAsFixed(0);

                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      color: Colors.deepPurple,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$percentage% completado',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesPreview() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Badges',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<achievement.Badge>>(
              future: _badgesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final badges = snapshot.data ?? [];
                final unlockedBadges = badges.where((b) => b.unlocked).toList();

                if (unlockedBadges.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Completa lecciones para desbloquear badges',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: unlockedBadges.take(6).map((badge) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber[400]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          badge.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editNickname(UserProfile profile) async {
    final newNickname = await EditNicknameDialog.show(
      context,
      profile.nickname,
    );

    if (newNickname != null && newNickname != profile.nickname) {
      await _saveNickname(newNickname);
    }
  }

  Future<void> _editAvatar(UserProfile profile) async {
    final newAvatarId = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => AvatarSelectionScreen(
          currentAvatarId: profile.avatarId,
        ),
      ),
    );

    if (newAvatarId != null && newAvatarId != profile.avatarId) {
      await _saveAvatar(newAvatarId);
    }
  }

  Future<void> _saveNickname(String nickname) async {
    setState(() {
      _isSaving = true;
      _saveMessage = 'Guardando...';
      _showSuccess = false;
    });

    try {
      await UserProfileService.updateNickname(nickname);
      setState(() {
        _isSaving = false;
        _saveMessage = 'Nickname guardado';
        _showSuccess = true;
      });

      // Recargar datos
      _loadData();

      // Ocultar mensaje después de 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _saveMessage = null;
            _showSuccess = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
        _saveMessage = 'Error al guardar';
        _showSuccess = false;
      });

      // Ocultar mensaje de error después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _saveMessage = null;
          });
        }
      });
    }
  }

  Future<void> _saveAvatar(int avatarId) async {
    setState(() {
      _isSaving = true;
      _saveMessage = 'Guardando...';
      _showSuccess = false;
    });

    try {
      await UserProfileService.updateAvatar(avatarId);
      setState(() {
        _isSaving = false;
        _saveMessage = 'Avatar guardado';
        _showSuccess = true;
      });

      // Recargar datos
      _loadData();

      // Ocultar mensaje después de 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _saveMessage = null;
            _showSuccess = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
        _saveMessage = 'Error al guardar';
        _showSuccess = false;
      });

      // Ocultar mensaje de error después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _saveMessage = null;
          });
        }
      });
    }
  }
}
