import 'sync_metadata.dart';

enum ConflictResolutionStrategy {
  localWins,
  remoteWins,
  merge,
  manual,
}

class SyncConflict {
  final String conflictId;
  final String userId;
  final String collection;
  final String documentId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final SyncMetadata localMetadata;
  final SyncMetadata remoteMetadata;
  final ConflictResolutionStrategy strategy;
  final DateTime detectedAt;
  final bool resolved;
  final Map<String, dynamic>? resolvedData;
  final DateTime? resolvedAt;

  const SyncConflict({
    required this.conflictId,
    required this.userId,
    required this.collection,
    required this.documentId,
    required this.localData,
    required this.remoteData,
    required this.localMetadata,
    required this.remoteMetadata,
    this.strategy = ConflictResolutionStrategy.manual,
    required this.detectedAt,
    this.resolved = false,
    this.resolvedData,
    this.resolvedAt,
  });

  Map<String, dynamic> toJson() => {
    'conflictId': conflictId,
    'userId': userId,
    'collection': collection,
    'documentId': documentId,
    'localData': localData,
    'remoteData': remoteData,
    'localMetadata': localMetadata.toJson(),
    'remoteMetadata': remoteMetadata.toJson(),
    'strategy': strategy.name,
    'detectedAt': detectedAt.toIso8601String(),
    'resolved': resolved,
    'resolvedData': resolvedData,
    'resolvedAt': resolvedAt?.toIso8601String(),
  };

  factory SyncConflict.fromJson(Map<String, dynamic> json) => SyncConflict(
    conflictId: json['conflictId'] as String,
    userId: json['userId'] as String,
    collection: json['collection'] as String,
    documentId: json['documentId'] as String,
    localData: Map<String, dynamic>.from(json['localData']),
    remoteData: Map<String, dynamic>.from(json['remoteData']),
    localMetadata: SyncMetadata.fromJson(json['localMetadata']),
    remoteMetadata: SyncMetadata.fromJson(json['remoteMetadata']),
    strategy: ConflictResolutionStrategy.values.firstWhere(
      (e) => e.name == json['strategy'],
      orElse: () => ConflictResolutionStrategy.manual,
    ),
    detectedAt: DateTime.parse(json['detectedAt']),
    resolved: json['resolved'] as bool? ?? false,
    resolvedData: json['resolvedData'] != null
        ? Map<String, dynamic>.from(json['resolvedData'])
        : null,
    resolvedAt: json['resolvedAt'] != null
        ? DateTime.parse(json['resolvedAt'])
        : null,
  );

  SyncConflict copyWith({
    String? conflictId,
    String? userId,
    String? collection,
    String? documentId,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
    SyncMetadata? localMetadata,
    SyncMetadata? remoteMetadata,
    ConflictResolutionStrategy? strategy,
    DateTime? detectedAt,
    bool? resolved,
    Map<String, dynamic>? resolvedData,
    DateTime? resolvedAt,
  }) {
    return SyncConflict(
      conflictId: conflictId ?? this.conflictId,
      userId: userId ?? this.userId,
      collection: collection ?? this.collection,
      documentId: documentId ?? this.documentId,
      localData: localData ?? this.localData,
      remoteData: remoteData ?? this.remoteData,
      localMetadata: localMetadata ?? this.localMetadata,
      remoteMetadata: remoteMetadata ?? this.remoteMetadata,
      strategy: strategy ?? this.strategy,
      detectedAt: detectedAt ?? this.detectedAt,
      resolved: resolved ?? this.resolved,
      resolvedData: resolvedData ?? this.resolvedData,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  // Helper methods
  bool get needsResolution {
    return !resolved && strategy == ConflictResolutionStrategy.manual;
  }

  Duration get timeSinceDetection {
    return DateTime.now().difference(detectedAt);
  }

  // Auto-resolution methods
  SyncConflict resolveWithLocal() {
    return copyWith(
      strategy: ConflictResolutionStrategy.localWins,
      resolved: true,
      resolvedData: localData,
      resolvedAt: DateTime.now(),
    );
  }

  SyncConflict resolveWithRemote() {
    return copyWith(
      strategy: ConflictResolutionStrategy.remoteWins,
      resolved: true,
      resolvedData: remoteData,
      resolvedAt: DateTime.now(),
    );
  }

  SyncConflict resolveWithMerge(Map<String, dynamic> mergedData) {
    return copyWith(
      strategy: ConflictResolutionStrategy.merge,
      resolved: true,
      resolvedData: mergedData,
      resolvedAt: DateTime.now(),
    );
  }
}