import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/cashbox_repository.dart';

class CashboxScreen extends StatefulWidget {
  final UserModel user;

  const CashboxScreen({super.key, required this.user});

  @override
  State<CashboxScreen> createState() => _CashboxScreenState();
}

class _CashboxScreenState extends State<CashboxScreen> {
  final CashboxRepository _cashboxRepository = CashboxRepository(DatabaseHelper.instance);

  double _currentBalance = 0;
  double _totalDeposits = 0;
  double _totalWithdrawals = 0;
  List<Map<String, dynamic>> _transactions = [];
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
    final balance = await _cashboxRepository.getCurrentBalance();
    final deposits = await _cashboxRepository.getTotalDeposits();
    final withdrawals = await _cashboxRepository.getTotalWithdrawals();
    final transactions = await _cashboxRepository.getTransactions(limit: 100);

    setState(() {
      _currentBalance = balance;
      _totalDeposits = deposits;
      _totalWithdrawals = withdrawals;
      _transactions = transactions;
      _isLoading = false;
    });
  }

  // ✅ فتح تفاصيل العملية
  void _showTransactionDetails(Map<String, dynamic> transaction) {
    final colorScheme = Theme.of(context).colorScheme;
    final type = transaction['transaction_type'] as String? ?? '';
    final isDeposit = type == 'SALE' || type == 'DEPOSIT' || type == 'RETURN';
    final createdAt = DateTime.tryParse(transaction['created_at'] as String? ?? '') ?? DateTime.now();

    IconData typeIcon;
    Color typeColor;
    String typeLabel;

    switch (type) {
      case 'SALE':
        typeIcon = Icons.shopping_cart;
        typeColor = const Color(0xFF4CAF50);
        typeLabel = _tr('عملية بيع', 'Sale');
        break;
      case 'EXPENSE':
        typeIcon = Icons.money_off;
        typeColor = const Color(0xFFF44336);
        typeLabel = _tr('مصروف', 'Expense');
        break;
      case 'WITHDRAWAL':
        typeIcon = Icons.arrow_upward;
        typeColor = const Color(0xFFF44336);
        typeLabel = _tr('سحب نقدي', 'Cash Withdrawal');
        break;
      case 'DEPOSIT':
        typeIcon = Icons.arrow_downward;
        typeColor = const Color(0xFF4CAF50);
        typeLabel = _tr('إيداع نقدي', 'Cash Deposit');
        break;
      case 'RETURN':
        typeIcon = Icons.assignment_return;
        typeColor = const Color(0xFF2196F3);
        typeLabel = _tr('إرجاع عملية', 'Return');
        break;
      default:
        typeIcon = Icons.swap_horiz;
        typeColor = const Color(0xFF9C27B0);
        typeLabel = _tr('تعديل', 'Adjustment');
    }

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          typeLabel,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                          ),
                        ),
                        Text(
                          '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Text(
                      isDeposit ? _tr('المبلغ المستلم', 'Amount Received') : _tr('المبلغ المسحوب', 'Amount Withdrawn'),
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${isDeposit ? '+' : '-'}${transaction['amount']}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow(dialogContext, _tr('نوع العملية', 'Type'), typeLabel, typeColor),
              _buildDetailRow(dialogContext, _tr('السبب', 'Reason'), transaction['reason'] as String? ?? _tr('غير محدد', 'N/A'), null),
              _buildDetailRow(dialogContext, _tr('الرصيد قبل', 'Balance Before'), '${transaction['balance_before']}', null),
              _buildDetailRow(dialogContext, _tr('الرصيد بعد', 'Balance After'), '${transaction['balance_after']}', null),
              if (transaction['reference_type'] != null)
                _buildDetailRow(dialogContext, _tr('المرجع', 'Reference'), '${transaction['reference_type']}', null),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_tr('إغلاق', 'Close')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, Color? valueColor) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => _CashDialog(
        title: _tr('سحب نقدي', 'Cash Withdrawal'),
        isDeposit: false,
        onSave: (amount, reason) async {
          await _cashboxRepository.withdrawCash(
            amount: amount,
            reason: reason,
            createdBy: widget.user.id!,
          );
          await _loadData();
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _showDepositDialog() {
    showDialog(
      context: context,
      builder: (context) => _CashDialog(
        title: _tr('إيداع نقدي', 'Cash Deposit'),
        isDeposit: true,
        onSave: (amount, reason) async {
          await _cashboxRepository.depositCash(
            amount: amount,
            reason: reason,
            createdBy: widget.user.id!,
          );
          await _loadData();
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_tr('الخزنة', 'Cashbox')),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showDepositDialog, tooltip: _tr('إيداع', 'Deposit')),
          IconButton(icon: const Icon(Icons.remove), onPressed: _showWithdrawDialog, tooltip: _tr('سحب', 'Withdraw')),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(_tr('الرصيد الحالي', 'Current Balance'), style: const TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '$_currentBalance',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(context, _tr('الإيداعات', 'Deposits'), _totalDeposits, Icons.arrow_downward, const Color(0xFF4CAF50)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(context, _tr('السحوبات', 'Withdrawals'), _totalWithdrawals, Icons.arrow_upward, const Color(0xFFF44336)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _tr('سجل العمليات', 'Transaction Log'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            if (_transactions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(_tr('لا توجد عمليات', 'No transactions'), style: TextStyle(color: colorScheme.onSurfaceVariant)),
                ),
              )
            else
              ..._transactions.map((transaction) => _buildTransactionCard(context, transaction)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, double value, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(0)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Map<String, dynamic> transaction) {
    final colorScheme = Theme.of(context).colorScheme;
    final type = transaction['transaction_type'] as String? ?? '';
    final isDeposit = type == 'SALE' || type == 'DEPOSIT' || type == 'RETURN';
    final createdAt = DateTime.tryParse(transaction['created_at'] as String? ?? '') ?? DateTime.now();

    IconData typeIcon;
    Color typeColor;

    switch (type) {
      case 'SALE':
        typeIcon = Icons.shopping_cart;
        typeColor = const Color(0xFF4CAF50);
        break;
      case 'EXPENSE':
        typeIcon = Icons.money_off;
        typeColor = const Color(0xFFF44336);
        break;
      case 'WITHDRAWAL':
        typeIcon = Icons.arrow_upward;
        typeColor = const Color(0xFFF44336);
        break;
      case 'DEPOSIT':
        typeIcon = Icons.arrow_downward;
        typeColor = const Color(0xFF4CAF50);
        break;
      case 'RETURN':
        typeIcon = Icons.assignment_return;
        typeColor = const Color(0xFF2196F3);
        break;
      default:
        typeIcon = Icons.swap_horiz;
        typeColor = const Color(0xFF9C27B0);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(typeIcon, color: typeColor, size: 20),
        ),
        title: Text(
          transaction['reason'] as String? ?? type,
          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
          style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isDeposit ? '+' : '-'}${transaction['amount']}',
              style: TextStyle(fontWeight: FontWeight.bold, color: typeColor),
            ),
            Text(
              '${_tr('الرصيد', 'Bal')}: ${transaction['balance_after']}',
              style: TextStyle(fontSize: 9, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }
}

class _CashDialog extends StatefulWidget {
  final String title;
  final bool isDeposit;
  final Function(double amount, String reason) onSave;

  const _CashDialog({
    required this.title,
    required this.isDeposit,
    required this.onSave,
  });

  @override
  State<_CashDialog> createState() => _CashDialogState();
}

class _CashDialogState extends State<_CashDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  String _tr(String ar, String en) {
    return AppLocalizations.of(context).isArabic ? ar : en;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        double.tryParse(_amountController.text) ?? 0,
        _reasonController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: _tr('المبلغ', 'Amount'), prefixIcon: const Icon(Icons.money)),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? _tr('المبلغ مطلوب', 'Amount required') : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(labelText: _tr('السبب', 'Reason'), prefixIcon: const Icon(Icons.description)),
                validator: (v) => v!.isEmpty ? _tr('السبب مطلوب', 'Reason required') : null,
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