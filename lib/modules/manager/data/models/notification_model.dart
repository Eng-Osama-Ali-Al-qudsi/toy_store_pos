class NotificationModel {
  final int? id;
  final String uuid;
  final int? userId;
  final String title;
  final String body;
  final String? type;
  final bool isRead;
  final DateTime? createdAt;
  final String syncStatus;

  NotificationModel({
    this.id,
    required this.uuid,
    this.userId,
    required this.title,
    required this.body,
    this.type,
    this.isRead = false,
    this.createdAt,
    this.syncStatus = 'pending',
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      userId: map['user_id'] as int?,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: map['type'] as String?,
      isRead: (map['is_read'] as int? ?? 0) == 1,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'is_read': isRead ? 1 : 0,
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