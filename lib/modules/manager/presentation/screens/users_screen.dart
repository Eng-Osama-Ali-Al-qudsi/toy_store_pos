import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/auth/password_hasher.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class UsersScreen extends StatefulWidget {
  final UserModel user;

  const UsersScreen({super.key, required this.user});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserRepository _userRepository = UserRepository(DatabaseHelper.instance);

  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  String _tr(String ar, String en) {
    return AppLocalizations.of(context).isArabic ? ar : en;
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _userRepository.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddUserDialog(
        onSave: (fullName, username, password, phone, role) async {
          final user = UserModel(
            uuid: '',
            username: username,
            passwordHash: PasswordHasher.hashPassword(password),
            fullName: fullName,
            phone: phone,
            role: role,
            mustChangePassword: true,
          );
          await _userRepository.addUser(user);
          await _loadUsers();
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_tr('تم إضافة المستخدم', 'User added')),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
          }
        },
      ),
    );
  }

  void _toggleUserStatus(UserModel user) async {
    if (user.isActive) {
      await _userRepository.deactivateUser(user.id!);
    } else {
      await _userRepository.activateUser(user.id!);
    }
    await _loadUsers();
  }

  void _resetPassword(UserModel user) async {
    await _userRepository.resetPassword(user.id!, PasswordHasher.hashPassword('123456'));
    await _loadUsers();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('تم إعادة تعيين كلمة المرور', 'Password reset')),
          backgroundColor: const Color(0xFF2196F3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_tr('المستخدمين', 'Users')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddUserDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(
        child: Text(_tr('لا توجد مستخدمين', 'No users'), style: TextStyle(color: colorScheme.onSurfaceVariant)),
      )
          : ListView.builder(
        padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + MediaQuery.of(context).padding.bottom),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: user.isManager
                    ? const Color(0xFFFF9800).withValues(alpha: 0.2)
                    : const Color(0xFF2196F3).withValues(alpha: 0.2),
                child: Icon(
                  user.isManager ? Icons.admin_panel_settings : Icons.person,
                  color: user.isManager ? const Color(0xFFFF9800) : const Color(0xFF2196F3),
                ),
              ),
              title: Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.isManager ? _tr('مدير', 'Manager') : _tr('عامل', 'Worker')),
                  Text(user.username),
                  if (user.isActive)
                    Text(_tr('نشط', 'Active'), style: const TextStyle(color: Color(0xFF4CAF50)))
                  else
                    Text(_tr('معطل', 'Inactive'), style: const TextStyle(color: Color(0xFFF44336))),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      user.isActive ? Icons.block : Icons.check_circle,
                      color: user.isActive ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
                    ),
                    onPressed: () => _toggleUserStatus(user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.lock_reset, color: Color(0xFF2196F3)),
                    onPressed: () => _resetPassword(user),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AddUserDialog extends StatefulWidget {
  final Function(String fullName, String username, String password, String? phone, String role) onSave;

  const _AddUserDialog({required this.onSave});

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String _role = 'worker';

  String _tr(String ar, String en) {
    return AppLocalizations.of(context).isArabic ? ar : en;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _fullNameController.text,
        _usernameController.text,
        _passwordController.text,
        _phoneController.text.isEmpty ? null : _phoneController.text,
        _role,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_tr('إضافة مستخدم', 'Add User')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: _tr('الاسم الكامل', 'Full Name')),
                validator: (v) => v!.isEmpty ? _tr('مطلوب', 'Required') : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: _tr('اسم المستخدم', 'Username')),
                validator: (v) => v!.isEmpty ? _tr('مطلوب', 'Required') : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: _tr('كلمة المرور المؤقتة', 'Temporary Password')),
                obscureText: true,
                validator: (v) => v!.isEmpty ? _tr('مطلوب', 'Required') : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: _tr('رقم الهاتف (اختياري)', 'Phone (optional)')),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: InputDecoration(labelText: _tr('الدور', 'Role')),
                items: [
                  DropdownMenuItem(value: 'worker', child: Text(_tr('عامل', 'Worker'))),
                  DropdownMenuItem(value: 'manager', child: Text(_tr('مدير', 'Manager'))),
                ],
                onChanged: (value) => setState(() => _role = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_tr('إلغاء', 'Cancel')),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(_tr('حفظ', 'Save')),
        ),
      ],
    );
  }
}