class AttendanceModel {
  final int? id;
  final String uuid;
  final int userId;
  final String date;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final double? workHours;
  final String? notes;
  final String syncStatus;

  AttendanceModel({
    this.id,
    required this.uuid,
    required this.userId,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    this.workHours,
    this.notes,
    this.syncStatus = 'pending',
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      userId: map['user_id'] as int? ?? 0,
      date: map['date'] as String? ?? '',
      checkInTime: DateTime.tryParse(map['check_in_time'] as String? ?? '') ?? DateTime.now(),
      checkOutTime: map['check_out_time'] != null ? DateTime.tryParse(map['check_out_time'] as String) : null,
      workHours: (map['work_hours'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'date': date,
      'check_in_time': checkInTime.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'work_hours': workHours,
      'notes': notes,
      'sync_status': syncStatus,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    final map = toMap();
    map.remove('id');
    return map;
  }
}