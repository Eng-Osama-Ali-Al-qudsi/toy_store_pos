import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';
import 'database_constants.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static const int _dbVersion = 2; // ✅ تحديث الإصدار

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, AppConstants.dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ✅ دالة الترقية
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // إضافة business_date للجداول المالية
      await db.execute('ALTER TABLE cashbox_transactions ADD COLUMN business_date TEXT');
      await db.execute('ALTER TABLE expenses ADD COLUMN business_date TEXT');
      await db.execute('ALTER TABLE sales ADD COLUMN business_date TEXT');
      await db.execute('ALTER TABLE wallet_transactions ADD COLUMN business_date TEXT');

      // إنشاء جدول business_days
      await db.execute('''
        CREATE TABLE ${DatabaseConstants.tableBusinessDays} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT UNIQUE NOT NULL,
          business_date TEXT NOT NULL UNIQUE,
          opening_cash REAL DEFAULT 0,
          closing_cash REAL DEFAULT 0,
          opening_wallets_total REAL DEFAULT 0,
          closing_wallets_total REAL DEFAULT 0,
          status TEXT DEFAULT 'open' CHECK (status IN ('open', 'closed')),
          opened_at DATETIME,
          closed_at DATETIME,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          sync_status TEXT DEFAULT 'pending'
        )
      ''');

      // تعبئة business_date للبيانات القديمة
      await db.rawUpdate('UPDATE cashbox_transactions SET business_date = substr(created_at, 1, 10) WHERE business_date IS NULL');
      await db.rawUpdate('UPDATE expenses SET business_date = substr(expense_date, 1, 10) WHERE business_date IS NULL');
      await db.rawUpdate('UPDATE sales SET business_date = substr(sale_date, 1, 10) WHERE business_date IS NULL');
      await db.rawUpdate('UPDATE wallet_transactions SET business_date = substr(created_at, 1, 10) WHERE business_date IS NULL');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await _createUsersTable(db);
    await _createUserPermissionsTable(db);
    await _createBranchesTable(db);
    await _createStoreSettingsTable(db);
    await _createCurrenciesTable(db);
    await _createTaxConfigsTable(db);
    await _createCategoriesTable(db);
    await _createSuppliersTable(db);
    await _createCustomersTable(db);
    await _createProductsTable(db);
    await _createWalletsTable(db);
    await _createSalesTable(db);
    await _createSaleItemsTable(db);
    await _createPaymentsTable(db);
    await _createReturnsTable(db);
    await _createReturnItemsTable(db);
    await _createPurchasesTable(db);
    await _createPurchaseItemsTable(db);
    await _createSupplierDebtsTable(db);
    await _createCustomerDebtsTable(db);
    await _createCashboxTransactionsTable(db);
    await _createExpensesTable(db);
    await _createWalletTransactionsTable(db);
    await _createInventoryMovementsTable(db);
    await _createInventoryCountsTable(db);
    await _createInventoryCountItemsTable(db);
    await _createInvoiceSequencesTable(db);
    await _createAttendanceTable(db);
    await _createAuditLogsTable(db);
    await _createNotificationsTable(db);
    await _createSyncQueueTable(db);
    await _createBusinessDaysTable(db);

    await _insertDefaultData(db);
  }

  // ===== الجداول =====

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableUsers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        avatar TEXT,
        role TEXT NOT NULL CHECK (role IN ('manager', 'worker')),
        is_active INTEGER DEFAULT 1,
        must_change_password INTEGER DEFAULT 0,
        last_login_at DATETIME,
        device_info TEXT,
        branch_id INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');
  }

  Future<void> _createUserPermissionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableUserPermissions} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        permission TEXT NOT NULL,
        granted INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE CASCADE,
        UNIQUE(user_id, permission)
      )
    ''');
  }

  Future<void> _createBranchesTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableBranches} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        code TEXT UNIQUE,
        address TEXT,
        phone TEXT,
        is_main INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');
  }

  Future<void> _createStoreSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableStoreSettings} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> _createCurrenciesTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCurrencies} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        code TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        symbol TEXT NOT NULL,
        exchange_rate REAL DEFAULT 1.0,
        is_default INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');
  }

  Future<void> _createTaxConfigsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableTaxConfigs} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        rate REAL DEFAULT 0,
        is_active INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');
  }

  Future<void> _createCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCategories} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        is_active INTEGER DEFAULT 1,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');
  }

  Future<void> _createSuppliersTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableSuppliers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        company_name TEXT,
        total_purchases REAL DEFAULT 0,
        total_debt REAL DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        branch_id INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');
  }

  Future<void> _createCustomersTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCustomers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        full_name TEXT NOT NULL,
        phone TEXT UNIQUE,
        email TEXT,
        address TEXT,
        notes TEXT,
        total_purchases REAL DEFAULT 0,
        total_debt REAL DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        branch_id INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');
  }

  Future<void> _createProductsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableProducts} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        sku TEXT UNIQUE,
        barcode TEXT,
        image_url TEXT,
        category_id INTEGER,
        supplier_id INTEGER,
        description TEXT,
        purchase_price REAL NOT NULL DEFAULT 0,
        sale_price REAL NOT NULL DEFAULT 0,
        quantity INTEGER NOT NULL DEFAULT 0,
        min_quantity_alert INTEGER DEFAULT 5,
        is_active INTEGER DEFAULT 1,
        branch_id INTEGER,
        created_by INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (category_id) REFERENCES ${DatabaseConstants.tableCategories}(id),
        FOREIGN KEY (supplier_id) REFERENCES ${DatabaseConstants.tableSuppliers}(id),
        FOREIGN KEY (created_by) REFERENCES ${DatabaseConstants.tableUsers}(id)
      )
    ''');
  }

  Future<void> _createWalletsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableWallets} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        wallet_number TEXT,
        owner_name TEXT,
        initial_balance REAL DEFAULT 0,
        current_balance REAL DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        notes TEXT,
        branch_id INTEGER,
        created_by INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (created_by) REFERENCES ${DatabaseConstants.tableUsers}(id)
      )
    ''');
  }

  Future<void> _createSalesTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableSales} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        invoice_number TEXT UNIQUE NOT NULL,
        sale_date DATETIME NOT NULL,
        business_date TEXT,
        subtotal REAL NOT NULL DEFAULT 0,
        discount REAL DEFAULT 0,
        tax_amount REAL DEFAULT 0,
        total_amount REAL NOT NULL DEFAULT 0,
        payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'wallet', 'mixed')),
        payment_status TEXT DEFAULT 'paid',
        sold_by INTEGER NOT NULL,
        customer_id INTEGER,
        customer_name TEXT,
        customer_phone TEXT,
        notes TEXT,
        status TEXT DEFAULT 'completed' CHECK (status IN ('completed', 'cancelled', 'returned')),
        branch_id INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (sold_by) REFERENCES ${DatabaseConstants.tableUsers}(id),
        FOREIGN KEY (customer_id) REFERENCES ${DatabaseConstants.tableCustomers}(id)
      )
    ''');
  }

  Future<void> _createSaleItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableSaleItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        purchase_price_at_sale REAL,
        discount REAL DEFAULT 0,
        tax_amount REAL DEFAULT 0,
        total_price REAL NOT NULL,
        profit_amount REAL,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (sale_id) REFERENCES ${DatabaseConstants.tableSales}(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id)
      )
    ''');
  }

  Future<void> _createPaymentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tablePayments} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        sale_id INTEGER NOT NULL,
        payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'wallet')),
        wallet_id INTEGER,
        amount REAL NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (sale_id) REFERENCES ${DatabaseConstants.tableSales}(id) ON DELETE CASCADE,
        FOREIGN KEY (wallet_id) REFERENCES ${DatabaseConstants.tableWallets}(id)
      )
    ''');
  }

  Future<void> _createReturnsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableReturns} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        sale_id INTEGER NOT NULL,
        return_date DATETIME NOT NULL,
        reason TEXT,
        total_refund REAL DEFAULT 0,
        status TEXT DEFAULT 'completed',
        branch_id INTEGER,
        created_by INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (sale_id) REFERENCES ${DatabaseConstants.tableSales}(id),
        FOREIGN KEY (created_by) REFERENCES ${DatabaseConstants.tableUsers}(id)
      )
    ''');
  }

  Future<void> _createReturnItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableReturnItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        return_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (return_id) REFERENCES ${DatabaseConstants.tableReturns}(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id)
      )
    ''');
  }

  Future<void> _createPurchasesTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tablePurchases} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        purchase_number TEXT UNIQUE NOT NULL,
        purchase_date DATETIME NOT NULL,
        supplier_id INTEGER,
        total_amount REAL NOT NULL DEFAULT 0,
        paid_amount REAL DEFAULT 0,
        remaining_amount REAL DEFAULT 0,
        payment_method TEXT DEFAULT 'cash',
        payment_status TEXT DEFAULT 'paid',
        wallet_id INTEGER,
        notes TEXT,
        branch_id INTEGER,
        created_by INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (supplier_id) REFERENCES ${DatabaseConstants.tableSuppliers}(id),
        FOREIGN KEY (wallet_id) REFERENCES ${DatabaseConstants.tableWallets}(id),
        FOREIGN KEY (created_by) REFERENCES ${DatabaseConstants.tableUsers}(id)
      )
    ''');
  }

  Future<void> _createPurchaseItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tablePurchaseItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        purchase_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_cost REAL NOT NULL,
        total_cost REAL NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (purchase_id) REFERENCES ${DatabaseConstants.tablePurchases}(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id)
      )
    ''');
  }

  Future<void> _createSupplierDebtsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableSupplierDebts} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        supplier_id INTEGER NOT NULL,
        purchase_id INTEGER,
        amount REAL NOT NULL,
        paid_amount REAL DEFAULT 0,
        remaining_amount REAL DEFAULT 0,
        due_date DATETIME,
        status TEXT DEFAULT 'pending',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (supplier_id) REFERENCES ${DatabaseConstants.tableSuppliers}(id),
        FOREIGN KEY (purchase_id) REFERENCES ${DatabaseConstants.tablePurchases}(id)
      )
    ''');
  }

  Future<void> _createCustomerDebtsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCustomerDebts} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        customer_id INTEGER NOT NULL,
        sale_id INTEGER,
        amount REAL NOT NULL,
        paid_amount REAL DEFAULT 0,
        remaining_amount REAL DEFAULT 0,
        due_date DATETIME,
        status TEXT DEFAULT 'pending',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (customer_id) REFERENCES ${DatabaseConstants.tableCustomers}(id),
        FOREIGN KEY (sale_id) REFERENCES ${DatabaseConstants.tableSales}(id)
      )
    ''');
  }

  Future<void> _createCashboxTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCashboxTransactions} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        transaction_type TEXT NOT NULL CHECK (transaction_type IN ('SALE', 'EXPENSE', 'WITHDRAWAL', 'DEPOSIT', 'RETURN', 'ADJUSTMENT')),
        amount REAL NOT NULL,
        balance_before REAL NOT NULL,
        balance_after REAL NOT NULL,
        reason TEXT,
        reference_type TEXT,
        reference_id INTEGER,
        business_date TEXT,
        branch_id INTEGER,
        created_by INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (created_by) REFERENCES ${DatabaseConstants.tableUsers}(id)
      )
    ''');
  }

  Future<void> _createExpensesTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableExpenses} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        amount REAL NOT NULL,
        category TEXT,
        description TEXT,
        payment_method TEXT DEFAULT 'cash',
        wallet_id INTEGER,
        expense_date DATETIME NOT NULL,
        business_date TEXT,
        branch_id INTEGER,
        created_by INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (wallet_id) REFERENCES ${DatabaseConstants.tableWallets}(id),
        FOREIGN KEY (created_by) REFERENCES ${DatabaseConstants.tableUsers}(id)
      )
    ''');
  }

  Future<void> _createWalletTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableWalletTransactions} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        wallet_id INTEGER NOT NULL,
        transaction_type TEXT NOT NULL CHECK (transaction_type IN ('credit', 'debit')),
        amount REAL NOT NULL,
        balance_before REAL NOT NULL,
        balance_after REAL NOT NULL,
        reference_type TEXT,
        reference_id INTEGER,
        sale_id INTEGER,
        description TEXT,
        business_date TEXT,
        created_by INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (wallet_id) REFERENCES ${DatabaseConstants.tableWallets}(id),
        FOREIGN KEY (sale_id) REFERENCES ${DatabaseConstants.tableSales}(id),
        FOREIGN KEY (created_by) REFERENCES ${DatabaseConstants.tableUsers}(id)
      )
    ''');
  }

  Future<void> _createInventoryMovementsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableInventoryMovements} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        product_id INTEGER NOT NULL,
        movement_type TEXT NOT NULL CHECK (movement_type IN ('SALE', 'PURCHASE', 'ADJUSTMENT', 'RETURN', 'DAMAGE', 'MANUAL_ADD', 'MANUAL_REMOVE')),
        quantity INTEGER NOT NULL,
        quantity_before INTEGER NOT NULL,
        quantity_after INTEGER NOT NULL,
        reference_type TEXT,
        reference_id INTEGER,
        reason TEXT,
        created_by INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id),
        FOREIGN KEY (created_by) REFERENCES ${DatabaseConstants.tableUsers}(id)
      )
    ''');
  }

  Future<void> _createInventoryCountsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableInventoryCounts} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        count_date DATETIME NOT NULL,
        status TEXT DEFAULT 'in_progress',
        notes TEXT,
        branch_id INTEGER,
        created_by INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (created_by) REFERENCES ${DatabaseConstants.tableUsers}(id)
      )
    ''');
  }

  Future<void> _createInventoryCountItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableInventoryCountItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        inventory_count_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        system_quantity INTEGER NOT NULL,
        counted_quantity INTEGER NOT NULL,
        difference INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (inventory_count_id) REFERENCES ${DatabaseConstants.tableInventoryCounts}(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id)
      )
    ''');
  }

  Future<void> _createInvoiceSequencesTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableInvoiceSequences} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        branch_id INTEGER,
        date TEXT NOT NULL,
        last_number INTEGER DEFAULT 0,
        prefix TEXT DEFAULT 'INV',
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> _createAttendanceTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableAttendance} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        check_in_time DATETIME NOT NULL,
        check_out_time DATETIME,
        work_hours REAL,
        notes TEXT,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createAuditLogsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableAuditLogs} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        user_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id INTEGER,
        old_value TEXT,
        new_value TEXT,
        description TEXT,
        device_info TEXT,
        ip_address TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES ${DatabaseConstants.tableUsers}(id)
      )
    ''');
  }

  Future<void> _createNotificationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableNotifications} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        user_id INTEGER,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT,
        is_read INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES ${DatabaseConstants.tableUsers}(id)
      )
    ''');
  }

  Future<void> _createSyncQueueTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableSyncQueue} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        table_name TEXT NOT NULL,
        record_uuid TEXT NOT NULL,
        operation TEXT NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
        status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'synced', 'failed')),
        attempts INTEGER DEFAULT 0,
        error_message TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        attempted_at DATETIME,
        synced_at DATETIME
      )
    ''');
  }

  // ✅ جدول الأيام المحاسبية
  Future<void> _createBusinessDaysTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableBusinessDays} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        business_date TEXT NOT NULL UNIQUE,
        opening_cash REAL DEFAULT 0,
        closing_cash REAL DEFAULT 0,
        opening_wallets_total REAL DEFAULT 0,
        closing_wallets_total REAL DEFAULT 0,
        status TEXT DEFAULT 'open' CHECK (status IN ('open', 'closed')),
        opened_at DATETIME,
        closed_at DATETIME,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');
  }

  Future<void> _insertDefaultData(Database db) async {
    await db.insert(DatabaseConstants.tableCurrencies, {
      'uuid': 'currency-yer',
      'code': 'YER',
      'name': 'ريال يمني',
      'symbol': 'ر.ي',
      'exchange_rate': 1.0,
      'is_default': 1,
      'is_active': 1,
      'sync_status': 'pending',
    });

    await db.insert(DatabaseConstants.tableBranches, {
      'uuid': 'branch-main',
      'name': 'الفرع الرئيسي',
      'code': 'MAIN',
      'is_main': 1,
      'is_active': 1,
      'sync_status': 'pending',
    });

    final categories = [
      {'uuid': 'cat-001', 'name': 'ألعاب أطفال', 'description': 'ألعاب متنوعة للأطفال'},
      {'uuid': 'cat-002', 'name': 'دمى', 'description': 'دمى وعرائس'},
      {'uuid': 'cat-003', 'name': 'سيارات', 'description': 'سيارات ومركبات'},
      {'uuid': 'cat-004', 'name': 'ألعاب تعليمية', 'description': 'ألعاب تعليمية وتنموية'},
      {'uuid': 'cat-005', 'name': 'دراجات', 'description': 'دراجات وسكوتر'},
    ];

    for (var category in categories) {
      await db.insert(DatabaseConstants.tableCategories, category);
    }

    final settings = [
      {'key': 'store_name', 'value': 'محل بيت الطفل للألعاب'},
      {'key': 'store_address', 'value': 'صنعاء، اليمن'},
      {'key': 'store_phone', 'value': ''},
      {'key': 'default_currency', 'value': 'YER'},
      {'key': 'tax_enabled', 'value': 'false'},
      {'key': 'tax_rate', 'value': '0'},
      {'key': 'invoice_prefix', 'value': 'INV'},
      {'key': 'dark_mode', 'value': 'false'},
    ];

    for (var setting in settings) {
      await db.insert(DatabaseConstants.tableStoreSettings, setting);
    }
  }

  // دوال مساعدة
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<int> update(String table, Map<String, dynamic> data, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs, String? orderBy, int? limit}) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<void> execute(String sql) async {
    final db = await database;
    await db.execute(sql);
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction<T>(action);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}