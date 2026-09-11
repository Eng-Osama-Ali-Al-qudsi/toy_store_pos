import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/models/user_model.dart';
import '../../data/models/wallet_model.dart';
import '../../data/repositories/wallet_repository.dart';
import 'wallet_detail_screen.dart';

class WalletsScreen extends StatefulWidget {
  final UserModel user;

  const WalletsScreen({super.key, required this.user});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  final WalletRepository _walletRepository = WalletRepository(DatabaseHelper.instance);

  List<WalletModel> _wallets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  String _tr(String ar, String en) {
    return AppLocalizations.of(context).isArabic ? ar : en;
  }

  Future<void> _loadWallets() async {
    setState(() => _isLoading = true);
    final wallets = await _walletRepository.getAllWallets();
    setState(() {
      _wallets = wallets;
      _isLoading = false;
    });
  }

  void _showAddWalletDialog() {
    showDialog(
      context: context,
      builder: (context) => _WalletDialog(
        onSave: (name, number, owner, initialBalance, notes) async {
          final wallet = WalletModel(
            uuid: '',
            name: name,
            walletNumber: number,
            ownerName: owner,
            initialBalance: initialBalance,
            notes: notes,
            createdBy: widget.user.id!,
          );
          await _walletRepository.addWallet(wallet);
          await _loadWallets();
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _deactivateWallet(WalletModel wallet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr('تعطيل المحفظة', 'Deactivate Wallet')),
        content: Text('${_tr('هل تريد تعطيل', 'Do you want to deactivate')} ${wallet.name}؟\n${_tr('لن يتم حذف المحفظة أو بياناتها.', 'The wallet and its data will NOT be deleted.')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_tr('إلغاء', 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF44336)),
            child: Text(_tr('تعطيل', 'Deactivate')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _walletRepository.deactivateWallet(wallet.id!);
      await _loadWallets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr('تم تعطيل المحفظة', 'Wallet deactivated')),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    }
  }

  void _activateWallet(WalletModel wallet) async {
    await _walletRepository.activateWallet(wallet.id!);
    await _loadWallets();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('تم تفعيل المحفظة', 'Wallet activated')),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    }
  }

  void _openWalletDetail(WalletModel wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletDetailScreen(user: widget.user, wallet: wallet),
      ),
    ).then((_) => _loadWallets());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_tr('المحافظ الإلكترونية', 'E-Wallets')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddWalletDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wallets.isEmpty
          ? Center(
        child: Text(
          _tr('لا توجد محافظ', 'No wallets available'),
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + MediaQuery.of(context).padding.bottom),
        itemCount: _wallets.length,
        itemBuilder: (context, index) {
          final wallet = _wallets[index];
          return _buildWalletCard(context, wallet);
        },
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, WalletModel wallet) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = wallet.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (isActive ? const Color(0xFF2196F3) : Colors.grey).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.wallet,
            color: isActive ? const Color(0xFF2196F3) : Colors.grey,
          ),
        ),
        title: Text(
          wallet.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? colorScheme.onSurface : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_tr('الرصيد', 'Balance')}: ${wallet.currentBalance}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF2196F3) : Colors.grey,
              ),
            ),
            Text(
              isActive ? _tr('نشطة', 'Active') : _tr('معطلة', 'Inactive'),
              style: TextStyle(
                fontSize: 11,
                color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isActive ? Icons.block : Icons.check_circle,
                color: isActive ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
              ),
              onPressed: () {
                if (isActive) {
                  _deactivateWallet(wallet);
                } else {
                  _activateWallet(wallet);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward, color: colorScheme.primary),
              onPressed: () => _openWalletDetail(wallet),
            ),
          ],
        ),
        onTap: () => _openWalletDetail(wallet),
      ),
    );
  }
}

class _WalletDialog extends StatefulWidget {
  final Function(String name, String? number, String? owner, double initialBalance, String? notes) onSave;

  const _WalletDialog({required this.onSave});

  @override
  State<_WalletDialog> createState() => _WalletDialogState();
}

class _WalletDialogState extends State<_WalletDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _ownerController = TextEditingController();
  final _balanceController = TextEditingController();
  final _notesController = TextEditingController();

  String _tr(String ar, String en) {
    return AppLocalizations.of(context).isArabic ? ar : en;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _ownerController.dispose();
    _balanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _nameController.text,
        _numberController.text.isEmpty ? null : _numberController.text,
        _ownerController.text.isEmpty ? null : _ownerController.text,
        double.tryParse(_balanceController.text) ?? 0,
        _notesController.text.isEmpty ? null : _notesController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_tr('إضافة محفظة', 'Add Wallet')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: _tr('اسم المحفظة', 'Wallet Name')),
                validator: (v) => v!.isEmpty ? _tr('مطلوب', 'Required') : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _numberController,
                decoration: InputDecoration(labelText: _tr('رقم المحفظة (اختياري)', 'Wallet Number (optional)')),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _ownerController,
                decoration: InputDecoration(labelText: _tr('اسم المالك (اختياري)', 'Owner Name (optional)')),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _balanceController,
                decoration: InputDecoration(labelText: _tr('الرصيد الابتدائي', 'Initial Balance')),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: _tr('ملاحظات (اختياري)', 'Notes (optional)')),
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