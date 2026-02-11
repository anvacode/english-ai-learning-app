class SyncMetadata {
  final String deviceId;
  final DateTime timestamp;
  final String operationId;
  final int version;

  const SyncMetadata({
    required this.deviceId,
    required this.timestamp,
    required this.operationId,
    required this.version,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'timestamp': timestamp.toIso8601String(),
    'operationId': operationId,
    'version': version,
  };

  factory SyncMetadata.fromJson(Map<String, dynamic> json) => SyncMetadata(
    deviceId: json['deviceId'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    operationId: json['operationId'] as String,
    version: json['version'] as int,
  );

  SyncMetadata copyWith({
    String? deviceId,
    DateTime? timestamp,
    String? operationId,
    int? version,
  }) {
    return SyncMetadata(
      deviceId: deviceId ?? this.deviceId,
      timestamp: timestamp ?? this.timestamp,
      operationId: operationId ?? this.operationId,
      version: version ?? this.version,
    );
  }
}