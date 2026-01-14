/// Modelo que representa el perfil del usuario.
/// 
/// Contiene información básica del usuario como nickname,
/// avatar seleccionado y fecha de creación.
class UserProfile {
  final String nickname;
  final int avatarId; // 0-7 para avatares predefinidos
  final DateTime createdAt;

  const UserProfile({
    required this.nickname,
    required this.avatarId,
    required this.createdAt,
  });

  /// Crea un perfil con valores por defecto.
  factory UserProfile.defaultProfile() {
    return UserProfile(
      nickname: 'Estudiante',
      avatarId: 0,
      createdAt: DateTime.now(),
    );
  }

  /// Crea una copia del perfil con campos actualizados.
  UserProfile copyWith({
    String? nickname,
    int? avatarId,
    DateTime? createdAt,
  }) {
    return UserProfile(
      nickname: nickname ?? this.nickname,
      avatarId: avatarId ?? this.avatarId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convierte el perfil a JSON para almacenamiento.
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'avatarId': avatarId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Crea un perfil desde JSON.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'] as String,
      avatarId: json['avatarId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Valida que el avatarId esté en el rango válido (0-7).
  bool get isValidAvatarId => avatarId >= 0 && avatarId <= 7;
}
