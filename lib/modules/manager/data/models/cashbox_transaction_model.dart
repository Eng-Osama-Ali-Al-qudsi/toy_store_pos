class CashboxTransactionModel {
  final int? id;
  final String uuid;
  final String transactionType; // SALE, EXPENSE, WITHDRAWAL, DEPOSIT, RETURN, ADJUSTMENT
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? reason;
  final String? referenceType;
  final int? referenceId;
  final int? branchId;
  final int createdBy;
  final DateTime? createdAt;
  final String syncStatus;

  CashboxTransactionModel({
    this.id,
    required this.uuid,
    required this.transactionType,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.reason,
    this.referenceType,
    this.referenceId,
    this.branchId,
    required this.createdBy,
    this.createdAt,
    this.syncStatus = 'pending',
  });

  factory CashboxTransactionModel.fromMap(Map<String, dynamic> map) {
    return CashboxTransactionModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      transactionType: map['transaction_type'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      balanceBefore: (map['balance_before'] as num?)?.toDouble() ?? 0,
      balanceAfter: (map['balance_after'] as num?)?.toDouble() ?? 0,
      reason: map['reason'] as String?,
      referenceType: map['reference_type'] as String?,
      referenceId: map['reference_id'] as int?,
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
      'transaction_type': transactionType,
      'amount': amount,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'reason': reason,
      'reference_type': referenceType,
      'reference_id': referenceId,
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
}