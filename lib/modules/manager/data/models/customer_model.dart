class CustomerModel {
  final int? id;
  final String uuid;
  final String fullName;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final double totalPurchases;
  final double totalDebt;
  final bool isActive;
  final int? branchId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String syncStatus;

  CustomerModel({
    this.id,
    required this.uuid,
    required this.fullName,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.totalPurchases = 0,
    this.totalDebt = 0,
    this.isActive = true,
    this.branchId,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'pending',
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      totalPurchases: (map['total_purchases'] as num?)?.toDouble() ?? 0,
      totalDebt: (map['total_debt'] as num?)?.toDouble() ?? 0,
      isActive: (map['is_active'] as int? ?? 1) == 1,
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
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
      'total_purchases': totalPurchases,
      'total_debt': totalDebt,
      'is_active': isActive ? 1 : 0,
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

  CustomerModel copyWith({
    int? id,
    String? uuid,
    String? fullName,
    String? phone,
    String? email,
    String? address,
    String? notes,
    double? totalPurchases,
    double? totalDebt,
    bool? isActive,
    int? branchId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalDebt: totalDebt ?? this.totalDebt,
      isActive: isActive ?? this.isActive,
      branchId: branchId ?? this.branchId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}