import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../manager/data/models/user_model.dart';
import 'worker_pos_screen.dart';
import 'worker_my_sales_screen.dart';
import 'worker_attendance_screen.dart';
import 'worker_more_screen.dart';

class WorkerDashboardScreen extends StatefulWidget {
  final UserModel user;

  const WorkerDashboardScreen({super.key, required this.user});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      WorkerPosScreen(user: widget.user),
      WorkerMySalesScreen(user: widget.user),
      WorkerAttendanceScreen(user: widget.user),
      WorkerMoreScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.point_of_sale_outlined),
            activeIcon: const Icon(Icons.point_of_sale),
            label: l10n.pointOfSale,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long),
            label: l10n.mySales,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.access_time_outlined),
            activeIcon: const Icon(Icons.access_time),
            label: l10n.attendance,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz),
            activeIcon: const Icon(Icons.more),
            label: l10n.more,
          ),
        ],
      ),
    );
  }
}