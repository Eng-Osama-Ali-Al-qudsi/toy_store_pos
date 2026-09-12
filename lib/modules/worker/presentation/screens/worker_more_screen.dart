import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../manager/data/models/user_model.dart';
import 'worker_expenses_screen.dart';
import 'worker_sync_screen.dart';
import 'worker_profile_screen.dart';
import 'worker_settings_screen.dart';

class WorkerMoreScreen extends StatelessWidget {
  final UserModel user;

  const WorkerMoreScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.more)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
        children: [
          _buildMenuItem(context, icon: Icons.money_off, color: const Color(0xFFF44336), title: l10n.expenses, screen: WorkerExpensesScreen(user: user)),
          _buildMenuItem(context, icon: Icons.sync, color: const Color(0xFF4CAF50), title: l10n.settings, screen: WorkerSyncScreen(user: user)),
          _buildMenuItem(context, icon: Icons.person, color: const Color(0xFF2196F3), title: l10n.account, screen: WorkerProfileScreen(user: user)),
          _buildMenuItem(context, icon: Icons.settings, color: const Color(0xFF607D8B), title: l10n.settings, screen: WorkerSettingsScreen(user: user)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required Color color,
        required String title,
        required Widget screen,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        trailing: Icon(Icons.arrow_forward, size: 20, color: colorScheme.onSurfaceVariant),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
      ),
    );
  }
}