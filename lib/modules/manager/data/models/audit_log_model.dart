class AuditLogModel {
  final int? id;
  final String uuid;
  final int userId;
  final String action;
  final String entityType;
  final int? entityId;
  final String? oldValue;
  final String? newValue;
  final String? description;
  final String? deviceInfo;
  final String? ipAddress;
  final DateTime? createdAt;
  final String syncStatus;

  AuditLogModel({
    this.id,
    required this.uuid,
    required this.userId,
    required this.action,
    required this.entityType,
    this.entityId,
    this.oldValue,
    this.newValue,
    this.description,
    this.deviceInfo,
    this.ipAddress,
    this.createdAt,
    this.syncStatus = 'pending',
  });

  factory AuditLogModel.fromMap(Map<String, dynamic> map) {
    return AuditLogModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      userId: map['user_id'] as int? ?? 0,
      action: map['action'] as String? ?? '',
      entityType: map['entity_type'] as String? ?? '',
      entityId: map['entity_id'] as int?,
      oldValue: map['old_value'] as String?,
      newValue: map['new_value'] as String?,
      description: map['description'] as String?,
      deviceInfo: map['device_info'] as String?,
      ipAddress: map['ip_address'] as String?,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'old_value': oldValue,
      'new_value': newValue,
      'description': description,
      'device_info': deviceInfo,
      'ip_address': ipAddress,
      'created_at': createdAt?.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    final map = toMap();
    map.remove('id');
    return map;
  }
}