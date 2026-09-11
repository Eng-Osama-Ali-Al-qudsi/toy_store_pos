import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';

class ReportRepository {
  final DatabaseHelper _dbHelper;

  ReportRepository(this._dbHelper);

  // تقرير المبيعات
  Future<Map<String, dynamic>> getSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final salesResult = await _dbHelper.rawQuery('''
      SELECT 
        COALESCE(SUM(total_amount), 0) as total_sales,
        COUNT(*) as invoice_count,
        COALESCE(SUM(discount), 0) as total_discount
      FROM ${DatabaseConstants.tableSales}
      WHERE sale_date BETWEEN ? AND ? AND status = 'completed'
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    final cashSales = await _dbHelper.rawQuery('''
      SELECT COALESCE(SUM(total_amount), 0) as cash_total
      FROM ${DatabaseConstants.tableSales}
      WHERE sale_date BETWEEN ? AND ? AND payment_method = 'cash' AND status = 'completed'
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    final walletSales = await _dbHelper.rawQuery('''
      SELECT COALESCE(SUM(total_amount), 0) as wallet_total
      FROM ${DatabaseConstants.tableSales}
      WHERE sale_date BETWEEN ? AND ? AND payment_method = 'wallet' AND status = 'completed'
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return {
      'total_sales': (salesResult.first['total_sales'] as num?)?.toDouble() ?? 0,
      'invoice_count': salesResult.first['invoice_count'] as int? ?? 0,
      'total_discount': (salesResult.first['total_discount'] as num?)?.toDouble() ?? 0,
      'cash_total': (cashSales.first['cash_total'] as num?)?.toDouble() ?? 0,
      'wallet_total': (walletSales.first['wallet_total'] as num?)?.toDouble() ?? 0,
    };
  }

  // تقرير الأرباح
  Future<Map<String, dynamic>> getProfitReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final profitResult = await _dbHelper.rawQuery('''
      SELECT COALESCE(SUM(si.profit_amount), 0) as total_profit
      FROM ${DatabaseConstants.tableSaleItems} si
      INNER JOIN ${DatabaseConstants.tableSales} s ON si.sale_id = s.id
      WHERE s.sale_date BETWEEN ? AND ? AND s.status = 'completed'
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    final expensesResult = await _dbHelper.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total_expenses
      FROM ${DatabaseConstants.tableExpenses}
      WHERE expense_date BETWEEN ? AND ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    final totalProfit = (profitResult.first['total_profit'] as num?)?.toDouble() ?? 0;
    final totalExpenses = (expensesResult.first['total_expenses'] as num?)?.toDouble() ?? 0;

    return {
      'total_profit': totalProfit,
      'total_expenses': totalExpenses,
      'net_profit': totalProfit - totalExpenses,
    };
  }

  // تقرير المصروفات
  Future<Map<String, dynamic>> getExpensesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await _dbHelper.rawQuery('''
      SELECT 
        COALESCE(SUM(amount), 0) as total_expenses,
        COUNT(*) as expense_count
      FROM ${DatabaseConstants.tableExpenses}
      WHERE expense_date BETWEEN ? AND ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return {
      'total_expenses': (result.first['total_expenses'] as num?)?.toDouble() ?? 0,
      'expense_count': result.first['expense_count'] as int? ?? 0,
    };
  }

  // تقرير الخزنة
  Future<Map<String, dynamic>> getCashboxReport() async {
    final result = await _dbHelper.rawQuery('''
      SELECT 
        COALESCE(SUM(CASE WHEN transaction_type IN ('SALE', 'DEPOSIT', 'RETURN') THEN amount ELSE 0 END), 0) as total_deposits,
        COALESCE(SUM(CASE WHEN transaction_type IN ('EXPENSE', 'WITHDRAWAL', 'ADJUSTMENT') THEN amount ELSE 0 END), 0) as total_withdrawals,
        COALESCE(SUM(CASE WHEN transaction_type IN ('SALE', 'DEPOSIT', 'RETURN') THEN amount ELSE -amount END), 0) as current_balance
      FROM ${DatabaseConstants.tableCashboxTransactions}
    ''');

    return {
      'total_deposits': (result.first['total_deposits'] as num?)?.toDouble() ?? 0,
      'total_withdrawals': (result.first['total_withdrawals'] as num?)?.toDouble() ?? 0,
      'current_balance': (result.first['current_balance'] as num?)?.toDouble() ?? 0,
    };
  }

  // تقرير المحافظ
  Future<Map<String, dynamic>> getWalletsReport() async {
    final result = await _dbHelper.rawQuery('''
      SELECT 
        COALESCE(SUM(current_balance), 0) as total_wallet_balance,
        COUNT(*) as wallet_count
      FROM ${DatabaseConstants.tableWallets}
      WHERE is_active = 1
    ''');

    return {
      'total_wallet_balance': (result.first['total_wallet_balance'] as num?)?.toDouble() ?? 0,
      'wallet_count': result.first['wallet_count'] as int? ?? 0,
    };
  }

  // تقرير المخزون
  Future<Map<String, dynamic>> getInventoryReport() async {
    final result = await _dbHelper.rawQuery('''
      SELECT 
        COUNT(*) as product_count,
        COALESCE(SUM(quantity), 0) as total_quantity,
        COALESCE(SUM(quantity * purchase_price), 0) as inventory_value,
        COALESCE(SUM(CASE WHEN quantity <= min_quantity_alert THEN 1 ELSE 0 END), 0) as low_stock_count,
        COALESCE(SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END), 0) as out_of_stock_count
      FROM ${DatabaseConstants.tableProducts}
      WHERE is_active = 1
    ''');

    return {
      'product_count': result.first['product_count'] as int? ?? 0,
      'total_quantity': result.first['total_quantity'] as int? ?? 0,
      'inventory_value': (result.first['inventory_value'] as num?)?.toDouble() ?? 0,
      'low_stock_count': result.first['low_stock_count'] as int? ?? 0,
      'out_of_stock_count': result.first['out_of_stock_count'] as int? ?? 0,
    };
  }

  // تقرير أداء العمال
  Future<List<Map<String, dynamic>>> getWorkerPerformanceReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _dbHelper.rawQuery('''
      SELECT 
        u.id,
        u.full_name,
        COUNT(s.id) as sale_count,
        COALESCE(SUM(s.total_amount), 0) as total_sales
      FROM ${DatabaseConstants.tableUsers} u
      LEFT JOIN ${DatabaseConstants.tableSales} s ON u.id = s.sold_by 
        AND s.sale_date BETWEEN ? AND ? AND s.status = 'completed'
      WHERE u.role = 'worker'
      GROUP BY u.id, u.full_name
      ORDER BY total_sales DESC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
  }

