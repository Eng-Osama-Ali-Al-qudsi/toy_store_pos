import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  CustomerRepository(this._dbHelper);

  Future<List<CustomerModel>> getAllCustomers() async {
    final customers = await _dbHelper.query(
      DatabaseConstants.tableCustomers,
      where: 'is_active = 1',
      orderBy: 'full_name ASC',
    );
    return customers.map((customer) => CustomerModel.fromMap(customer)).toList();
  }

  Future<List<CustomerModel>> searchCustomers(String query) async {
    final customers = await _dbHelper.query(
      DatabaseConstants.tableCustomers,
      where: '(full_name LIKE ? OR phone LIKE ?) AND is_active = 1',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'full_name ASC',
    );
    return customers.map((customer) => CustomerModel.fromMap(customer)).toList();
  }

  Future<CustomerModel?> getCustomerById(int id) async {
    final customers = await _dbHelper.query(
      DatabaseConstants.tableCustomers,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (customers.isNotEmpty) {
      return CustomerModel.fromMap(customers.first);
    }
    return null;
  }

  Future<CustomerModel?> getCustomerByPhone(String phone) async {
    final customers = await _dbHelper.query(
      DatabaseConstants.tableCustomers,
      where: 'phone = ? AND is_active = 1',
      whereArgs: [phone],
    );
    if (customers.isNotEmpty) {
      return CustomerModel.fromMap(customers.first);
    }
    return null;
  }

  Future<int> addCustomer(CustomerModel customer) async {
    final customerWithUuid = customer.copyWith(
      uuid: customer.uuid.isEmpty ? _uuid.v4() : customer.uuid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return await _dbHelper.insert(
      DatabaseConstants.tableCustomers,
      customerWithUuid.toDatabaseMap(),
    );
  }

  Future<int> updateCustomer(CustomerModel customer) async {
    final updatedCustomer = customer.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: 'updated',
    );
    return await _dbHelper.update(
      DatabaseConstants.tableCustomers,
      updatedCustomer.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deactivateCustomer(int id) async {
    return await _dbHelper.update(
      DatabaseConstants.tableCustomers,
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
        'sync_status': 'updated',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getCustomerSales(int customerId) async {
    return await _dbHelper.query(
      DatabaseConstants.tableSales,
      where: 'customer_id = ? AND status = ?',
      whereArgs: [customerId, 'completed'],
      orderBy: 'sale_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getCustomerDebts(int customerId) async {
    return await _dbHelper.query(
      DatabaseConstants.tableCustomerDebts,
      where: 'customer_id = ? AND remaining_amount > 0',
      whereArgs: [customerId],
      orderBy: 'created_at DESC',
    );
  }
}