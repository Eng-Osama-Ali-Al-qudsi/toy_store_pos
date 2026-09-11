import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';

class CashboxRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  CashboxRepository(this._dbHelper);

  Future<double> getCurrentBalance() async {
    final result = await _dbHelper.rawQuery('''
      SELECT COALESCE(SUM(CASE 
        WHEN transaction_type IN ('SALE', 'DEPOSIT', 'RETURN') THEN amount 
        ELSE -amount 
      END), 0) as balance 
      FROM ${DatabaseConstants.tableCashboxTransactions}
    ''');
    return (result.first['balance'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getTotalDeposits() async {
    final result = await _dbHelper.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM ${DatabaseConstants.tableCashboxTransactions} WHERE transaction_type IN ("SALE", "DEPOSIT", "RETURN")',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getTotalWithdrawals() async {
    final result = await _dbHelper.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM ${DatabaseConstants.tableCashboxTransactions} WHERE transaction_type IN ("EXPENSE", "WITHDRAWAL", "ADJUSTMENT")',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<List<Map<String, dynamic>>> getTransactions({int limit = 100}) async {
    return await _dbHelper.query(
      DatabaseConstants.tableCashboxTransactions,
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionsByDate(DateTime date) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return await _dbHelper.query(
      DatabaseConstants.tableCashboxTransactions,
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> withdrawCash({
    required double amount,
    required String reason,
    required int createdBy,
  }) async {
    return await _dbHelper.transaction((txn) async {
      final balanceResult = await txn.rawQuery(
        'SELECT COALESCE(SUM(CASE WHEN transaction_type IN ("SALE", "DEPOSIT", "RETURN") THEN amount ELSE -amount END), 0) as balance FROM ${DatabaseConstants.tableCashboxTransactions}',
      );
      final currentBalance = (balanceResult.first['balance'] as num?)?.toDouble() ?? 0;

      return await txn.insert(
        DatabaseConstants.tableCashboxTransactions,
        {
          'uuid': _uuid.v4(),
          'transaction_type': 'WITHDRAWAL',
          'amount': amount,
          'balance_before': currentBalance,
          'balance_after': currentBalance - amount,
          'reason': reason,
          'reference_type': 'manual',
          'created_by': createdBy,
          'created_at': DateTime.now().toIso8601String(),
          'sync_status': 'pending',
        },
      );
    });
  }

  Future<int> depositCash({
    required double amount,
    required String reason,
    required int createdBy,
  }) async {
    return await _dbHelper.transaction((txn) async {
      final balanceResult = await txn.rawQuery(
        'SELECT COALESCE(SUM(CASE WHEN transaction_type IN ("SALE", "DEPOSIT", "RETURN") THEN amount ELSE -amount END), 0) as balance FROM ${DatabaseConstants.tableCashboxTransactions}',
      );
      final currentBalance = (balanceResult.first['balance'] as num?)?.toDouble() ?? 0;

      return await txn.insert(
        DatabaseConstants.tableCashboxTransactions,
        {
          'uuid': _uuid.v4(),
          'transaction_type': 'DEPOSIT',
          'amount': amount,
          'balance_before': currentBalance,
          'balance_after': currentBalance + amount,
          'reason': reason,
          'reference_type': 'manual',
          'created_by': createdBy,
          'created_at': DateTime.now().toIso8601String(),
          'sync_status': 'pending',
        },
      );
    });
  }
}