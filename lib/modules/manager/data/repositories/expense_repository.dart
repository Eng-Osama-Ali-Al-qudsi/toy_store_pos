import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  ExpenseRepository(this._dbHelper);

  Future<int> addExpense(ExpenseModel expense) async {
    return await _dbHelper.transaction((txn) async {
      final expenseWithUuid = expense.copyWith(
        uuid: expense.uuid.isEmpty ? _uuid.v4() : expense.uuid,
        createdAt: DateTime.now(),
      );

      final expenseId = await txn.insert(
        DatabaseConstants.tableExpenses,
        expenseWithUuid.toDatabaseMap(),
      );

      // ✅ خصم من الصندوق إذا كان الدفع نقدي
      if (expense.paymentMethod == 'cash') {
        final balanceResult = await txn.rawQuery(
          'SELECT COALESCE(SUM(CASE WHEN transaction_type IN ("SALE", "DEPOSIT", "RETURN") THEN amount ELSE -amount END), 0) as balance FROM ${DatabaseConstants.tableCashboxTransactions}',
        );
        final currentBalance = (balanceResult.first['balance'] as num?)?.toDouble() ?? 0;

        await txn.insert(
          DatabaseConstants.tableCashboxTransactions,
          {
            'uuid': _uuid.v4(),
            'transaction_type': 'EXPENSE',
            'amount': expense.amount,
            'balance_before': currentBalance,
            'balance_after': currentBalance - expense.amount,
            'reason': expense.description ?? 'مصروف',
            'reference_type': 'expense',
            'reference_id': expenseId,
            'created_by': expense.createdBy,
            'created_at': DateTime.now().toIso8601String(),
            'sync_status': 'pending',
          },
        );
      }

      // ✅ خصم من المحفظة إذا كان الدفع بمحفظة
      if (expense.paymentMethod == 'wallet' && expense.walletId != null) {
        final walletResult = await txn.query(
          DatabaseConstants.tableWallets,
          where: 'id = ?',
          whereArgs: [expense.walletId],
        );

        if (walletResult.isNotEmpty) {
          final currentWalletBalance = (walletResult.first['current_balance'] as num?)?.toDouble() ?? 0;
          final newWalletBalance = currentWalletBalance - expense.amount;

          await txn.update(
            DatabaseConstants.tableWallets,
            {
              'current_balance': newWalletBalance,
              'updated_at': DateTime.now().toIso8601String(),
              'sync_status': 'updated',
            },
            where: 'id = ?',
            whereArgs: [expense.walletId],
          );

          await txn.insert(
            DatabaseConstants.tableWalletTransactions,
            {
              'uuid': _uuid.v4(),
              'wallet_id': expense.walletId,
              'transaction_type': 'debit',
              'amount': expense.amount,
              'balance_before': currentWalletBalance,
              'balance_after': newWalletBalance,
              'reference_type': 'expense',
              'reference_id': expenseId,
              'description': expense.description ?? 'مصروف',
              'created_by': expense.createdBy,
              'created_at': DateTime.now().toIso8601String(),
              'sync_status': 'pending',
            },
          );
        }
      }

      return expenseId;
    });
  }

  Future<List<ExpenseModel>> getExpensesByDate(DateTime date) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final expenses = await _dbHelper.query(
      DatabaseConstants.tableExpenses,
      where: 'expense_date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'expense_date DESC',
    );

    return expenses.map((expense) => ExpenseModel.fromMap(expense)).toList();
  }

  Future<List<ExpenseModel>> getExpensesByUser(int userId) async {
    final expenses = await _dbHelper.query(
      DatabaseConstants.tableExpenses,
      where: 'created_by = ?',
      whereArgs: [userId],
      orderBy: 'expense_date DESC',
    );

    return expenses.map((expense) => ExpenseModel.fromMap(expense)).toList();
  }

  Future<List<ExpenseModel>> getAllExpenses() async {
    final expenses = await _dbHelper.query(
      DatabaseConstants.tableExpenses,
      orderBy: 'expense_date DESC',
    );

    return expenses.map((expense) => ExpenseModel.fromMap(expense)).toList();
  }

  Future<double> getTotalExpensesByDate(DateTime date) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await _dbHelper.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM ${DatabaseConstants.tableExpenses} WHERE expense_date BETWEEN ? AND ?',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }
}