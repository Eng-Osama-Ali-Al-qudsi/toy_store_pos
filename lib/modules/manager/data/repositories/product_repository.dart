import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';
import '../models/product_model.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  ProductRepository(this._dbHelper);

  Future<List<ProductModel>> getAllProducts() async {
    final products = await _dbHelper.query(
      DatabaseConstants.tableProducts,
      where: 'is_active = 1',
      orderBy: 'name ASC',
    );
    return products.map((product) => ProductModel.fromMap(product)).toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final products = await _dbHelper.query(
      DatabaseConstants.tableProducts,
      where: '(name LIKE ? OR sku LIKE ? OR barcode LIKE ?) AND is_active = 1',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return products.map((product) => ProductModel.fromMap(product)).toList();
  }

  Future<ProductModel?> getProductById(int id) async {
    final products = await _dbHelper.query(
      DatabaseConstants.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (products.isNotEmpty) {
      return ProductModel.fromMap(products.first);
    }
    return null;
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    final products = await _dbHelper.query(
      DatabaseConstants.tableProducts,
      where: 'barcode = ? AND is_active = 1',
      whereArgs: [barcode],
    );
    if (products.isNotEmpty) {
      return ProductModel.fromMap(products.first);
    }
    return null;
  }

  Future<List<ProductModel>> getLowStockProducts() async {
    final products = await _dbHelper.query(
      DatabaseConstants.tableProducts,
      where: 'quantity <= min_quantity_alert AND is_active = 1',
      orderBy: 'quantity ASC',
    );
    return products.map((product) => ProductModel.fromMap(product)).toList();
  }

  Future<List<ProductModel>> getOutOfStockProducts() async {
    final products = await _dbHelper.query(
      DatabaseConstants.tableProducts,
      where: 'quantity <= 0 AND is_active = 1',
      orderBy: 'name ASC',
    );
    return products.map((product) => ProductModel.fromMap(product)).toList();
  }

  Future<int> addProduct(ProductModel product) async {
    final productWithUuid = product.copyWith(
      uuid: product.uuid.isEmpty ? _uuid.v4() : product.uuid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return await _dbHelper.insert(
      DatabaseConstants.tableProducts,
      productWithUuid.toDatabaseMap(),
    );
  }

  Future<int> updateProduct(ProductModel product) async {
    final updatedProduct = product.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: 'updated',
    );
    return await _dbHelper.update(
      DatabaseConstants.tableProducts,
      updatedProduct.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    return await _dbHelper.update(
      DatabaseConstants.tableProducts,
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
        'sync_status': 'updated',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateProductQuantity(int productId, int newQuantity) async {
    return await _dbHelper.update(
      DatabaseConstants.tableProducts,
      {
        'quantity': newQuantity,
        'updated_at': DateTime.now().toIso8601String(),
        'sync_status': 'updated',
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    return await _dbHelper.query(
      DatabaseConstants.tableCategories,
      where: 'is_active = 1',
      orderBy: 'name ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllSuppliers() async {
    return await _dbHelper.query(
      DatabaseConstants.tableSuppliers,
      where: 'is_active = 1',
      orderBy: 'name ASC',
    );
  }
}