  // أفضل المنتجات مبيعاً
  Future<List<Map<String, dynamic>>> getTopProducts({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    return await _dbHelper.rawQuery('''
      SELECT 
        p.id,
        p.name,
        SUM(si.quantity) as total_quantity,
        COALESCE(SUM(si.total_price), 0) as total_sales
      FROM ${DatabaseConstants.tableSaleItems} si
      INNER JOIN ${DatabaseConstants.tableSales} s ON si.sale_id = s.id
      INNER JOIN ${DatabaseConstants.tableProducts} p ON si.product_id = p.id
      WHERE s.sale_date BETWEEN ? AND ? AND s.status = 'completed'
      GROUP BY p.id, p.name
      ORDER BY total_quantity DESC
      LIMIT ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String(), limit]);
  }

  // المبيعات اليومية للرسم البياني
  Future<List<Map<String, dynamic>>> getDailySalesTrend({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _dbHelper.rawQuery('''
      SELECT 
        DATE(sale_date) as date,
        COUNT(*) as invoice_count,
        COALESCE(SUM(total_amount), 0) as total_sales
      FROM ${DatabaseConstants.tableSales}
      WHERE sale_date BETWEEN ? AND ? AND status = 'completed'
      GROUP BY DATE(sale_date)
      ORDER BY date ASC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
  }
}