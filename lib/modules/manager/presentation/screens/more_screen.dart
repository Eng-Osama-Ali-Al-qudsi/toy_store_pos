import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/models/user_model.dart';
import 'expenses_screen.dart';
import 'cashbox_screen.dart';
import 'wallets_screen.dart';
import 'users_screen.dart';
import 'reports_screen.dart';
import 'attendance_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  final UserModel user;

  const MoreScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.more)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
        children: [
          _buildMenuItem(context, icon: Icons.money_off, color: const Color(0xFFF44336), title: l10n.expenses, screen: ExpensesScreen(user: user)),
          _buildMenuItem(context, icon: Icons.savings, color: const Color(0xFFFF9800), title: l10n.cashbox, screen: CashboxScreen(user: user)),
          _buildMenuItem(context, icon: Icons.wallet, color: const Color(0xFF9C27B0), title: l10n.wallets, screen: WalletsScreen(user: user)),
          _buildMenuItem(context, icon: Icons.people, color: const Color(0xFF009688), title: l10n.users, screen: UsersScreen(user: user)),
          _buildMenuItem(context, icon: Icons.bar_chart, color: const Color(0xFF3F51B5), title: l10n.reports, screen: ReportsScreen(user: user)),
          _buildMenuItem(context, icon: Icons.access_time, color: const Color(0xFF795548), title: l10n.attendance, screen: AttendanceScreen(user: user)),
          _buildMenuItem(context, icon: Icons.settings, color: const Color(0xFF607D8B), title: l10n.settings, screen: SettingsScreen(user: user)),
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