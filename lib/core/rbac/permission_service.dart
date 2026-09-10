import '../../modules/manager/data/models/user_model.dart';
import 'permission.dart';
import 'user_role.dart';

class PermissionService {
  PermissionService._();

  static final PermissionService instance = PermissionService._();

  bool hasPermission(UserModel? user, Permission permission) {
    if (user == null) return false;

    // المدير لديه كل الصلاحيات
    if (user.role == UserRole.manager) {
      return true;
    }

    // العامل: فحص الصلاحيات المخصصة
    final customPermissions = _getCustomPermissions(user.id);
    if (customPermissions.contains(permission)) {
      return true;
    }

    // الصلاحيات الافتراضية للعامل
    return DefaultPermissions.workerPermissions.contains(permission);
  }

  bool hasAnyPermission(UserModel? user, List<Permission> permissions) {
    for (var permission in permissions) {
      if (hasPermission(user, permission)) return true;
    }
    return false;
  }

  bool hasAllPermissions(UserModel? user, List<Permission> permissions) {
    for (var permission in permissions) {
      if (!hasPermission(user, permission)) return false;
    }
    return true;
  }

  Set<Permission> _getCustomPermissions(int? userId) {
    if (userId == null) return {};
    // سيتم ربطها بقاعدة البيانات لاحقاً
    return {};
  }

  List<Permission> getUserPermissions(UserModel? user) {
    if (user == null) return [];
    if (user.role == UserRole.manager) {
      return Permission.values.toList();
    }
    return DefaultPermissions.workerPermissions.toList();
  }
}