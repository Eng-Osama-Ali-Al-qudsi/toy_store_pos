import 'dart:convert';
import '../../../../core/rbac/user_role.dart';

class UserModel {
  final int? id;
  final String uuid;
  final String username;
  final String passwordHash;
  final String fullName;
  final String? phone;
  final String? email;
  final String? avatar;
  final String role;
  final bool isActive;
  final bool mustChangePassword;
  final DateTime? lastLoginAt;
  final String? deviceInfo;
  final int? branchId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String syncStatus;

  UserModel({
    this.id,
    required this.uuid,
    required this.username,
    required this.passwordHash,
    required this.fullName,
    this.phone,
    this.email,
    this.avatar,
    required this.role,
    this.isActive = true,
    this.mustChangePassword = false,
    this.lastLoginAt,
    this.deviceInfo,
    this.branchId,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'pending',
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      username: map['username'] as String? ?? '',
      passwordHash: map['password_hash'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      avatar: map['avatar'] as String?,
      role: map['role'] as String? ?? 'worker',
      isActive: (map['is_active'] as int? ?? 1) == 1,
      mustChangePassword: (map['must_change_password'] as int? ?? 0) == 1,
      lastLoginAt: map['last_login_at'] != null ? DateTime.tryParse(map['last_login_at'] as String) : null,
      deviceInfo: map['device_info'] as String?,
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
      'username': username,
      'password_hash': passwordHash,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      'role': role,
      'is_active': isActive ? 1 : 0,
      'must_change_password': mustChangePassword ? 1 : 0,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'device_info': deviceInfo,
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

  UserRole get userRole => UserRole.fromString(role);

  bool get isManager => userRole == UserRole.manager;
  bool get isWorker => userRole == UserRole.worker;

  UserModel copyWith({
    int? id,
    String? uuid,
    String? username,
    String? passwordHash,
    String? fullName,
    String? phone,
    String? email,
    String? avatar,
    String? role,
    bool? isActive,
    bool? mustChangePassword,
    DateTime? lastLoginAt,
    String? deviceInfo,
    int? branchId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return UserModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      branchId: branchId ?? this.branchId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserModel.fromJson(String json) {
    return UserModel.fromMap(jsonDecode(json));
  }
}