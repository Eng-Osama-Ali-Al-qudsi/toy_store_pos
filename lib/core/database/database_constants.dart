class DatabaseConstants {
  DatabaseConstants._();

  // أسماء الجداول
  static const String tableUsers = 'users';
  static const String tableUserPermissions = 'user_permissions';
  static const String tableBranches = 'branches';
  static const String tableStoreSettings = 'store_settings';
  static const String tableCurrencies = 'currencies';
  static const String tableTaxConfigs = 'tax_configs';
  static const String tableCategories = 'categories';
  static const String tableSuppliers = 'suppliers';
  static const String tableCustomers = 'customers';
  static const String tableProducts = 'products';
  static const String tableWallets = 'wallets';
  static const String tableSales = 'sales';
  static const String tableSaleItems = 'sale_items';
  static const String tablePayments = 'payments';
  static const String tableReturns = 'returns';
  static const String tableReturnItems = 'return_items';
  static const String tablePurchases = 'purchases';
  static const String tablePurchaseItems = 'purchase_items';
  static const String tableSupplierDebts = 'supplier_debts';
  static const String tableCustomerDebts = 'customer_debts';
  static const String tableCashboxTransactions = 'cashbox_transactions';
  static const String tableExpenses = 'expenses';
  static const String tableWalletTransactions = 'wallet_transactions';
  static const String tableInventoryMovements = 'inventory_movements';
  static const String tableInventoryCounts = 'inventory_counts';
  static const String tableInventoryCountItems = 'inventory_count_items';
  static const String tableInvoiceSequences = 'invoice_sequences';
  static const String tableAttendance = 'attendance';
  static const String tableAuditLogs = 'audit_logs';
  static const String tableNotifications = 'notifications';
  static const String tableSyncQueue = 'sync_queue';

  // ✅ جدول جديد
  static const String tableBusinessDays = 'business_days';
}