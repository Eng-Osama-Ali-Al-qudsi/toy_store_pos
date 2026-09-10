import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('ar', 'YE'),
    Locale('en'),
  ];

  bool get isArabic => locale.languageCode == 'ar';

  String _tr(String ar, String en) => isArabic ? ar : en;

  // ===== عام =====
  String get appName => _tr('بيت الطفل', 'Toy Store');
  String get appTitle => _tr('نظام إدارة محل ألعاب الأطفال', 'Toy Store Management System');
  String get yes => _tr('نعم', 'Yes');
  String get no => _tr('لا', 'No');
  String get save => _tr('حفظ', 'Save');
  String get cancel => _tr('إلغاء', 'Cancel');
  String get edit => _tr('تعديل', 'Edit');
  String get delete => _tr('حذف', 'Delete');
  String get add => _tr('إضافة', 'Add');
  String get search => _tr('بحث', 'Search');
  String get confirm => _tr('تأكيد', 'Confirm');
  String get loading => _tr('جاري التحميل...', 'Loading...');
  String get noData => _tr('لا توجد بيانات', 'No data available');
  String get back => _tr('رجوع', 'Back');
  String get next => _tr('التالي', 'Next');

  // ===== تسجيل الدخول =====
  String get login => _tr('تسجيل الدخول', 'Login');
  String get logout => _tr('تسجيل الخروج', 'Logout');
  String get username => _tr('اسم المستخدم', 'Username');
  String get password => _tr('كلمة المرور', 'Password');
  String get enterUsername => _tr('أدخل اسم المستخدم', 'Enter username');
  String get enterPassword => _tr('أدخل كلمة المرور', 'Enter password');
  String get wrongCredentials => _tr('اسم المستخدم أو كلمة المرور غير صحيحة', 'Invalid username or password');
  String get selectRole => _tr('اختر نوع الدخول', 'Select login type');
  String get manager => _tr('مدير المتجر', 'Manager');
  String get worker => _tr('عامل / موظف', 'Worker');
  String get managerLogin => _tr('دخول المدير', 'Manager Login');
  String get workerLogin => _tr('دخول العامل', 'Worker Login');
  String get confirmLogout => _tr('هل أنت متأكد من رغبتك في تسجيل الخروج؟', 'Are you sure you want to logout?');

  // ===== التنقل =====
  String get home => _tr('الرئيسية', 'Home');
  String get sales => _tr('المبيعات', 'Sales');
  String get products => _tr('المنتجات', 'Products');
  String get inventory => _tr('المخزون', 'Inventory');
  String get expenses => _tr('المصروفات', 'Expenses');
  String get cashbox => _tr('الخزنة', 'Cashbox');
  String get wallets => _tr('المحافظ', 'Wallets');
  String get users => _tr('الموظفون', 'Employees');
  String get reports => _tr('التقارير', 'Reports');
  String get attendance => _tr('الحضور', 'Attendance');
  String get settings => _tr('الإعدادات', 'Settings');
  String get more => _tr('المزيد', 'More');
  String get account => _tr('حسابي', 'My Account');
  String get mySales => _tr('مبيعاتي', 'My Sales');

  // ===== Dashboard =====
  String get welcome => _tr('مرحباً', 'Welcome');
  String get todaySummary => _tr('ملخص اليوم', 'Today Summary');
  String get todaySales => _tr('مبيعات اليوم', 'Today Sales');
  String get profits => _tr('الأرباح', 'Profits');
  String get cashboxBalance => _tr('رصيد الخزنة', 'Cashbox Balance');
  String get invoiceCount => _tr('عدد الفواتير', 'Invoice Count');
  String get walletBalance => _tr('رصيد المحافظ', 'Wallet Balance');
  String get inventoryValue => _tr('قيمة المخزون', 'Inventory Value');
  String get quickActions => _tr('اختصارات سريعة', 'Quick Actions');
  String get alerts => _tr('تنبيهات', 'Alerts');
  String get lowStockAlerts => _tr('منتجات منخفضة المخزون', 'Low stock products');
  String get outOfStockAlerts => _tr('منتجات نفذت من المخزون', 'Out of stock products');
  String get allProductsAvailable => _tr('جميع المنتجات متوفرة', 'All products available');

  // ===== البيع =====
  String get pointOfSale => _tr('نقطة البيع', 'Point of Sale');
  String get cart => _tr('السلة', 'Cart');
  String get emptyCart => _tr('السلة فارغة', 'Cart is empty');
  String get total => _tr('الإجمالي', 'Total');
  String get paymentMethod => _tr('طريقة الدفع', 'Payment Method');
  String get cash => _tr('نقداً', 'Cash');
  String get wallet => _tr('محفظة', 'Wallet');
  String get completeSale => _tr('إتمام البيع', 'Complete Sale');
  String get purchasePrice => _tr('سعر الشراء', 'Purchase Price');
  String get salePrice => _tr('سعر البيع', 'Sale Price');
  String get quantity => _tr('الكمية', 'Quantity');
  String get available => _tr('المتوفر', 'Available');
  String get saleSuccess => _tr('تم البيع بنجاح', 'Sale completed successfully');
  String get searchProduct => _tr('بحث عن منتج...', 'Search product...');
  String get noProducts => _tr('لا توجد منتجات', 'No products available');
  String get selectWallet => _tr('اختر المحفظة', 'Select wallet');
  String get quantityNotAvailable => _tr('الكمية غير متوفرة', 'Quantity not available');
  String get productNotAvailable => _tr('المنتج غير متوفر', 'Product not available');

  // ===== الحضور =====
  String get checkIn => _tr('تسجيل الحضور', 'Check In');
  String get checkOut => _tr('تسجيل الانصراف', 'Check Out');
  String get checkedIn => _tr('مسجل حضور', 'Checked In');
  String get notCheckedIn => _tr('غير مسجل', 'Not Checked In');
  String get checkInTime => _tr('وقت الحضور', 'Check In Time');
  String get checkOutTime => _tr('وقت الانصراف', 'Check Out Time');
  String get checkInSuccess => _tr('تم تسجيل الحضور بنجاح', 'Checked in successfully');
  String get checkOutSuccess => _tr('تم تسجيل الانصراف بنجاح', 'Checked out successfully');
  String get alreadyCheckedIn => _tr('أنت مسجل حضور بالفعل اليوم', 'You are already checked in today');
  String get checkInFirst => _tr('يجب تسجيل الحضور أولاً', 'You must check in first');
  String get attendanceHistory => _tr('سجل الحضور', 'Attendance History');
  String get noAttendanceRecords => _tr('لا توجد سجلات حضور', 'No attendance records');

  // ===== الإعدادات =====
  String get appearance => _tr('المظهر', 'Appearance');
  String get darkMode => _tr('الوضع الداكن', 'Dark Mode');
  String get lightMode => _tr('الوضع الفاتح', 'Light Mode');
  String get systemMode => _tr('حسب إعداد الجهاز', 'System Mode');
  String get language => _tr('اللغة', 'Language');
  String get arabic => _tr('العربية', 'Arabic');
  String get english => _tr('English', 'English');
  String get changePassword => _tr('تغيير كلمة المرور', 'Change Password');
  String get currentPassword => _tr('كلمة المرور الحالية', 'Current Password');
  String get newPassword => _tr('كلمة المرور الجديدة', 'New Password');
  String get confirmPassword => _tr('تأكيد كلمة المرور', 'Confirm Password');
  String get passwordChanged => _tr('تم تغيير كلمة المرور بنجاح', 'Password changed successfully');
  String get passwordMismatch => _tr('كلمتا المرور غير متطابقتين', 'Passwords do not match');
  String get wrongCurrentPassword => _tr('كلمة المرور الحالية غير صحيحة', 'Current password is incorrect');

  // ===== المتجر =====
  String get storeData => _tr('بيانات المتجر', 'Store Data');
  String get storeName => _tr('اسم المحل', 'Store Name');
  String get storePhone => _tr('رقم الهاتف', 'Phone Number');
  String get storeAddress => _tr('العنوان', 'Address');
  String get saveStoreData => _tr('حفظ بيانات المتجر', 'Save Store Data');
  String get saleSettings => _tr('إعدادات البيع', 'Sale Settings');
  String get allowPriceOverride => _tr('السماح للعامل بتعديل سعر البيع', 'Allow worker to override sale price');
  String get allowPriceOverrideSubtitle => _tr('عند التفعيل، يستطيع العامل إدخال سعر بيع مخصص', 'When enabled, worker can enter custom sale price');

  // ===== المستخدم =====
  String get role => _tr('الدور', 'Role');
  String get active => _tr('نشط', 'Active');
  String get inactive => _tr('معطل', 'Inactive');
  String get phone => _tr('رقم الهاتف', 'Phone');
  String get status => _tr('الحالة', 'Status');
  String get notSet => _tr('غير محدد', 'Not set');

  // ===== مفاتيح الفاتورة =====
  String get printInvoice => _tr('طباعة الفاتورة', 'Print Invoice');
  String get sharePdf => _tr('مشاركة PDF', 'Share PDF');
  String get newSale => _tr('عملية جديدة', 'New Sale');
  String get confirmSale => _tr('تأكيد عملية البيع', 'Confirm Sale');

  // ===== المحافظ =====
  String get deactivateWallet => _tr('تعطيل المحفظة', 'Deactivate Wallet');
  String get deactivateWalletConfirm => _tr('هل تريد تعطيل هذه المحفظة؟ لن يتم حذفها أو حذف بياناتها.', 'Do you want to deactivate this wallet? It will not be deleted.');
  String get deactivate => _tr('تعطيل', 'Deactivate');
  String get walletDeactivated => _tr('تم تعطيل المحفظة', 'Wallet deactivated');
  String get activate => _tr('تفعيل', 'Activate');
  String get walletActivated => _tr('تم تفعيل المحفظة', 'Wallet activated');
  String get activeWallet => _tr('نشطة', 'Active');
  String get inactiveWallet => _tr('معطلة', 'Inactive');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'ar' || locale.languageCode == 'en';
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}