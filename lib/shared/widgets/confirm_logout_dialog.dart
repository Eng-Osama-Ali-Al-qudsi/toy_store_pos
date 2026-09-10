import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

class ConfirmLogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmLogoutDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.logout, color: Color(0xFFF44336)),
          const SizedBox(width: 8),
          Text(l10n.logout),
        ],
      ),
      content: Text(
        l10n.confirmLogout,
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF44336),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(l10n.logout),
        ),
      ],
    );
  }
}