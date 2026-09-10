enum UserRole {
  manager('manager', 'مدير المتجر'),
  worker('worker', 'عامل / موظف');

  final String value;
  final String label;

  const UserRole(this.value, this.label);

  static UserRole fromString(String? value) {
    if (value == 'manager') return UserRole.manager;
    return UserRole.worker;
  }

  bool get isManager => this == UserRole.manager;
  bool get isWorker => this == UserRole.worker;
}