import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/models/user_model.dart';
import '../../data/models/wallet_model.dart';
import '../../data/repositories/wallet_repository.dart';

class WalletDetailScreen extends StatefulWidget {
  final UserModel user;
  final WalletModel wallet;

  const WalletDetailScreen({super.key, required this.user, required this.wallet});

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  final WalletRepository _walletRepository = WalletRepository(DatabaseHelper.instance);

  WalletModel? _wallet;
  List<Map<String, dynamic>> _transactions = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    final wallet = await _walletRepository.getWalletById(widget.wallet.id!);
    final transactions = await _walletRepository.getWalletTransactions(widget.wallet.id!);
    final stats = await _walletRepository.getWalletStats(widget.wallet.id!);

    setState(() {
      _wallet = wallet;
      _transactions = transactions;
      _stats = stats;
      _isLoading = false;
    });
  }

  void _showDepositDialog() {
    showDialog(
      context: context,
      builder: (context) => _WalletTransactionDialog(
        title: 'إيداع في المحفظة',
        isDeposit: true,
        onSave: (amount, reason) async {
          final result = await _walletRepository.depositToWallet(
            walletId: widget.wallet.id!,
            amount: amount,
            reason: reason,
            createdBy: widget.user.id!,
            referenceType: 'manual',
          );
          await _loadWalletData();
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result > 0 ? 'تم الإيداع بنجاح' : 'فشل الإيداع'),
                backgroundColor: result > 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
              ),
            );
          }
        },
      ),
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => _WalletTransactionDialog(
        title: 'سحب من المحفظة',
        isDeposit: false,
        onSave: (amount, reason) async {
          final result = await _walletRepository.withdrawFromWallet(
            walletId: widget.wallet.id!,
            amount: amount,
            reason: reason,
            createdBy: widget.user.id!,
            referenceType: 'manual',
          );
          await _loadWalletData();
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result > 0
                      ? 'تم السحب بنجاح'
                      : result == -2
                      ? 'الرصيد غير كافٍ'
                      : 'فشل السحب',
                ),
                backgroundColor: result > 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final wallet = _wallet ?? widget.wallet;

    return Scaffold(
      appBar: AppBar(title: Text(wallet.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== بطاقة الرصيد =====
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    wallet.isActive ? const Color(0xFF2196F3) : Colors.grey,
                    wallet.isActive ? const Color(0xFF1976D2) : Colors.grey.shade600,
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'الرصيد الحالي',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${wallet.currentBalance}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    wallet.isActive ? 'نشطة' : 'معطلة',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ===== إحصائيات =====
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(context, 'إجمالي الداخل', _stats['total_credits'] ?? 0, Icons.arrow_downward, const Color(0xFF4CAF50)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(context, 'إجمالي السحوبات', _stats['total_debits'] ?? 0, Icons.arrow_upward, const Color(0xFFF44336)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(context, 'عدد العمليات', (_stats['total_transactions'] ?? 0).toDouble(), Icons.receipt, const Color(0xFFFF9800)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ===== أزرار الإيداع والسحب =====
            if (wallet.isActive) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showDepositDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('إيداع'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showWithdrawDialog,
                      icon: const Icon(Icons.remove),
                      label: const Text('سحب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF44336),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // ===== سجل العمليات =====
            Text(
              'سجل العمليات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            if (_transactions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'لا توجد عمليات',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(0)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Map<String, dynamic> transaction) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCredit = transaction['transaction_type'] == 'credit';
    final date = DateTime.tryParse(transaction['created_at'] as String? ?? '') ?? DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isCredit ? const Color(0xFF4CAF50) : const Color(0xFFF44336)).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
            size: 20,
          ),
        ),
        title: Text(
          transaction['description'] as String? ?? (isCredit ? 'إيداع' : 'سحب'),
          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 13),
        ),
        subtitle: Text(
          '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
          style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCredit ? '+' : '-'}${transaction['amount']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCredit ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
              ),
            ),
            Text(
              'الرصيد: ${transaction['balance_after']}',
              style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletTransactionDialog extends StatefulWidget {
  final String title;
  final bool isDeposit;
  final Function(double amount, String reason) onSave;

  const _WalletTransactionDialog({
    required this.title,
    required this.isDeposit,
    required this.onSave,
  });

  @override
  State<_WalletTransactionDialog> createState() => _WalletTransactionDialogState();
}

class _WalletTransactionDialogState extends State<_WalletTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

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
                decoration: const InputDecoration(labelText: 'المبلغ'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(labelText: 'السبب / الوصف'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}