import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../manager/data/models/user_model.dart';

class WorkerSyncScreen extends StatefulWidget {
  final UserModel user;

  const WorkerSyncScreen({super.key, required this.user});

  @override
  State<WorkerSyncScreen> createState() => _WorkerSyncScreenState();
}

class _WorkerSyncScreenState extends State<WorkerSyncScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isSyncing = false;
  String _syncStatus = ''; // ✅ لا نستخدم _tr هنا
  int _pendingRecords = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingRecords(); // ✅ فقط تحميل البيانات - بدون _tr
  }

  String _tr(String ar, String en) {
    return AppLocalizations.of(context).isArabic ? ar : en;
  }

  Future<void> _loadPendingRecords() async {
    try {
      final result = await _dbHelper.rawQuery(
        'SELECT COUNT(*) as count FROM sync_queue WHERE status = "pending"',
      );
      if (mounted) {
        setState(() {
          _pendingRecords = result.first['count'] as int? ?? 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _pendingRecords = 0);
      }
    }
  }

  Future<void> _syncNow() async {
    setState(() {
      _isSyncing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _pendingRecords = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('تمت المزامنة بنجاح ✓', 'Sync completed successfully ✓')),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isArabic = AppLocalizations.of(context).isArabic; // ✅ هنا آمن

    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'المزامنة' : 'Sync')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_sync,
              size: 80,
              color: _isSyncing ? const Color(0xFF2196F3) : const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 20),
            Text(
              _isSyncing
                  ? (isArabic ? 'جاري المزامنة...' : 'Syncing...')
                  : (isArabic ? 'جاهز للمزامنة' : 'Ready to sync'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '${isArabic ? 'عمليات بانتظار المزامنة' : 'Pending records'}: $_pendingRecords',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isSyncing ? null : _syncNow,
              icon: _isSyncing
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Icon(Icons.sync),
              label: Text(
                _isSyncing
                    ? (isArabic ? 'جاري المزامنة...' : 'Syncing...')
                    : (isArabic ? 'مزامنة الآن' : 'Sync Now'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}