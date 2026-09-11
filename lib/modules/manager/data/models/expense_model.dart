class ExpenseModel {
  final int? id;
  final String uuid;
  final double amount;
  final String? category;
  final String? description;
  final String paymentMethod;
  final int? walletId;
  final DateTime expenseDate;
  final int? branchId;
  final int createdBy;
  final DateTime? createdAt;
  final String syncStatus;

  ExpenseModel({
    this.id,
    required this.uuid,
    required this.amount,
    this.category,
    this.description,
    this.paymentMethod = 'cash',
    this.walletId,
    required this.expenseDate,
    this.branchId,
    required this.createdBy,
    this.createdAt,
    this.syncStatus = 'pending',
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      category: map['category'] as String?,
      description: map['description'] as String?,
      paymentMethod: map['payment_method'] as String? ?? 'cash',
      walletId: map['wallet_id'] as int?,
      expenseDate: DateTime.tryParse(map['expense_date'] as String? ?? '') ?? DateTime.now(),
      branchId: map['branch_id'] as int?,
      createdBy: map['created_by'] as int? ?? 0,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'amount': amount,
      'category': category,
      'description': description,
      'payment_method': paymentMethod,
      'wallet_id': walletId,
      'expense_date': expenseDate.toIso8601String(),
      'branch_id': branchId,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  ExpenseModel copyWith({
    int? id,
    String? uuid,
    double? amount,
    String? category,
    String? description,
    String? paymentMethod,
    int? walletId,
    DateTime? expenseDate,
    int? branchId,
    int? createdBy,
    DateTime? createdAt,
    String? syncStatus,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      walletId: walletId ?? this.walletId,
      expenseDate: expenseDate ?? this.expenseDate,
      branchId: branchId ?? this.branchId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}