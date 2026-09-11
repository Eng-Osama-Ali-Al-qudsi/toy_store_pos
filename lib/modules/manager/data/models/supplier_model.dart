class SupplierModel {
  final int? id;
  final String uuid;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? companyName;
  final double totalPurchases;
  final double totalDebt;
  final bool isActive;
  final int? branchId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String syncStatus;

  SupplierModel({
    this.id,
    required this.uuid,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.companyName,
    this.totalPurchases = 0,
    this.totalDebt = 0,
    this.isActive = true,
    this.branchId,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'pending',
  });

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      companyName: map['company_name'] as String?,
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
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'company_name': companyName,
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

  SupplierModel copyWith({
    int? id,
    String? uuid,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? companyName,
    double? totalPurchases,
    double? totalDebt,
    bool? isActive,
    int? branchId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      companyName: companyName ?? this.companyName,
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