class SaleModel {
  final int? id;
  final String uuid;
  final String invoiceNumber;
  final DateTime saleDate;
  final double subtotal;
  final double discount;
  final double taxAmount;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final int soldBy;
  final int? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final String status;
  final int? branchId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String syncStatus;

  SaleModel({
    this.id,
    required this.uuid,
    required this.invoiceNumber,
    required this.saleDate,
    this.subtotal = 0,
    this.discount = 0,
    this.taxAmount = 0,
    required this.totalAmount,
    this.paymentMethod = 'cash',
    this.paymentStatus = 'paid',
    required this.soldBy,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.status = 'completed',
    this.branchId,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'pending',
  });

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      invoiceNumber: map['invoice_number'] as String? ?? '',
      saleDate: DateTime.tryParse(map['sale_date'] as String? ?? '') ?? DateTime.now(),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      taxAmount: (map['tax_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: map['payment_method'] as String? ?? 'cash',
      paymentStatus: map['payment_status'] as String? ?? 'paid',
      soldBy: map['sold_by'] as int? ?? 0,
      customerId: map['customer_id'] as int?,
      customerName: map['customer_name'] as String?,
      customerPhone: map['customer_phone'] as String?,
      notes: map['notes'] as String?,
      status: map['status'] as String? ?? 'completed',
      branchId: map['branch_id'] as int?,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'] as String) : null,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'invoice_number': invoiceNumber,
      'sale_date': saleDate.toIso8601String(),
      'subtotal': subtotal,
      'discount': discount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'sold_by': soldBy,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'notes': notes,
      'status': status,
      'branch_id': branchId,
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

  SaleModel copyWith({
    int? id,
    String? uuid,
    String? invoiceNumber,
    DateTime? saleDate,
    double? subtotal,
    double? discount,
    double? taxAmount,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    int? soldBy,
    int? customerId,
    String? customerName,
    String? customerPhone,
    String? notes,
    String? status,
    int? branchId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return SaleModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      saleDate: saleDate ?? this.saleDate,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      soldBy: soldBy ?? this.soldBy,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      branchId: branchId ?? this.branchId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}