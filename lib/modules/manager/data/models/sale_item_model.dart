class SaleItemModel {
  final int? id;
  final String uuid;
  final int saleId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double? purchasePriceAtSale;
  final double discount;
  final double taxAmount;
  final double totalPrice;
  final double? profitAmount;
  final String syncStatus;

  SaleItemModel({
    this.id,
    required this.uuid,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.purchasePriceAtSale,
    this.discount = 0,
    this.taxAmount = 0,
    required this.totalPrice,
    this.profitAmount,
    this.syncStatus = 'pending',
  });

  factory SaleItemModel.fromMap(Map<String, dynamic> map) {
    return SaleItemModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      saleId: map['sale_id'] as int? ?? 0,
      productId: map['product_id'] as int? ?? 0,
      quantity: map['quantity'] as int? ?? 0,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0,
      purchasePriceAtSale: (map['purchase_price_at_sale'] as num?)?.toDouble(),
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      taxAmount: (map['tax_amount'] as num?)?.toDouble() ?? 0,
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
      profitAmount: (map['profit_amount'] as num?)?.toDouble(),
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'purchase_price_at_sale': purchasePriceAtSale,
      'discount': discount,
      'tax_amount': taxAmount,
      'total_price': totalPrice,
      'profit_amount': profitAmount,
      'sync_status': syncStatus,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  SaleItemModel copyWith({
    int? id,
    String? uuid,
    int? saleId,
    int? productId,
    int? quantity,
    double? unitPrice,
    double? purchasePriceAtSale,
    double? discount,
    double? taxAmount,
    double? totalPrice,
    double? profitAmount,
    String? syncStatus,
  }) {
    return SaleItemModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      purchasePriceAtSale:
          purchasePriceAtSale ?? this.purchasePriceAtSale,
      discount: discount ?? this.discount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      profitAmount: profitAmount ?? this.profitAmount,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}