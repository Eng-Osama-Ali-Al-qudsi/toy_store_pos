class WalletModel {
  final int? id;
  final String uuid;
  final String name;
  final String? walletNumber;
  final String? ownerName;
  final double initialBalance;
  final double currentBalance;
  final bool isActive;
  final String? notes;
  final int? branchId;
  final int createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String syncStatus;

  WalletModel({
    this.id,
    required this.uuid,
    required this.name,
    this.walletNumber,
    this.ownerName,
    this.initialBalance = 0,
    this.currentBalance = 0,
    this.isActive = true,
    this.notes,
    this.branchId,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'pending',
  });

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      walletNumber: map['wallet_number'] as String?,
      ownerName: map['owner_name'] as String?,
      initialBalance: (map['initial_balance'] as num?)?.toDouble() ?? 0,
      currentBalance: (map['current_balance'] as num?)?.toDouble() ?? 0,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      notes: map['notes'] as String?,
      branchId: map['branch_id'] as int?,
      createdBy: map['created_by'] as int? ?? 0,
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
      'wallet_number': walletNumber,
      'owner_name': ownerName,
      'initial_balance': initialBalance,
      'current_balance': currentBalance,
      'is_active': isActive ? 1 : 0,
      'notes': notes,
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

  WalletModel copyWith({
    int? id,
    String? uuid,
    String? name,
    String? walletNumber,
    String? ownerName,
    double? initialBalance,
    double? currentBalance,
    bool? isActive,
    String? notes,
    int? branchId,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return WalletModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      walletNumber: walletNumber ?? this.walletNumber,
      ownerName: ownerName ?? this.ownerName,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      branchId: branchId ?? this.branchId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}