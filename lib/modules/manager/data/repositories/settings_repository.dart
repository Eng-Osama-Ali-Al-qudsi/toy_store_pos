import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';

class SettingsRepository {
  final DatabaseHelper _dbHelper;

  SettingsRepository(this._dbHelper);

  Future<String?> getSetting(String key) async {
    final result = await _dbHelper.query(
      DatabaseConstants.tableStoreSettings,
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  Future<Map<String, String>> getAllSettings() async {
    final result = await _dbHelper.query(DatabaseConstants.tableStoreSettings);
    final settings = <String, String>{};
    for (var row in result) {
      settings[row['key'] as String] = row['value'] as String? ?? '';
    }
    return settings;
  }

  Future<int> setSetting(String key, String value) async {
    final existing = await _dbHelper.query(
      DatabaseConstants.tableStoreSettings,
      where: 'key = ?',
      whereArgs: [key],
    );

    if (existing.isNotEmpty) {
      return await _dbHelper.update(
        DatabaseConstants.tableStoreSettings,
        {
          'value': value,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'key = ?',
        whereArgs: [key],
      );
    } else {
      return await _dbHelper.insert(
        DatabaseConstants.tableStoreSettings,
        {
          'key': key,
          'value': value,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  Future<int> deleteSetting(String key) async {
    return await _dbHelper.delete(
      DatabaseConstants.tableStoreSettings,
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  // الحصول على اسم المتجر
  Future<String> getStoreName() async {
    return await getSetting('store_name') ?? 'محل بيت الطفل للألعاب';
  }

  // الحصول على العملة الافتراضية
  Future<String> getDefaultCurrency() async {
    return await getSetting('default_currency') ?? 'YER';
  }

  // الحصول على إعدادات الضريبة
  Future<bool> isTaxEnabled() async {
    final value = await getSetting('tax_enabled');
    return value == 'true';
  }

  Future<double> getTaxRate() async {
    final value = await getSetting('tax_rate');
    return double.tryParse(value ?? '0') ?? 0;
  }

  // الحصول على بادئة الفاتورة
  Future<String> getInvoicePrefix() async {
    return await getSetting('invoice_prefix') ?? 'INV';
  }
}