import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';
import '../models/supplier_model.dart';

class SupplierRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  SupplierRepository(this._dbHelper);

  Future<List<SupplierModel>> getAllSuppliers() async {
    final suppliers = await _dbHelper.query(
      DatabaseConstants.tableSuppliers,
      where: 'is_active = 1',
      orderBy: 'name ASC',
    );
    return suppliers.map((supplier) => SupplierModel.fromMap(supplier)).toList();
  }

  Future<List<SupplierModel>> searchSuppliers(String query) async {
    final suppliers = await _dbHelper.query(
      DatabaseConstants.tableSuppliers,
      where: '(name LIKE ? OR phone LIKE ? OR company_name LIKE ?) AND is_active = 1',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return suppliers.map((supplier) => SupplierModel.fromMap(supplier)).toList();
  }

  Future<SupplierModel?> getSupplierById(int id) async {
    final suppliers = await _dbHelper.query(
      DatabaseConstants.tableSuppliers,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (suppliers.isNotEmpty) {
      return SupplierModel.fromMap(suppliers.first);
    }
    return null;
  }

  Future<int> addSupplier(SupplierModel supplier) async {
    final supplierWithUuid = supplier.copyWith(
      uuid: supplier.uuid.isEmpty ? _uuid.v4() : supplier.uuid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return await _dbHelper.insert(
      DatabaseConstants.tableSuppliers,
      supplierWithUuid.toDatabaseMap(),
    );
  }

  Future<int> updateSupplier(SupplierModel supplier) async {
    final updatedSupplier = supplier.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: 'updated',
    );
    return await _dbHelper.update(
      DatabaseConstants.tableSuppliers,
      updatedSupplier.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<int> deactivateSupplier(int id) async {
    return await _dbHelper.update(
      DatabaseConstants.tableSuppliers,
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
        'sync_status': 'updated',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getSupplierPurchases(int supplierId) async {
    return await _dbHelper.query(
      DatabaseConstants.tablePurchases,
      where: 'supplier_id = ?',
      whereArgs: [supplierId],
      orderBy: 'purchase_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getSupplierDebts(int supplierId) async {
    return await _dbHelper.query(
      DatabaseConstants.tableSupplierDebts,
      where: 'supplier_id = ? AND remaining_amount > 0',
      whereArgs: [supplierId],
      orderBy: 'created_at DESC',
    );
  }
}