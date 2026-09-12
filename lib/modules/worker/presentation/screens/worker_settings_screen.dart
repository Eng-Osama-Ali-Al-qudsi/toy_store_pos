import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/auth/session_manager.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../manager/data/models/user_model.dart';
import '../../../../shared/screens/role_selection_screen.dart';
import '../../../../shared/widgets/confirm_logout_dialog.dart';
import 'worker_change_password_screen.dart';

class WorkerSettingsScreen extends StatelessWidget {
  final UserModel user;

  const WorkerSettingsScreen({super.key, required this.user});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmLogoutDialog(
        onConfirm: () async {
          await SessionManager.instance.clearSession();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                  (route) => false,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
        children: [
          _buildSectionTitle(context, l10n.appearance),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(l10n.lightMode),
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) => themeProvider.setThemeMode(value!),
                  activeColor: colorScheme.primary,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.darkMode),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) => themeProvider.setThemeMode(value!),
                  activeColor: colorScheme.primary,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.systemMode),
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) => themeProvider.setThemeMode(value!),
                  activeColor: colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle(context, l10n.language),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(l10n.arabic),
                  value: 'ar',
                  groupValue: localeProvider.isArabic ? 'ar' : 'en',
                  onChanged: (value) => localeProvider.setArabic(),
                  activeColor: colorScheme.primary,
                ),
                RadioListTile<String>(
                  title: Text(l10n.english),
                  value: 'en',
                  groupValue: localeProvider.isArabic ? 'ar' : 'en',
                  onChanged: (value) => localeProvider.setEnglish(),
                  activeColor: colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle(context, l10n.account),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock, color: Color(0xFF2196F3)),
              title: Text(l10n.changePassword),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => WorkerChangePasswordScreen(user: user)),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFF44336)),
              title: Text(l10n.logout, style: const TextStyle(color: Color(0xFFF44336))),
              trailing: const Icon(Icons.arrow_forward, color: Color(0xFFF44336)),
              onTap: () => _showLogoutDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}