class AppConstants {
  AppConstants._();

  // معلومات التطبيق
  static const String appName = 'نظام إدارة محل ألعاب الأطفال';
  static const String appVersion = '1.0.0';
  static const String appCode = 'toy_store_pos';

  // إعدادات قاعدة البيانات
  static const String dbName = 'toy_store.db';
  static const int dbVersion = 1;

  // إعدادات الجلسة
  static const String sessionKey = 'session_token';
  static const String userKey = 'current_user';
  static const String roleKey = 'current_role';

  // إعدادات الفاتورة
  static const String invoicePrefix = 'INV';
  static const int invoicePadding = 4;

  // إعدادات المزامنة
  static const int syncIntervalSeconds = 60;
  static const int maxSyncRetries = 3;

  // إعدادات التنبيه
  static const int defaultMinQuantityAlert = 5;
  static const int lowStockNotificationThreshold = 5;

  // أنواع الدفع
  static const String paymentCash = 'cash';
  static const String paymentWallet = 'wallet';
  static const String paymentMixed = 'mixed';

  // أنواع الحركات
  static const String transactionDeposit = 'deposit';
  static const String transactionWithdrawal = 'withdrawal';

  // حالات المزامنة
  static const String syncPending = 'pending';
  static const String syncSynced = 'synced';
  static const String syncFailed = 'failed';

  // حالات البيع
  static const String saleCompleted = 'completed';
  static const String saleCancelled = 'cancelled';
  static const String saleReturned = 'returned';

  // أنواع حركات المخزون
  static const String movementSale = 'SALE';
  static const String movementPurchase = 'PURCHASE';
  static const String movementAdjustment = 'ADJUSTMENT';
  static const String movementReturn = 'RETURN';
  static const String movementDamage = 'DAMAGE';
  static const String movementManualAdd = 'MANUAL_ADD';
  static const String movementManualRemove = 'MANUAL_REMOVE';
}