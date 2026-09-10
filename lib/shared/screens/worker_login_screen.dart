import 'package:flutter/material.dart';
import '../../core/auth/auth_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../modules/worker/presentation/screens/worker_dashboard_screen.dart';
import 'change_password_screen.dart';

class WorkerLoginScreen extends StatefulWidget {
  const WorkerLoginScreen({super.key});

  @override
  State<WorkerLoginScreen> createState() => _WorkerLoginScreenState();
}

class _WorkerLoginScreenState extends State<WorkerLoginScreen> {
  final AuthService _authService = AuthService.instance;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (result.success && result.user != null && mounted) {
        if (result.user!.mustChangePassword) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ChangePasswordScreen(user: result.user!),
            ),
          );
        } else if (result.user!.isWorker) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => WorkerDashboardScreen(user: result.user!),
            ),
          );
        } else {
          _showMessage(_tr('هذا الحساب ليس حساب عامل', 'This account is not a worker account'));
        }
      } else {
        _showMessage(result.message ?? _tr('فشل تسجيل الدخول', 'Login failed'));
      }

      setState(() => _isLoading = false);
    }
  }

  String _tr(String ar, String en) {
    return AppLocalizations.of(context).isArabic ? ar : en;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFF44336)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.person, size: 45, color: Color(0xFF2196F3)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.workerLogin,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: l10n.username,
                              labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                              prefixIcon: Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            style: TextStyle(color: colorScheme.onSurface),
                            validator: (v) => v!.isEmpty ? l10n.enterUsername : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                              prefixIcon: Icon(Icons.lock_outline, color: colorScheme.onSurfaceVariant),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            style: TextStyle(color: colorScheme.onSurface),
                            validator: (v) => v!.isEmpty ? l10n.enterPassword : null,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : Text(
                              l10n.login,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.back, style: TextStyle(color: colorScheme.primary)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}