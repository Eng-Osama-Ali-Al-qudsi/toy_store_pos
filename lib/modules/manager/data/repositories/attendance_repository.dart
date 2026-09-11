import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  final DatabaseHelper _dbHelper;

  AttendanceRepository(this._dbHelper);

  String _generateUuid() {
    return 'uuid-${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<int> checkIn(int userId) async {
    try {
      final now = DateTime.now();
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final existing = await _dbHelper.query(
        DatabaseConstants.tableAttendance,
        where: 'user_id = ? AND date = ? AND check_out_time IS NULL',
        whereArgs: [userId, today],
      );

      if (existing.isNotEmpty) {
        return -2;
      }

      final attendance = AttendanceModel(
        uuid: _generateUuid(),
        userId: userId,
        date: today,
        checkInTime: now,
      );

      return await _dbHelper.insert(
        DatabaseConstants.tableAttendance,
        attendance.toDatabaseMap(),
      );
    } catch (e) {
      return -1;
    }
  }

  Future<int> checkOut(int attendanceId) async {
    try {
      final now = DateTime.now();

      final records = await _dbHelper.query(
        DatabaseConstants.tableAttendance,
        where: 'id = ?',
        whereArgs: [attendanceId],
      );

      if (records.isEmpty) return -1;

      final attendance = AttendanceModel.fromMap(records.first);
      final workHours = now.difference(attendance.checkInTime).inMinutes / 60.0;

      return await _dbHelper.update(
        DatabaseConstants.tableAttendance,
        {
          'check_out_time': now.toIso8601String(),
          'work_hours': workHours,
          'sync_status': 'updated',
        },
        where: 'id = ?',
        whereArgs: [attendanceId],
      );
    } catch (e) {
      return -1;
    }
  }

  Future<AttendanceModel?> getTodayAttendance(int userId) async {
    try {
      final now = DateTime.now();
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final records = await _dbHelper.query(
        DatabaseConstants.tableAttendance,
        where: 'user_id = ? AND date = ?',
        whereArgs: [userId, today],
        orderBy: 'check_in_time DESC',
      );

      if (records.isNotEmpty) {
        return AttendanceModel.fromMap(records.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<AttendanceModel>> getAttendanceByUser(int userId) async {
    try {
      final records = await _dbHelper.query(
        DatabaseConstants.tableAttendance,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC, check_in_time DESC',
      );

      return records.map((record) => AttendanceModel.fromMap(record)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<AttendanceModel>> getAllAttendance() async {
    try {
      final records = await _dbHelper.query(
        DatabaseConstants.tableAttendance,
        orderBy: 'date DESC, check_in_time DESC',
      );

      return records.map((record) => AttendanceModel.fromMap(record)).toList();
    } catch (e) {
      return [];
    }
  }
}