enum Permission {
  // المنتجات
  viewProducts('view_products', 'عرض المنتجات'),
  createProduct('create_product', 'إضافة منتج'),
  editProduct('edit_product', 'تعديل منتج'),
  deleteProduct('delete_product', 'حذف منتج'),
  viewPurchasePrice('view_purchase_price', 'عرض سعر الشراء'),

  // المخزون
  viewInventory('view_inventory', 'عرض المخزون'),
  manageInventory('manage_inventory', 'إدارة المخزون'),
  addStock('add_stock', 'إضافة كمية'),
  inventoryCount('inventory_count', 'عمل جرد'),

  // المبيعات
  createSale('create_sale', 'إنشاء بيع'),
  viewOwnSales('view_own_sales', 'عرض مبيعاتي'),
  viewAllSales('view_all_sales', 'عرض كل المبيعات'),
  cancelSale('cancel_sale', 'إلغاء بيع'),
  returnSale('return_sale', 'إرجاع بيع'),
  applyDiscount('apply_discount', 'تطبيق خصم'),

  // الفواتير
  viewInvoices('view_invoices', 'عرض الفواتير'),
  printInvoice('print_invoice', 'طباعة فاتورة'),
  shareInvoice('share_invoice', 'مشاركة فاتورة'),

  // المصروفات
  viewExpenses('view_expenses', 'عرض المصروفات'),
  createExpense('create_expense', 'تسجيل مصروف'),
  deleteExpense('delete_expense', 'حذف مصروف'),

  // الخزنة
  viewCashbox('view_cashbox', 'عرض الخزنة'),
  manageCashbox('manage_cashbox', 'إدارة الخزنة'),
  withdrawCash('withdraw_cash', 'سحب نقدي'),
  depositCash('deposit_cash', 'إيداع نقدي'),

  // المحافظ
  viewWallets('view_wallets', 'عرض المحافظ'),
  manageWallets('manage_wallets', 'إدارة المحافظ'),
  viewWalletTransactions('view_wallet_transactions', 'عرض حركات المحافظ'),

  // المشتريات
  viewPurchases('view_purchases', 'عرض المشتريات'),
  createPurchase('create_purchase', 'تسجيل شراء'),
  manageSuppliers('manage_suppliers', 'إدارة الموردين'),

  // العملاء
  viewCustomers('view_customers', 'عرض العملاء'),
  manageCustomers('manage_customers', 'إدارة العملاء'),

  // التقارير
  viewReports('view_reports', 'عرض التقارير'),
  viewFinancialReports('view_financial_reports', 'عرض التقارير المالية'),
  viewProfitReport('view_profit_report', 'عرض تقرير الأرباح'),

  // المستخدمون
  manageUsers('manage_users', 'إدارة المستخدمين'),
  viewUsers('view_users', 'عرض المستخدمين'),
  resetUserPassword('reset_user_password', 'إعادة تعيين كلمة المرور'),

  // الحضور
  checkIn('check_in', 'تسجيل دخول'),
  checkOut('check_out', 'تسجيل خروج'),
  viewAttendance('view_attendance', 'عرض الحضور'),

  // الإعدادات
  manageSettings('manage_settings', 'إدارة الإعدادات'),
  manageStoreSettings('manage_store_settings', 'إدارة إعدادات المتجر'),
  manageSync('manage_sync', 'إدارة المزامنة'),
  manageBackup('manage_backup', 'إدارة النسخ الاحتياطي'),

  // النظام
  viewAuditLogs('view_audit_logs', 'عرض سجل العمليات'),
  manageSystem('manage_system', 'إدارة النظام');

  final String value;
  final String label;

  const Permission(this.value, this.label);

  static Permission? fromString(String? value) {
    if (value == null) return null;
    for (var permission in Permission.values) {
      if (permission.value == value) return permission;
    }
    return null;
  }
}

class DefaultPermissions {
  // صلاحيات المدير (كل الصلاحيات)
  static final Set<Permission> managerPermissions = Permission.values.toSet();

  // صلاحيات العامل الافتراضية
  static final Set<Permission> workerPermissions = {
    Permission.viewProducts,
    Permission.createSale,
    Permission.viewOwnSales,
    Permission.viewInvoices,
    Permission.printInvoice,
    Permission.shareInvoice,
    Permission.checkIn,
    Permission.checkOut,
    Permission.viewAttendance,
  };
}