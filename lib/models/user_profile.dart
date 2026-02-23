/// Modelo que representa el perfil del usuario.
///
/// Contiene información básica del usuario como nickname,
/// avatar seleccionado, nivel de inglés y fecha de creación.
class UserProfile {
  final String nickname;
  final int avatarId;
  final String? englishLevel;
  final DateTime createdAt;

  const UserProfile({
    required this.nickname,
    required this.avatarId,
    this.englishLevel,
    required this.createdAt,
  });

  factory UserProfile.defaultProfile() {
    return UserProfile(
      nickname: 'Estudiante',
      avatarId: 0,
      englishLevel: null,
      createdAt: DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? nickname,
    int? avatarId,
    String? englishLevel,
    DateTime? createdAt,
    bool clearEnglishLevel = false,
  }) {
    return UserProfile(
      nickname: nickname ?? this.nickname,
      avatarId: avatarId ?? this.avatarId,
      englishLevel: clearEnglishLevel
          ? null
          : (englishLevel ?? this.englishLevel),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'avatarId': avatarId,
      'englishLevel': englishLevel,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'] as String,
      avatarId: json['avatarId'] as int,
      englishLevel: json['englishLevel'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool get isValidAvatarId => avatarId >= 0 && avatarId <= 10;

  bool get isShopAvatar => avatarId >= 8 && avatarId <= 10;

  String get englishLevelDisplayName {
    switch (englishLevel) {
      case 'beginner':
        return 'Principiante';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      default:
        return 'No determinado';
    }
  }
}
