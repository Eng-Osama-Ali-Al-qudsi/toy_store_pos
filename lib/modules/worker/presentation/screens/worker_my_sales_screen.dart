import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../manager/data/models/user_model.dart';
import '../../../manager/data/repositories/sale_repository.dart';

class WorkerMySalesScreen extends StatefulWidget {
  final UserModel user;

  const WorkerMySalesScreen({super.key, required this.user});

  @override
  State<WorkerMySalesScreen> createState() => _WorkerMySalesScreenState();
}

class _WorkerMySalesScreenState extends State<WorkerMySalesScreen> {
  final SaleRepository _saleRepository = SaleRepository(DatabaseHelper.instance);

  List<Map<String, dynamic>> _sales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => _isLoading = true);
    final sales = await _saleRepository.getSalesByUser(widget.user.id!);
    setState(() {
      _sales = sales;
      _isLoading = false;
    });
  }

  void _showSaleDetails(Map<String, dynamic> sale) async {
    final saleItems = await _saleRepository.getSaleItems(sale['id'] as int? ?? 0);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => _SaleDetailDialog(
        sale: sale,
        saleItems: saleItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mySales)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sales.isEmpty
          ? Center(
        child: Text('لا توجد مبيعات', style: TextStyle(color: colorScheme.onSurfaceVariant)),
      )
          : ListView.builder(
        padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + MediaQuery.of(context).padding.bottom),
        itemCount: _sales.length,
        itemBuilder: (context, index) {
          final sale = _sales[index];
          return _buildSaleCard(context, sale);
        },
      ),
    );
  }

  Widget _buildSaleCard(BuildContext context, Map<String, dynamic> sale) {
    final colorScheme = Theme.of(context).colorScheme;
    final saleDate = DateTime.tryParse(sale['sale_date'] as String? ?? '') ?? DateTime.now();
    final paymentMethod = sale['payment_method'] as String? ?? 'cash';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: (paymentMethod == 'cash' ? const Color(0xFF4CAF50) : const Color(0xFF2196F3)).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            paymentMethod == 'cash' ? Icons.money : Icons.wallet,
            color: paymentMethod == 'cash' ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
          ),
        ),
        title: Text(
          sale['invoice_number'] as String? ?? '',
          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        subtitle: Text(
          '${saleDate.day}/${saleDate.month}/${saleDate.year} ${saleDate.hour}:${saleDate.minute.toString().padLeft(2, '0')}',
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
        trailing: Text(
          '${(sale['total_amount'] as num?)?.toDouble() ?? 0}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.primary,
          ),
        ),
        onTap: () => _showSaleDetails(sale),
      ),
    );
  }
}

class _SaleDetailDialog extends StatelessWidget {
  final Map<String, dynamic> sale;
  final List<Map<String, dynamic>> saleItems;

  const _SaleDetailDialog({required this.sale, required this.saleItems});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final saleDate = DateTime.tryParse(sale['sale_date'] as String? ?? '') ?? DateTime.now();
    final paymentMethod = sale['payment_method'] as String? ?? 'cash';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale['invoice_number'] as String? ?? '',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      Text(
                        '${saleDate.day}/${saleDate.month}/${saleDate.year} ${saleDate.hour}:${saleDate.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: saleItems.length,
                itemBuilder: (context, index) {
                  final item = saleItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'منتج ${item['product_id']}',
                            style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
                          ),
                        ),
                        Text(
                          '${item['quantity']} × ${item['unit_price']}',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
                        ),
                        Text(
                          '${item['total_price']}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            _buildSummaryRow(context, 'الإجمالي', '${sale['total_amount']}'),
            _buildSummaryRow(
              context,
              'طريقة الدفع',
              paymentMethod == 'cash' ? 'نقداً' : 'محفظة',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 14)),
        ],
      ),
    );
  }
}