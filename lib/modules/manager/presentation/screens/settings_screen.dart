import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/auth/session_manager.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/screens/role_selection_screen.dart';
import '../../../../shared/widgets/confirm_logout_dialog.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsScreen extends StatefulWidget {
  final UserModel user;

  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsRepository _settingsRepository = SettingsRepository(DatabaseHelper.instance);

  final _storeNameController = TextEditingController();
  final _storePhoneController = TextEditingController();
  final _storeAddressController = TextEditingController();

  bool _allowPriceOverride = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsRepository.getAllSettings();
    _storeNameController.text = settings['store_name'] ?? '';
    _storePhoneController.text = settings['store_phone'] ?? '';
    _storeAddressController.text = settings['store_address'] ?? '';
    _allowPriceOverride = settings['allow_price_override'] == 'true';
    setState(() {});
  }

  Future<void> _saveStoreSettings() async {
    await _settingsRepository.setSetting('store_name', _storeNameController.text);
    await _settingsRepository.setSetting('store_phone', _storePhoneController.text);
    await _settingsRepository.setSetting('store_address', _storeAddressController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الإعدادات'), backgroundColor: Color(0xFF4CAF50)),
      );
    }
  }

  Future<void> _togglePriceOverride(bool value) async {
    await _settingsRepository.setSetting('allow_price_override', value.toString());
    setState(() => _allowPriceOverride = value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ إعداد البيع'), backgroundColor: Color(0xFF4CAF50)),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmLogoutDialog(
        onConfirm: () async {
          await SessionManager.instance.clearSession();
          if (mounted) {
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
  void dispose() {
    _storeNameController.dispose();
    _storePhoneController.dispose();
    _storeAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 120 + MediaQuery.of(context).padding.bottom),
          children: [
            // ===== قسم المظهر =====
            _buildSectionHeader(context, l10n.appearance),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.lightMode),
                    value: ThemeMode.light,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) => themeProvider.setThemeMode(value!),
                    activeColor: colorScheme.primary,
                    dense: true,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.darkMode),
                    value: ThemeMode.dark,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) => themeProvider.setThemeMode(value!),
                    activeColor: colorScheme.primary,
                    dense: true,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.systemMode),
                    value: ThemeMode.system,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) => themeProvider.setThemeMode(value!),
                    activeColor: colorScheme.primary,
                    dense: true,
                  ),
                ],
              ),
            ),

            // ===== قسم اللغة =====
            _buildSectionHeader(context, l10n.language),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(l10n.arabic),
                    value: 'ar',
                    groupValue: localeProvider.isArabic ? 'ar' : 'en',
                    onChanged: (value) => localeProvider.setArabic(),
                    activeColor: colorScheme.primary,
                    dense: true,
                  ),
                  RadioListTile<String>(
                    title: Text(l10n.english),
                    value: 'en',
                    groupValue: localeProvider.isArabic ? 'ar' : 'en',
                    onChanged: (value) => localeProvider.setEnglish(),
                    activeColor: colorScheme.primary,
                    dense: true,
                  ),
                ],
              ),
            ),

            // ===== قسم بيانات المتجر =====
            _buildSectionHeader(context, l10n.storeData),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _storeNameController,
                      decoration: InputDecoration(
                        labelText: l10n.storeName,
                        prefixIcon: Icon(Icons.store, color: colorScheme.primary),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _storePhoneController,
                      decoration: InputDecoration(
                        labelText: l10n.storePhone,
                        prefixIcon: Icon(Icons.phone, color: colorScheme.primary),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _storeAddressController,
                      decoration: InputDecoration(
                        labelText: l10n.storeAddress,
                        prefixIcon: Icon(Icons.location_on, color: colorScheme.primary),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveStoreSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(l10n.saveStoreData),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== قسم إعدادات البيع =====
            _buildSectionHeader(context, l10n.saleSettings),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: SwitchListTile(
                title: Text(l10n.allowPriceOverride),
                subtitle: Text(l10n.allowPriceOverrideSubtitle),
                value: _allowPriceOverride,
                onChanged: _togglePriceOverride,
                activeColor: colorScheme.primary,
              ),
            ),

            // ===== قسم الحساب =====
            _buildSectionHeader(context, l10n.account),
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.logout, color: colorScheme.error),
                title: Text(l10n.logout, style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
                trailing: Icon(Icons.arrow_forward, color: colorScheme.error, size: 20),
                onTap: _showLogoutDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}