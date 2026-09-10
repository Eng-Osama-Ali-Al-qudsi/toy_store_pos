import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../database/database_constants.dart';
import '../../modules/manager/data/models/business_day_model.dart';
import '../../modules/manager/data/repositories/cashbox_repository.dart';
import '../../modules/manager/data/repositories/wallet_repository.dart';

class BusinessDayService {
  BusinessDayService._();
  static final BusinessDayService instance = BusinessDayService._();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final CashboxRepository _cashboxRepository = CashboxRepository(DatabaseHelper.instance);
  final WalletRepository _walletRepository = WalletRepository(DatabaseHelper.instance);
  final _uuid = const Uuid();

  // ✅ الحصول على تاريخ اليوم بصيغة YYYY-MM-DD
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ✅ الحصول على اليوم المحاسبي الحالي
  Future<BusinessDayModel?> getCurrentBusinessDay() async {
    final today = _getTodayDateString();
    final result = await _dbHelper.query(
      DatabaseConstants.tableBusinessDays,
      where: 'business_date = ?',
      whereArgs: [today],
    );

    if (result.isNotEmpty) {
      return BusinessDayModel.fromMap(result.first);
    }
    return null;
  }

  // ✅ الحصول على آخر يوم محاسبي
  Future<BusinessDayModel?> getLastBusinessDay() async {
    final result = await _dbHelper.query(
      DatabaseConstants.tableBusinessDays,
      orderBy: 'business_date DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return BusinessDayModel.fromMap(result.first);
    }
    return null;
  }

  // ✅ فحص وإنشاء اليوم المحاسبي عند فتح التطبيق
  Future<BusinessDayModel> ensureBusinessDay() async {
    final today = _getTodayDateString();
    final current = await getCurrentBusinessDay();

    if (current != null) {
      return current;
    }

    // لا يوجد يوم اليوم → إنشاء يوم جديد
    final lastDay = await getLastBusinessDay();
    final currentCashBalance = await _cashboxRepository.getCurrentBalance();
    final wallets = await _walletRepository.getAllWallets();
    final totalWalletsBalance = wallets.fold(0.0, (sum, wallet) => sum + wallet.currentBalance);

    // إذا كان آخر يوم مفتوحاً → إغلاقه
    if (lastDay != null && lastDay.status == 'open') {
      await _closeBusinessDay(lastDay);
    }

    final newDay = BusinessDayModel(
      uuid: _uuid.v4(),
      businessDate: today,
      openingCash: lastDay != null ? lastDay.closingCash : currentCashBalance,
      openingWalletsTotal: lastDay != null ? lastDay.closingWalletsTotal : totalWalletsBalance,
      status: 'open',
      openedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _dbHelper.insert(
      DatabaseConstants.tableBusinessDays,
      newDay.toDatabaseMap(),
    );

    return newDay;
  }

  // ✅ إغلاق اليوم المحاسبي
  Future<void> _closeBusinessDay(BusinessDayModel day) async {
    final currentCash = await _cashboxRepository.getCurrentBalance();
    final wallets = await _walletRepository.getAllWallets();
    final totalWallets = wallets.fold(0.0, (sum, wallet) => sum + wallet.currentBalance);

    await _dbHelper.update(
      DatabaseConstants.tableBusinessDays,
      {
        'closing_cash': currentCash,
        'closing_wallets_total': totalWallets,
        'status': 'closed',
        'closed_at': DateTime.now().toIso8601String(),
        'sync_status': 'updated',
      },
      where: 'id = ?',
      whereArgs: [day.id],
    );
  }

  // ✅ إغلاق اليوم الحالي يدوياً (يمكن استدعاؤه من الإعدادات)
  Future<bool> closeCurrentDay() async {
    final current = await getCurrentBusinessDay();
    if (current == null || current.status == 'closed') return false;

    await _closeBusinessDay(current);
    return true;
  }

  // ✅ الحصول على ملخص اليوم الحالي
  Future<Map<String, dynamic>> getTodaySummary() async {
    final day = await getCurrentBusinessDay();
    final currentCash = await _cashboxRepository.getCurrentBalance();
    final wallets = await _walletRepository.getAllWallets();
    final totalWallets = wallets.fold(0.0, (sum, wallet) => sum + wallet.currentBalance);

    return {
      'business_date': day?.businessDate ?? _getTodayDateString(),
      'opening_cash': day?.openingCash ?? 0,
      'current_cash': currentCash,
      'opening_wallets_total': day?.openingWalletsTotal ?? 0,
      'current_wallets_total': totalWallets,
      'net_cash_movement': currentCash - (day?.openingCash ?? 0),
      'net_wallets_movement': totalWallets - (day?.openingWalletsTotal ?? 0),
      'status': day?.status ?? 'open',
    };
  }

  // ✅ الحصول على جميع الأيام المحاسبية (للتقارير)
  Future<List<BusinessDayModel>> getAllBusinessDays() async {
    final result = await _dbHelper.query(
      DatabaseConstants.tableBusinessDays,
      orderBy: 'business_date DESC',
    );
    return result.map((day) => BusinessDayModel.fromMap(day)).toList();
  }

  // ✅ الحصول على يوم محاسبي محدد
  Future<BusinessDayModel?> getBusinessDayByDate(String date) async {
    final result = await _dbHelper.query(
      DatabaseConstants.tableBusinessDays,
      where: 'business_date = ?',
      whereArgs: [date],
    );
    if (result.isNotEmpty) {
      return BusinessDayModel.fromMap(result.first);
    }
    return null;
  }
}