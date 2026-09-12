import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../manager/data/models/user_model.dart';
import '../../../manager/data/models/attendance_model.dart';
import '../../../manager/data/repositories/attendance_repository.dart';

class WorkerAttendanceScreen extends StatefulWidget {
  final UserModel user;

  const WorkerAttendanceScreen({super.key, required this.user});

  @override
  State<WorkerAttendanceScreen> createState() => _WorkerAttendanceScreenState();
}

class _WorkerAttendanceScreenState extends State<WorkerAttendanceScreen> {
  final AttendanceRepository _attendanceRepository = AttendanceRepository(DatabaseHelper.instance);

  AttendanceModel? _todayAttendance;
  List<AttendanceModel> _history = [];
  bool _isLoading = true;
  bool _isCheckedIn = false;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    final today = await _attendanceRepository.getTodayAttendance(widget.user.id!);
    final history = await _attendanceRepository.getAttendanceByUser(widget.user.id!);

    setState(() {
      _todayAttendance = today;
      _history = history;
      _isCheckedIn = today != null && today.checkOutTime == null;
      _isLoading = false;
    });
  }

  Future<void> _checkIn() async {
    final l10n = AppLocalizations.of(context);
    final result = await _attendanceRepository.checkIn(widget.user.id!);
    if (result > 0) {
      await _loadAttendance();
      _showMessage(l10n.checkInSuccess, true);
    } else if (result == -2) {
      _showMessage(l10n.alreadyCheckedIn, false);
    } else {
      _showMessage(l10n.checkIn, false);
    }
  }

  Future<void> _checkOut() async {
    final l10n = AppLocalizations.of(context);
    if (_todayAttendance == null) {
      _showMessage(l10n.checkInFirst, false);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.checkOut),
        content: Text(l10n.checkOut),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF44336)),
            child: Text(l10n.checkOut),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _attendanceRepository.checkOut(_todayAttendance!.id!);
      if (result > 0) {
        await _loadAttendance();
        _showMessage(l10n.checkOutSuccess, true);
      } else {
        _showMessage(l10n.checkOut, false);
      }
    }
  }

  void _showMessage(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.attendance)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isCheckedIn
                      ? [const Color(0xFF4CAF50), const Color(0xFF388E3C)]
                      : [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.7)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(_isCheckedIn ? Icons.login : Icons.logout, color: Colors.white, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    _isCheckedIn ? l10n.checkedIn : l10n.notCheckedIn,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateTime.now().toString().substring(0, 10),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                  ),
                  if (_todayAttendance != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.checkInTime}: ${_todayAttendance!.checkInTime.hour}:${_todayAttendance!.checkInTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
                    ),
                  ],
                  if (_todayAttendance?.checkOutTime != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.checkOutTime}: ${_todayAttendance!.checkOutTime!.hour}:${_todayAttendance!.checkOutTime!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isCheckedIn ? _checkOut : _checkIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _isCheckedIn ? const Color(0xFFF44336) : colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _isCheckedIn ? l10n.checkOut : l10n.checkIn,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.attendanceHistory,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            if (_history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(l10n.noAttendanceRecords, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                ),
              )
            else
              ..._history.take(10).map((attendance) => _buildAttendanceCard(context, attendance)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context, AttendanceModel attendance) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.access_time, color: colorScheme.primary),
        ),
        title: Text(attendance.date, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${attendance.checkInTime.hour}:${attendance.checkInTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            if (attendance.checkOutTime != null)
              Text(
                '${attendance.checkOutTime!.hour}:${attendance.checkOutTime!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}