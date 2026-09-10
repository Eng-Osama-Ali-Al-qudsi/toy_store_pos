import 'package:flutter/material.dart';
import '../../modules/manager/data/models/user_model.dart';
import 'permission.dart';
import 'permission_service.dart';
import 'user_role.dart';

class RouteGuard {
  RouteGuard._();

  static final PermissionService _permissionService = PermissionService.instance;

  // التحقق من صلاحية الوصول لمسار
  static bool canAccess(UserModel? user, Permission permission) {
    return _permissionService.hasPermission(user, permission);
  }

  // التحقق من صلاحية الوصول لشاشة
  static bool canAccessScreen(UserModel? user, ScreenType screenType) {
    if (user == null) return false;

    switch (screenType) {
      case ScreenType.managerDashboard:
      case ScreenType.manageUsers:
      case ScreenType.manageWallets:
      case ScreenType.manageSettings:
      case ScreenType.viewFinancialReports:
      case ScreenType.manageCashbox:
      case ScreenType.manageInventory:
      case ScreenType.manageSuppliers:
      case ScreenType.manageCustomers:
      case ScreenType.viewAuditLogs:
      case ScreenType.manageBackup:
        return user.role == UserRole.manager;

      case ScreenType.workerPOS:
      case ScreenType.workerProfile:
      case ScreenType.workerSettings:
      case ScreenType.workerMySales:
        return user.role == UserRole.worker;

      case ScreenType.products:
        return _permissionService.hasPermission(user, Permission.viewProducts);

      case ScreenType.sales:
        return _permissionService.hasPermission(user, Permission.viewAllSales) ||
            _permissionService.hasPermission(user, Permission.viewOwnSales);

      case ScreenType.expenses:
        return _permissionService.hasPermission(user, Permission.viewExpenses);

      case ScreenType.reports:
        return _permissionService.hasPermission(user, Permission.viewReports);

      case ScreenType.attendance:
        return _permissionService.hasPermission(user, Permission.viewAttendance);

      default:
        return true;
    }
  }

  // حماية شاشة معينة
  static Widget guardScreen({
    required UserModel? user,
    required ScreenType screenType,
    required Widget screen,
  }) {
    if (canAccessScreen(user, screenType)) {
      return screen;
    }
    return const Scaffold(
      body: Center(
        child: Text(
          'ليس لديك صلاحية للوصول لهذه الشاشة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

enum ScreenType {
  managerDashboard,
  workerPOS,
  workerProfile,
  workerSettings,
  workerMySales,
  products,
  sales,
  expenses,
  reports,
  attendance,
  manageUsers,
  manageWallets,
  manageSettings,
  viewFinancialReports,
  manageCashbox,
  manageInventory,
  manageSuppliers,
  manageCustomers,
  viewAuditLogs,
  manageBackup,
}