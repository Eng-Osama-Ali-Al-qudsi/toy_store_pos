import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../manager/data/models/user_model.dart';

class WorkerProfileScreen extends StatelessWidget {
  final UserModel user;

  const WorkerProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.account)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                    child: Icon(Icons.person, size: 50, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.worker,
                    style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
                  _buildInfoRow(context, Icons.person_outline, l10n.username, user.username),
                  _buildInfoRow(context, Icons.phone, l10n.phone, user.phone ?? l10n.notSet),
                  _buildInfoRow(
                    context,
                    Icons.check_circle,
                    l10n.status,
                    user.isActive ? l10n.active : l10n.inactive,
                    valueColor: user.isActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context,
      IconData icon,
      String label,
      String value, {
        Color? valueColor,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(color: valueColor ?? colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}