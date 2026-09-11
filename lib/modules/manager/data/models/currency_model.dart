class CurrencyModel {
  final int? id;
  final String uuid;
  final String code;
  final String name;
  final String symbol;
  final double exchangeRate;
  final bool isDefault;
  final bool isActive;
  final String syncStatus;

  CurrencyModel({
    this.id,
    required this.uuid,
    required this.code,
    required this.name,
    required this.symbol,
    this.exchangeRate = 1.0,
    this.isDefault = false,
    this.isActive = true,
    this.syncStatus = 'pending',
  });

  factory CurrencyModel.fromMap(Map<String, dynamic> map) {
    return CurrencyModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      code: map['code'] as String? ?? '',
      name: map['name'] as String? ?? '',
      symbol: map['symbol'] as String? ?? '',
      exchangeRate: (map['exchange_rate'] as num?)?.toDouble() ?? 1.0,
      isDefault: (map['is_default'] as int? ?? 0) == 1,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'code': code,
      'name': name,
      'symbol': symbol,
      'exchange_rate': exchangeRate,
      'is_default': isDefault ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'sync_status': syncStatus,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  String format(double amount) {
    return '$amount $symbol';
  }

  double convertTo(double amount, CurrencyModel targetCurrency) {
    // تحويل من هذه العملة إلى العملة المستهدفة
    if (code == targetCurrency.code) return amount;
    return amount * (exchangeRate / targetCurrency.exchangeRate);
  }
}