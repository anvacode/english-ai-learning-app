import 'sync_metadata.dart';

enum SyncOperationType {
  create,
  update,
  delete,
}

enum SyncStatus {
  pending,
  processing,
  completed,
  failed,
}

class SyncOperation {
  final String id;
  final String userId;
  final SyncOperationType type;
  final String collection;
  final String documentId;
  final Map<String, dynamic> data;
  final SyncMetadata metadata;
  final SyncStatus status;
  final int retryCount;
  final String? errorMessage;
  final DateTime? completedAt;

  const SyncOperation({
    required this.id,
    required this.userId,
    required this.type,
    required this.collection,
    required this.documentId,
    required this.data,
    required this.metadata,
    this.status = SyncStatus.pending,
    this.retryCount = 0,
    this.errorMessage,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.name,
    'collection': collection,
    'documentId': documentId,
    'data': data,
    'metadata': metadata.toJson(),
    'status': status.name,
    'retryCount': retryCount,
    'errorMessage': errorMessage,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
    id: json['id'] as String,
    userId: json['userId'] as String,
    type: SyncOperationType.values.firstWhere(
      (e) => e.name == json['type'],
    ),
    collection: json['collection'] as String,
    documentId: json['documentId'] as String,
    data: Map<String, dynamic>.from(json['data'] as Map),
    metadata: SyncMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    status: SyncStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => SyncStatus.pending,
    ),
    retryCount: json['retryCount'] as int? ?? 0,
    errorMessage: json['errorMessage'] as String?,
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String)
        : null,
  );

  SyncOperation copyWith({
    String? id,
    String? userId,
    SyncOperationType? type,
    String? collection,
    String? documentId,
    Map<String, dynamic>? data,
    SyncMetadata? metadata,
    SyncStatus? status,
    int? retryCount,
    String? errorMessage,
    DateTime? completedAt,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      collection: collection ?? this.collection,
      documentId: documentId ?? this.documentId,
      data: data ?? this.data,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get isExpired {
    // Consider operation expired after 7 days
    return DateTime.now().difference(metadata.timestamp).inDays > 7;
  }

  bool get canRetry {
    return retryCount < 3 && status != SyncStatus.completed;
  }
}