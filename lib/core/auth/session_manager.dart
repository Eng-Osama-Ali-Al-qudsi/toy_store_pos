import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../modules/manager/data/models/user_model.dart';

class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _sessionKey = 'session_token';
  static const String _userKey = 'current_user';
  static const String _roleKey = 'current_role';

  Future<void> saveSession(UserModel user) async {
    await _storage.write(key: _sessionKey, value: user.uuid);
    await _storage.write(key: _roleKey, value: user.role);
    await _storage.write(key: _userKey, value: jsonEncode(user.toMap()));
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null && userJson.isNotEmpty) {
        return UserModel.fromMap(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getSessionToken() async {
    return await _storage.read(key: _sessionKey);
  }

  Future<String?> getCurrentRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getSessionToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _roleKey);
  }
}