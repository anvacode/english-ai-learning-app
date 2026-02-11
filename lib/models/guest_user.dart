import 'user_sync_data.dart';

class GuestUser {
  final String guestId;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final UserSyncData? syncData;
  final bool canMigrate;

  const GuestUser({
    required this.guestId,
    required this.createdAt,
    required this.lastActiveAt,
    this.syncData,
    this.canMigrate = true,
  });

  Map<String, dynamic> toJson() => {
    'guestId': guestId,
    'createdAt': createdAt.toIso8601String(),
    'lastActiveAt': lastActiveAt.toIso8601String(),
    'syncData': syncData?.toJson(),
    'canMigrate': canMigrate,
  };

  factory GuestUser.fromJson(Map<String, dynamic> json) => GuestUser(
    guestId: json['guestId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
    syncData: json['syncData'] != null
        ? UserSyncData.fromJson(json['syncData'] as Map<String, dynamic>)
        : null,
    canMigrate: json['canMigrate'] as bool? ?? true,
  );

  GuestUser copyWith({
    String? guestId,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    UserSyncData? syncData,
    bool? canMigrate,
  }) {
    return GuestUser(
      guestId: guestId ?? this.guestId,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      syncData: syncData ?? this.syncData,
      canMigrate: canMigrate ?? this.canMigrate,
    );
  }

  // Helper methods
  bool get isExpired {
    // Guest session expires after 30 days of inactivity
    return DateTime.now().difference(lastActiveAt).inDays > 30;
  }

  bool get hasProgress {
    return syncData != null;
  }

  GuestUser updateActivity() {
    return copyWith(lastActiveAt: DateTime.now());
  }

  GuestUser withSyncData(UserSyncData data) {
    return copyWith(syncData: data);
  }
}