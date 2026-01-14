import 'package:flutter/material.dart';

/// Widget que muestra un avatar circular.
/// 
/// Soporta avatares predefinidos (0-7) usando emojis
/// o un placeholder por defecto.
class AvatarWidget extends StatelessWidget {
  final int avatarId;
  final double size;
  final Color? backgroundColor;

  const AvatarWidget({
    super.key,
    required this.avatarId,
    this.size = 80,
    this.backgroundColor,
  });

  /// Lista de emojis para avatares predefinidos.
  static const List<String> _avatarEmojis = [
    '👤', // 0 - Persona genérica
    '👦', // 1 - Niño
    '👧', // 2 - Niña
    '🧑', // 3 - Persona adulta
    '👨', // 4 - Hombre
    '👩', // 5 - Mujer
    '🦸', // 6 - Superhéroe
    '🦹', // 7 - Supervillano
  ];

  String get _avatarEmoji {
    if (avatarId >= 0 && avatarId < _avatarEmojis.length) {
      return _avatarEmojis[avatarId];
    }
    return _avatarEmojis[0]; // Default
  }

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = backgroundColor ??
        Theme.of(context).colorScheme.primaryContainer;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _avatarEmoji,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}
