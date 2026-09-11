class ProductModel {
  final int? id;
  final String uuid;
  final String name;
  final String? sku;
  final String? barcode;
  final String? imageUrl;
  final int? categoryId;
  final int? supplierId;
  final String? description;
  final double purchasePrice;
  final double salePrice;
  final int quantity;
  final int minQuantityAlert;
  final bool isActive;
  final int? branchId;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String syncStatus;

  ProductModel({
    this.id,
    required this.uuid,
    required this.name,
    this.sku,
    this.barcode,
    this.imageUrl,
    this.categoryId,
    this.supplierId,
    this.description,
    this.purchasePrice = 0,
    this.salePrice = 0,
    this.quantity = 0,
    this.minQuantityAlert = 5,
    this.isActive = true,
    this.branchId,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'pending',
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      sku: map['sku'] as String?,
      barcode: map['barcode'] as String?,
      imageUrl: map['image_url'] as String?,
      categoryId: map['category_id'] as int?,
      supplierId: map['supplier_id'] as int?,
      description: map['description'] as String?,
      purchasePrice: (map['purchase_price'] as num?)?.toDouble() ?? 0,
      salePrice: (map['sale_price'] as num?)?.toDouble() ?? 0,
      quantity: map['quantity'] as int? ?? 0,
      minQuantityAlert: map['min_quantity_alert'] as int? ?? 5,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      branchId: map['branch_id'] as int?,
      createdBy: map['created_by'] as int?,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'] as String) : null,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'image_url': imageUrl,
      'category_id': categoryId,
      'supplier_id': supplierId,
      'description': description,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'quantity': quantity,
      'min_quantity_alert': minQuantityAlert,
      'is_active': isActive ? 1 : 0,
      'branch_id': branchId,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  bool get isLowStock => quantity <= minQuantityAlert;
  bool get isOutOfStock => quantity <= 0;

  double get profit => salePrice - purchasePrice;
  double get profitPercentage => purchasePrice > 0 ? (profit / purchasePrice) * 100 : 0;

  ProductModel copyWith({
    int? id,
    String? uuid,
    String? name,
    String? sku,
    String? barcode,
    String? imageUrl,
    int? categoryId,
    int? supplierId,
    String? description,
    double? purchasePrice,
    double? salePrice,
    int? quantity,
    int? minQuantityAlert,
    bool? isActive,
    int? branchId,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return ProductModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      supplierId: supplierId ?? this.supplierId,
      description: description ?? this.description,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      quantity: quantity ?? this.quantity,
      minQuantityAlert: minQuantityAlert ?? this.minQuantityAlert,
      isActive: isActive ?? this.isActive,
      branchId: branchId ?? this.branchId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}