import 'package:toy_store_pos/core/database/database_helper.dart';
import 'package:toy_store_pos/core/database/database_constants.dart';
import 'package:toy_store_pos/modules/manager/data/models/user_model.dart';
import 'password_hasher.dart';
import 'session_manager.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SessionManager _sessionManager = SessionManager.instance;

  // تسجيل الدخول
  Future<AuthResult> login(String username, String password) async {
    try {
      final users = await _dbHelper.query(
        DatabaseConstants.tableUsers,
        where: 'username = ?',
        whereArgs: [username],
      );

      if (users.isEmpty) {
        return AuthResult.failure('اسم المستخدم غير موجود');
      }

      final user = UserModel.fromMap(users.first);

      // التحقق من حالة الحساب
      if (!user.isActive) {
        return AuthResult.failure('هذا الحساب معطل، تواصل مع المدير');
      }

      // التحقق من كلمة المرور
      if (!PasswordHasher.verify(password, user.passwordHash)) {
        return AuthResult.failure('كلمة المرور غير صحيحة');
      }

      // تحديث آخر تسجيل دخول
      await _dbHelper.update(
        DatabaseConstants.tableUsers,
        {
          'last_login_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );

      // حفظ الجلسة
      await _sessionManager.saveSession(user);

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure('فشل تسجيل الدخول: $e');
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    await _sessionManager.clearSession();
  }

  // التحقق من الجلسة الحالية
  Future<UserModel?> getCurrentUser() async {
    return await _sessionManager.getCurrentUser();
  }

  // التحقق من وجود مدير مسجل
  Future<bool> hasManager() async {
    final users = await _dbHelper.query(
      DatabaseConstants.tableUsers,
      where: 'role = ?',
      whereArgs: ['manager'],
    );
    return users.isNotEmpty;
  }

  // إنشاء مدير أول مرة
  Future<AuthResult> createFirstManager({
    required String username,
    required String password,
    required String fullName,
    String? phone,
    String? email,
  }) async {
    try {
      // التحقق من عدم وجود مدير سابق
      if (await hasManager()) {
        return AuthResult.failure('يوجد مدير مسجل مسبقاً');
      }

      final user = UserModel(
        uuid: 'manager-${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        passwordHash: PasswordHasher.hash(password),
        fullName: fullName,
        phone: phone,
        email: email,
        role: 'manager',
        isActive: true,
        mustChangePassword: false,
      );

      final result = await _dbHelper.insert(
        DatabaseConstants.tableUsers,
        user.toDatabaseMap(),
      );

      if (result > 0) {
        return AuthResult.success(user);
      }
      return AuthResult.failure('فشل إنشاء حساب المدير');
    } catch (e) {
      return AuthResult.failure('فشل إنشاء حساب المدير: $e');
    }
  }

  // تغيير كلمة المرور
  Future<bool> changePassword(int userId, String newPassword) async {
    try {
      final result = await _dbHelper.update(
        DatabaseConstants.tableUsers,
        {
          'password_hash': PasswordHasher.hash(newPassword),
          'must_change_password': 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }
}

class AuthResult {
  final bool success;
  final UserModel? user;
  final String? message;

  AuthResult._({required this.success, this.user, this.message});

  factory AuthResult.success(UserModel user) {
    return AuthResult._(success: true, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(success: false, message: message);
  }
}