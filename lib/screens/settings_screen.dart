import 'package:flutter/material.dart';
import '../services/audio_service.dart';

/// Pantalla de configuración básica de la aplicación.
/// 
/// Muestra opciones de configuración y preferencias del usuario.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audioService = AudioService();
  bool _autoSpeakEnabled = true;
  bool _soundsEnabled = true;
  double _pitch = 1.0;
  double _rate = 0.5;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAudioSettings();
  }

  Future<void> _loadAudioSettings() async {
    await _audioService.initialize();
    setState(() {
      _autoSpeakEnabled = _audioService.autoSpeakEnabled;
      _soundsEnabled = _audioService.soundsEnabled;
      _pitch = _audioService.pitch;
      _rate = _audioService.rate;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configuración'),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sección de cuenta
          _SettingsSection(
            title: 'Cuenta',
            children: [
              _SettingsTile(
                icon: Icons.person,
                title: 'Perfil',
                subtitle: 'Gestiona tu información personal',
                onTap: () {
                  // TODO: Implementar navegación a perfil detallado
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: Perfil detallado'),
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.history,
                title: 'Historial de lecciones',
                subtitle: 'Revisa tu progreso',
                onTap: () {
                  // TODO: Implementar historial
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: Historial de lecciones'),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sección de audio
          _SettingsSection(
            title: 'Audio',
            children: [
              _SettingsTile(
                icon: Icons.record_voice_over,
                title: 'Pronunciación automática',
                subtitle: 'Pronuncia palabras automáticamente',
                trailing: Switch(
                  value: _autoSpeakEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _autoSpeakEnabled = value;
                    });
                    await _audioService.setAutoSpeak(value);
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.volume_up,
                title: 'Efectos de sonido',
                subtitle: 'Activar sonidos de la aplicación',
                trailing: Switch(
                  value: _soundsEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _soundsEnabled = value;
                    });
                    await _audioService.setSoundsEnabled(value);
                  },
                ),
              ),
              // Pitch slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tune,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tono de voz',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _pitch.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _pitch,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      label: _pitch.toStringAsFixed(1),
                      onChanged: (value) async {
                        setState(() {
                          _pitch = value;
                        });
                        await _audioService.setPitch(value);
                      },
                    ),
                  ],
                ),
              ),
              // Rate slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.speed,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Velocidad de habla',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _rate.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _rate,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: _rate.toStringAsFixed(1),
                      onChanged: (value) async {
                        setState(() {
                          _rate = value;
                        });
                        await _audioService.setRate(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sección de aplicación
          _SettingsSection(
            title: 'Aplicación',
            children: [
              _SettingsTile(
                icon: Icons.notifications,
                title: 'Notificaciones',
                subtitle: 'Gestiona las notificaciones',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implementar guardado de preferencias
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.language,
                title: 'Idioma',
                subtitle: 'Español',
                onTap: () {
                  // TODO: Implementar selector de idioma
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: Selector de idioma'),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sección de ayuda
          _SettingsSection(
            title: 'Ayuda',
            children: [
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Ayuda y soporte',
                subtitle: 'Obtén ayuda sobre la aplicación',
                onTap: () {
                  // TODO: Implementar pantalla de ayuda
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: Ayuda y soporte'),
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Acerca de',
                subtitle: 'Información de la aplicación',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'English Learning',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(
                      Icons.school,
                      size: 48,
                      color: Colors.deepPurple,
                    ),
                    children: const [
                      Text('Aplicación de aprendizaje de inglés para niños.'),
                      SizedBox(height: 8),
                      Text('Aprende inglés de forma divertida con lecciones interactivas.'),
                    ],
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Botón de reset (para testing)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implementar reset de datos
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Próximamente: Reset de datos'),
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Restablecer datos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget que representa una sección de configuración.
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

/// Widget que representa un ítem de configuración.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
      shape: const Border(
        bottom: BorderSide(
          color: Colors.grey,
          width: 0.5,
        ),
      ),
    );
  }
}
