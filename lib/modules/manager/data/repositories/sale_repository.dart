import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';
import '../models/sale_model.dart';
import '../models/sale_item_model.dart';

class SaleRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  SaleRepository(this._dbHelper);

  // توليد رقم فاتورة
  Future<String> generateInvoiceNumber() async {
    final today = DateTime.now();
    final dateStr = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';

    final result = await _dbHelper.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableSales} WHERE invoice_number LIKE ?',
      ['INV-$dateStr-%'],
    );

    final count = result.first['count'] as int? ?? 0;
    return 'INV-$dateStr-${(count + 1).toString().padLeft(4, '0')}';
  }

  // إنشاء بيع مع عناصره (Atomic Transaction)
  Future<int> createSale({
    required SaleModel sale,
    required List<SaleItemModel> saleItems,
  }) async {
    return await _dbHelper.transaction((txn) async {
      final saleWithUuid = sale.copyWith(
        uuid: sale.uuid.isEmpty ? _uuid.v4() : sale.uuid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saleId = await txn.insert(
        DatabaseConstants.tableSales,
        saleWithUuid.toDatabaseMap(),
      );

      // إضافة عناصر البيع
      for (var item in saleItems) {
        final itemWithSaleId = item.copyWith(
          uuid: _uuid.v4(),
          saleId: saleId,
        );
        await txn.insert(
          DatabaseConstants.tableSaleItems,
          itemWithSaleId.toDatabaseMap(),
        );

        // تحديث المخزون
        final products = await txn.query(
          DatabaseConstants.tableProducts,
          where: 'id = ?',
          whereArgs: [item.productId],
        );

        if (products.isNotEmpty) {
          final currentQuantity = products.first['quantity'] as int? ?? 0;
          final newQuantity = currentQuantity - item.quantity;

          await txn.update(
            DatabaseConstants.tableProducts,
            {
              'quantity': newQuantity,
              'updated_at': DateTime.now().toIso8601String(),
              'sync_status': 'updated',
            },
            where: 'id = ?',
            whereArgs: [item.productId],
          );

          // تسجيل حركة مخزون
          await txn.insert(
            DatabaseConstants.tableInventoryMovements,
            {
              'uuid': _uuid.v4(),
              'product_id': item.productId,
              'movement_type': 'SALE',
              'quantity': -item.quantity,
              'quantity_before': currentQuantity,
              'quantity_after': newQuantity,
              'reference_type': 'sale',
              'reference_id': saleId,
              'reason': 'بيع - فاتورة ${sale.invoiceNumber}',
              'created_by': sale.soldBy,
              'created_at': DateTime.now().toIso8601String(),
              'sync_status': 'pending',
            },
          );
        }
      }

      // تسجيل حركة خزنة إذا كان الدفع نقدي
      if (sale.paymentMethod == 'cash' || sale.paymentMethod == 'mixed') {
        final balanceResult = await txn.rawQuery(
          'SELECT COALESCE(SUM(CASE WHEN transaction_type IN ("SALE", "DEPOSIT", "RETURN") THEN amount ELSE -amount END), 0) as balance FROM ${DatabaseConstants.tableCashboxTransactions}',
        );
        final currentBalance = (balanceResult.first['balance'] as num?)?.toDouble() ?? 0;
        final cashAmount = sale.paymentMethod == 'cash' ? sale.totalAmount : sale.totalAmount / 2;

        await txn.insert(
          DatabaseConstants.tableCashboxTransactions,
          {
            'uuid': _uuid.v4(),
            'transaction_type': 'SALE',
            'amount': cashAmount,
            'balance_before': currentBalance,
            'balance_after': currentBalance + cashAmount,
            'reason': 'بيع - فاتورة ${sale.invoiceNumber}',
            'reference_type': 'sale',
            'reference_id': saleId,
            'created_by': sale.soldBy,
            'created_at': DateTime.now().toIso8601String(),
            'sync_status': 'pending',
          },
        );
      }

      return saleId;
    });
  }

  Future<List<Map<String, dynamic>>> getSalesByDate(DateTime date) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return await _dbHelper.query(
      DatabaseConstants.tableSales,
      where: 'sale_date BETWEEN ? AND ? AND status = ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String(), 'completed'],
      orderBy: 'sale_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getSalesByUser(int userId) async {
    return await _dbHelper.query(
      DatabaseConstants.tableSales,
      where: 'sold_by = ? AND status = ?',
      whereArgs: [userId, 'completed'],
      orderBy: 'sale_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllSales() async {
    return await _dbHelper.query(
      DatabaseConstants.tableSales,
      orderBy: 'sale_date DESC',
      limit: 100,
    );
  }

  Future<Map<String, dynamic>?> getSaleById(int id) async {
    final sales = await _dbHelper.query(
      DatabaseConstants.tableSales,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (sales.isNotEmpty) {
      return sales.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getSaleItems(int saleId) async {
    return await _dbHelper.query(
      DatabaseConstants.tableSaleItems,
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );
  }

  Future<double> getTotalSalesByDate(DateTime date) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await _dbHelper.rawQuery(
      'SELECT COALESCE(SUM(total_amount), 0) as total FROM ${DatabaseConstants.tableSales} WHERE sale_date BETWEEN ? AND ? AND status = ?',
      [startDate.toIso8601String(), endDate.toIso8601String(), 'completed'],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getTotalProfitByDate(DateTime date) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await _dbHelper.rawQuery('''
      SELECT COALESCE(SUM(si.profit_amount), 0) as total_profit
      FROM ${DatabaseConstants.tableSaleItems} si
      INNER JOIN ${DatabaseConstants.tableSales} s ON si.sale_id = s.id
      WHERE s.sale_date BETWEEN ? AND ? AND s.status = 'completed'
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return (result.first['total_profit'] as num?)?.toDouble() ?? 0;
  }
}