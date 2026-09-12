import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../manager/data/models/user_model.dart';
import '../../../manager/data/models/expense_model.dart';
import '../../../manager/data/models/wallet_model.dart';
import '../../../manager/data/repositories/expense_repository.dart';
import '../../../manager/data/repositories/wallet_repository.dart';

class WorkerExpensesScreen extends StatefulWidget {
  final UserModel user;

  const WorkerExpensesScreen({super.key, required this.user});

  @override
  State<WorkerExpensesScreen> createState() => _WorkerExpensesScreenState();
}

class _WorkerExpensesScreenState extends State<WorkerExpensesScreen> {
  final ExpenseRepository _expenseRepository = ExpenseRepository(DatabaseHelper.instance);
  final WalletRepository _walletRepository = WalletRepository(DatabaseHelper.instance);

  List<ExpenseModel> _myExpenses = [];
  List<WalletModel> _wallets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _tr(String ar, String en) {
    return AppLocalizations.of(context).isArabic ? ar : en;
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final expenses = await _expenseRepository.getExpensesByUser(widget.user.id!);
    final wallets = await _walletRepository.getAllWallets();
    setState(() {
      _myExpenses = expenses;
      _wallets = wallets;
      _isLoading = false;
    });
  }

  String _getWalletName(int? walletId) {
    if (walletId == null) return '';
    for (var wallet in _wallets) {
      if (wallet.id == walletId) return wallet.name;
    }
    return _tr('محفظة غير معروفة', 'Unknown wallet');
  }

  void _showAddExpenseDialog() async {
    final activeWallets = await _walletRepository.getActiveWallets();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => _ExpenseDialog(
        wallets: activeWallets,
        onSave: (description, amount, paymentMethod, walletId) async {
          final expense = ExpenseModel(
            uuid: '',
            amount: amount,
            description: description,
            paymentMethod: paymentMethod,
            walletId: walletId,
            expenseDate: DateTime.now(),
            createdBy: widget.user.id!,
          );
          await _expenseRepository.addExpense(expense);
          await _loadData();
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_tr('تم تسجيل المصروف', 'Expense recorded')),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
          }
        },
      ),
    );
  }

  void _showExpenseDetails(ExpenseModel expense) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCash = expense.paymentMethod == 'cash';
    final walletName = isCash ? '' : _getWalletName(expense.walletId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_tr('تفاصيل المصروف', 'Expense Details')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(context, _tr('الوصف', 'Description'), expense.description ?? ''),
            _buildDetailRow(context, _tr('المبلغ', 'Amount'), '${expense.amount}'),
            _buildDetailRow(
              context,
              _tr('مصدر الدفع', 'Payment Source'),
              isCash ? '💵 ${_tr('الصندوق (نقداً)', 'Cashbox (Cash)')}' : '💳 ${_tr('محفظة', 'Wallet')} $walletName',
            ),
            _buildDetailRow(
              context,
              _tr('التاريخ', 'Date'),
              '${expense.expenseDate.day}/${expense.expenseDate.month}/${expense.expenseDate.year}',
            ),
            _buildDetailRow(
              context,
              _tr('الوقت', 'Time'),
              '${expense.expenseDate.hour}:${expense.expenseDate.minute.toString().padLeft(2, '0')}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_tr('إغلاق', 'Close')),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_tr('المصروفات', 'Expenses')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddExpenseDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myExpenses.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(_tr('لا توجد مصروفات', 'No expenses'), style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + MediaQuery.of(context).padding.bottom),
        itemCount: _myExpenses.length,
        itemBuilder: (context, index) {
          final expense = _myExpenses[index];
          return _buildExpenseCard(context, expense);
        },
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, ExpenseModel expense) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCash = expense.paymentMethod == 'cash';
    final walletName = isCash ? '' : _getWalletName(expense.walletId);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: (isCash ? const Color(0xFF4CAF50) : const Color(0xFF2196F3)).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isCash ? Icons.money : Icons.wallet,
            color: isCash ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
          ),
        ),
        title: Text(
          expense.description ?? '',
          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCash ? '💵 ${_tr('الصندوق (نقداً)', 'Cashbox (Cash)')}' : '💳 ${_tr('محفظة', 'Wallet')} $walletName',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isCash ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
              ),
            ),
            Text(
              '${expense.expenseDate.day}/${expense.expenseDate.month}/${expense.expenseDate.year}',
              style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        trailing: Text(
          '${expense.amount}',
          style: TextStyle(
            color: isCash ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () => _showExpenseDetails(expense),
      ),
    );
  }
}

class _ExpenseDialog extends StatefulWidget {
  final List<WalletModel> wallets;
  final Function(String description, double amount, String paymentMethod, int? walletId) onSave;

  const _ExpenseDialog({required this.wallets, required this.onSave});

  @override
  State<_ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<_ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String _paymentMethod = 'cash';
  int? _selectedWalletId;

  String _tr(String ar, String en) {
    return AppLocalizations.of(context).isArabic ? ar : en;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (_paymentMethod == 'wallet' && _selectedWalletId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr('اختر المحفظة', 'Select wallet')),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
        return;
      }
      widget.onSave(
        _descriptionController.text,
        double.tryParse(_amountController.text) ?? 0,
        _paymentMethod,
        _selectedWalletId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_tr('إضافة مصروف', 'Add Expense')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: _tr('الوصف / سبب المصروف', 'Description / Reason')),
                validator: (v) => v!.isEmpty ? _tr('مطلوب', 'Required') : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: _tr('المبلغ', 'Amount')),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? _tr('مطلوب', 'Required') : null,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(_tr('مصدر الدفع:', 'Payment Source:'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'cash',
                    label: Text(_tr('الصندوق', 'Cashbox')),
                    icon: const Icon(Icons.money, size: 16),
                  ),
                  ButtonSegment(
                    value: 'wallet',
                    label: Text(_tr('محفظة', 'Wallet')),
                    icon: const Icon(Icons.wallet, size: 16),
                  ),
                ],
                selected: {_paymentMethod},
                onSelectionChanged: (value) {
                  setState(() => _paymentMethod = value.first);
                },
              ),
              if (_paymentMethod == 'wallet') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _selectedWalletId,
                  decoration: InputDecoration(labelText: _tr('اختر المحفظة', 'Select Wallet')),
                  items: widget.wallets.map((wallet) {
                    return DropdownMenuItem(
                      value: wallet.id,
                      child: Text('${wallet.name} (${wallet.currentBalance})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedWalletId = value);
                  },
                ),
              ],
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