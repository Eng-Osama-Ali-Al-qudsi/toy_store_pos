import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  WalletRepository(this._dbHelper);

  Future<List<WalletModel>> getAllWallets() async {
    final wallets = await _dbHelper.query(
      DatabaseConstants.tableWallets,
      orderBy: 'name ASC',
    );
    return wallets.map((wallet) => WalletModel.fromMap(wallet)).toList();
  }

  Future<List<WalletModel>> getActiveWallets() async {
    final wallets = await _dbHelper.query(
      DatabaseConstants.tableWallets,
      where: 'is_active = 1',
      orderBy: 'name ASC',
    );
    return wallets.map((wallet) => WalletModel.fromMap(wallet)).toList();
  }

  Future<WalletModel?> getWalletById(int id) async {
    final wallets = await _dbHelper.query(
      DatabaseConstants.tableWallets,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (wallets.isNotEmpty) {
      return WalletModel.fromMap(wallets.first);
    }
    return null;
  }

  Future<int> addWallet(WalletModel wallet) async {
    final walletWithUuid = wallet.copyWith(
      uuid: wallet.uuid.isEmpty ? _uuid.v4() : wallet.uuid,
      currentBalance: wallet.initialBalance,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return await _dbHelper.insert(
      DatabaseConstants.tableWallets,
      walletWithUuid.toDatabaseMap(),
    );
  }

  Future<int> updateWallet(WalletModel wallet) async {
    final updatedWallet = wallet.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: 'updated',
    );
    return await _dbHelper.update(
      DatabaseConstants.tableWallets,
      updatedWallet.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  Future<int> deactivateWallet(int id) async {
    return await _dbHelper.update(
      DatabaseConstants.tableWallets,
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
        'sync_status': 'updated',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> activateWallet(int id) async {
    return await _dbHelper.update(
      DatabaseConstants.tableWallets,
      {
        'is_active': 1,
        'updated_at': DateTime.now().toIso8601String(),
        'sync_status': 'updated',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✅ إيداع في المحفظة
  Future<int> depositToWallet({
    required int walletId,
    required double amount,
    required String reason,
    required int createdBy,
    String? referenceType,
    int? referenceId,
  }) async {
    return await _dbHelper.transaction((txn) async {
      final walletResult = await txn.query(
        DatabaseConstants.tableWallets,
        where: 'id = ?',
        whereArgs: [walletId],
      );

      if (walletResult.isEmpty) return -1;

      final currentBalance = (walletResult.first['current_balance'] as num?)?.toDouble() ?? 0;
      final newBalance = currentBalance + amount;

      await txn.update(
        DatabaseConstants.tableWallets,
        {
          'current_balance': newBalance,
          'updated_at': DateTime.now().toIso8601String(),
          'sync_status': 'updated',
        },
        where: 'id = ?',
        whereArgs: [walletId],
      );

      await txn.insert(
        DatabaseConstants.tableWalletTransactions,
        {
          'uuid': _uuid.v4(),
          'wallet_id': walletId,
          'transaction_type': 'credit',
          'amount': amount,
          'balance_before': currentBalance,
          'balance_after': newBalance,
          'reference_type': referenceType,
          'reference_id': referenceId,
          'description': reason,
          'created_by': createdBy,
          'created_at': DateTime.now().toIso8601String(),
          'sync_status': 'pending',
        },
      );

      return 1;
    });
  }

  // ✅ سحب من المحفظة
  Future<int> withdrawFromWallet({
    required int walletId,
    required double amount,
    required String reason,
    required int createdBy,
    String? referenceType,
    int? referenceId,
  }) async {
    return await _dbHelper.transaction((txn) async {
      final walletResult = await txn.query(
        DatabaseConstants.tableWallets,
        where: 'id = ?',
        whereArgs: [walletId],
      );

      if (walletResult.isEmpty) return -1;

      final currentBalance = (walletResult.first['current_balance'] as num?)?.toDouble() ?? 0;

      // ✅ منع السحب أكثر من الرصيد
      if (amount > currentBalance) return -2;

      final newBalance = currentBalance - amount;

      await txn.update(
        DatabaseConstants.tableWallets,
        {
          'current_balance': newBalance,
          'updated_at': DateTime.now().toIso8601String(),
          'sync_status': 'updated',
        },
        where: 'id = ?',
        whereArgs: [walletId],
      );

      await txn.insert(
        DatabaseConstants.tableWalletTransactions,
        {
          'uuid': _uuid.v4(),
          'wallet_id': walletId,
          'transaction_type': 'debit',
          'amount': amount,
          'balance_before': currentBalance,
          'balance_after': newBalance,
          'reference_type': referenceType,
          'reference_id': referenceId,
          'description': reason,
          'created_by': createdBy,
          'created_at': DateTime.now().toIso8601String(),
          'sync_status': 'pending',
        },
      );

      return 1;
    });
  }

  // ✅ سجل العمليات الكامل للمحفظة
  Future<List<Map<String, dynamic>>> getWalletTransactions(int walletId) async {
    return await _dbHelper.query(
      DatabaseConstants.tableWalletTransactions,
      where: 'wallet_id = ?',
      whereArgs: [walletId],
      orderBy: 'created_at DESC',
    );
  }

  // ✅ إحصائيات المحفظة
  Future<Map<String, dynamic>> getWalletStats(int walletId) async {
    final totalCredits = await _dbHelper.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM ${DatabaseConstants.tableWalletTransactions} WHERE wallet_id = ? AND transaction_type = "credit"',
      [walletId],
    );
    final totalDebits = await _dbHelper.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM ${DatabaseConstants.tableWalletTransactions} WHERE wallet_id = ? AND transaction_type = "debit"',
      [walletId],
    );
    final totalTransactions = await _dbHelper.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableWalletTransactions} WHERE wallet_id = ?',
      [walletId],
    );

    return {
      'total_credits': (totalCredits.first['total'] as num?)?.toDouble() ?? 0,
      'total_debits': (totalDebits.first['total'] as num?)?.toDouble() ?? 0,
      'total_transactions': totalTransactions.first['count'] as int? ?? 0,
    };
  }
}