import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/user_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';

class AttendanceScreen extends StatefulWidget {
  final UserModel user;

  const AttendanceScreen({super.key, required this.user});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceRepository _attendanceRepository = AttendanceRepository(DatabaseHelper.instance);

  List<AttendanceModel> _todayAttendance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final allAttendance = await _attendanceRepository.getAllAttendance();
    final todayRecords = allAttendance.where((a) => a.date == dateStr).toList();

    setState(() {
      _todayAttendance = todayRecords;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حضور اليوم')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _todayAttendance.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('لا يوجد حضور مسجل اليوم', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadAttendance,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _todayAttendance.length,
          itemBuilder: (context, index) {
            final attendance = _todayAttendance[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF2E7D32)),
                ),
                title: Text('مستخدم ${attendance.userId}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('دخول: ${attendance.checkInTime.hour}:${attendance.checkInTime.minute.toString().padLeft(2, '0')}'),
                    if (attendance.checkOutTime != null)
                      Text('خروج: ${attendance.checkOutTime!.hour}:${attendance.checkOutTime!.minute.toString().padLeft(2, '0')}'),
                    if (attendance.workHours != null)
                      Text('ساعات: ${attendance.workHours!.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}