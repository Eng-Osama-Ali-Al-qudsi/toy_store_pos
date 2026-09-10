import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/services/business_day_service.dart';
import '../../core/auth/session_manager.dart';
import '../../core/database/database_helper.dart';
import 'first_run_wizard_screen.dart';
import 'role_selection_screen.dart';
import '../../modules/manager/presentation/screens/manager_dashboard_screen.dart';
import '../../modules/worker/presentation/screens/worker_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final BusinessDayService _businessDayService = BusinessDayService.instance;
  final SessionManager _sessionManager = SessionManager.instance;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _businessDayService.ensureBusinessDay();
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final hasManager = await _authHasManager();
    if (!hasManager) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const FirstRunWizardScreen()),
      );
      return;
    }

    final currentUser = await _sessionManager.getCurrentUser();
    if (currentUser != null && currentUser.isActive) {
      if (currentUser.isManager) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ManagerDashboardScreen(user: currentUser)),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => WorkerDashboardScreen(user: currentUser)),
        );
      }
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  Future<bool> _authHasManager() async {
    try {
      final result = await DatabaseHelper.instance.query(
        'users',
        where: "role = 'manager'",
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.toys, size: 50, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 24),
            const Text(
              'بيت الطفل',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'نظام إدارة محل ألعاب الأطفال',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 35,
              height: 35,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}