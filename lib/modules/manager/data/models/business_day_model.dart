class BusinessDayModel {
  final int? id;
  final String uuid;
  final String businessDate; // YYYY-MM-DD
  final double openingCash;
  final double closingCash;
  final double openingWalletsTotal;
  final double closingWalletsTotal;
  final String status; // 'open' | 'closed'
  final DateTime? openedAt;
  final DateTime? closedAt;
  final DateTime? createdAt;
  final String syncStatus;

  BusinessDayModel({
    this.id,
    required this.uuid,
    required this.businessDate,
    this.openingCash = 0,
    this.closingCash = 0,
    this.openingWalletsTotal = 0,
    this.closingWalletsTotal = 0,
    this.status = 'open',
    this.openedAt,
    this.closedAt,
    this.createdAt,
    this.syncStatus = 'pending',
  });

  factory BusinessDayModel.fromMap(Map<String, dynamic> map) {
    return BusinessDayModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      businessDate: map['business_date'] as String? ?? '',
      openingCash: (map['opening_cash'] as num?)?.toDouble() ?? 0,
      closingCash: (map['closing_cash'] as num?)?.toDouble() ?? 0,
      openingWalletsTotal: (map['opening_wallets_total'] as num?)?.toDouble() ?? 0,
      closingWalletsTotal: (map['closing_wallets_total'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? 'open',
      openedAt: map['opened_at'] != null ? DateTime.tryParse(map['opened_at'] as String) : null,
      closedAt: map['closed_at'] != null ? DateTime.tryParse(map['closed_at'] as String) : null,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'business_date': businessDate,
      'opening_cash': openingCash,
      'closing_cash': closingCash,
      'opening_wallets_total': openingWalletsTotal,
      'closing_wallets_total': closingWalletsTotal,
      'status': status,
      'opened_at': openedAt?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  BusinessDayModel copyWith({
    int? id,
    String? uuid,
    String? businessDate,
    double? openingCash,
    double? closingCash,
    double? openingWalletsTotal,
    double? closingWalletsTotal,
    String? status,
    DateTime? openedAt,
    DateTime? closedAt,
    DateTime? createdAt,
    String? syncStatus,
  }) {
    return BusinessDayModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      businessDate: businessDate ?? this.businessDate,
      openingCash: openingCash ?? this.openingCash,
      closingCash: closingCash ?? this.closingCash,
      openingWalletsTotal: openingWalletsTotal ?? this.openingWalletsTotal,
      closingWalletsTotal: closingWalletsTotal ?? this.closingWalletsTotal,
      status: status ?? this.status,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}