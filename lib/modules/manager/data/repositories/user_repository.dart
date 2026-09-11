import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';
import '../models/user_model.dart';

class UserRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  UserRepository(this._dbHelper);

  Future<List<UserModel>> getAllUsers() async {
    final users = await _dbHelper.query(
      DatabaseConstants.tableUsers,
      orderBy: 'created_at DESC',
    );
    return users.map((user) => UserModel.fromMap(user)).toList();
  }

  Future<List<UserModel>> getWorkers() async {
    final users = await _dbHelper.query(
      DatabaseConstants.tableUsers,
      where: 'role = ? AND is_active = 1',
      whereArgs: ['worker'],
      orderBy: 'full_name ASC',
    );
    return users.map((user) => UserModel.fromMap(user)).toList();
  }

  Future<UserModel?> getUserById(int id) async {
    final users = await _dbHelper.query(
      DatabaseConstants.tableUsers,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (users.isNotEmpty) {
      return UserModel.fromMap(users.first);
    }
    return null;
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final users = await _dbHelper.query(
      DatabaseConstants.tableUsers,
      where: 'username = ?',
      whereArgs: [username],
    );
    if (users.isNotEmpty) {
      return UserModel.fromMap(users.first);
    }
    return null;
  }

  Future<int> addUser(UserModel user) async {
    final userWithUuid = user.copyWith(
      uuid: user.uuid.isEmpty ? _uuid.v4() : user.uuid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return await _dbHelper.insert(
      DatabaseConstants.tableUsers,
      userWithUuid.toDatabaseMap(),
    );
  }

  Future<int> updateUser(UserModel user) async {
    final updatedUser = user.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: 'updated',
    );
    return await _dbHelper.update(
      DatabaseConstants.tableUsers,
      updatedUser.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deactivateUser(int id) async {
    return await _dbHelper.update(
      DatabaseConstants.tableUsers,
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
        'sync_status': 'updated',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> activateUser(int id) async {
    return await _dbHelper.update(
      DatabaseConstants.tableUsers,
      {
        'is_active': 1,
        'updated_at': DateTime.now().toIso8601String(),
        'sync_status': 'updated',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> resetPassword(int id, String newPasswordHash) async {
    return await _dbHelper.update(
      DatabaseConstants.tableUsers,
      {
        'password_hash': newPasswordHash,
        'must_change_password': 1,
        'updated_at': DateTime.now().toIso8601String(),
        'sync_status': 'updated',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isUsernameExists(String username) async {
    final users = await _dbHelper.query(
      DatabaseConstants.tableUsers,
      where: 'username = ?',
      whereArgs: [username],
    );
    return users.isNotEmpty;
  }
}