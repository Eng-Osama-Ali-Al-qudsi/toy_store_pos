import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/report_repository.dart';

class ReportsScreen extends StatefulWidget {
  final UserModel user;

  const ReportsScreen({super.key, required this.user});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportRepository _reportRepository = ReportRepository(DatabaseHelper.instance);

  String _period = 'daily';
  String _reportType = 'comprehensive';
  Map<String, dynamic>? _reportData;
  bool _isLoading = true;
  bool _isGeneratingPdf = false;
  DateTime _customStartDate = DateTime.now();
  DateTime _customEndDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  String _tr(String ar, String en) {
    return AppLocalizations.of(context).isArabic ? ar : en;
  }

  DateTimeRange _getDateRange() {
    final now = DateTime.now();
    switch (_period) {
      case 'daily':
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: DateTime(yesterday.year, yesterday.month, yesterday.day),
          end: DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
        );
      case 'weekly':
        return DateTimeRange(
          start: now.subtract(Duration(days: now.weekday - 1)),
          end: now.add(Duration(days: 7 - now.weekday)),
        );
      case 'monthly':
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case 'custom':
        return DateTimeRange(
          start: DateTime(_customStartDate.year, _customStartDate.month, _customStartDate.day),
          end: DateTime(_customEndDate.year, _customEndDate.month, _customEndDate.day, 23, 59, 59),
        );
      default:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
    }
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    final range = _getDateRange();

    final salesReport = await _reportRepository.getSalesReport(startDate: range.start, endDate: range.end);
    final profitReport = await _reportRepository.getProfitReport(startDate: range.start, endDate: range.end);
    final expensesReport = await _reportRepository.getExpensesReport(startDate: range.start, endDate: range.end);
    final cashboxReport = await _reportRepository.getCashboxReport();
    final inventoryReport = await _reportRepository.getInventoryReport();
    final walletsReport = await _reportRepository.getWalletsReport();

    if (mounted) {
      setState(() {
        _reportData = {
          'range': range,
          'sales': salesReport,
          'profit': profitReport,
          'expenses': expensesReport,
          'cashbox': cashboxReport,
          'inventory': inventoryReport,
          'wallets': walletsReport,
        };
        _isLoading = false;
      });
    }
  }

  Future<void> _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _customStartDate, end: _customEndDate),
    );
    if (picked != null && mounted) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _period = 'custom';
      });
      _loadReport();
    }
  }

  String _getPeriodLabel() {
    switch (_period) {
      case 'daily':
        return _tr('اليوم', 'Today');
      case 'yesterday':
        return _tr('أمس', 'Yesterday');
      case 'weekly':
        return _tr('هذا الأسبوع', 'This Week');
      case 'monthly':
        return _tr('هذا الشهر', 'This Month');
      case 'custom':
        return _tr('فترة مخصصة', 'Custom Period');
      default:
        return _tr('اليوم', 'Today');
    }
  }

  String _getReportTypeLabel() {
    switch (_reportType) {
      case 'comprehensive':
        return _tr('التقرير الشامل', 'Comprehensive Report');
      case 'sales':
        return _tr('المبيعات', 'Sales');
      case 'profit':
        return _tr('الأرباح', 'Profits');
      case 'expenses':
        return _tr('المصروفات', 'Expenses');
      case 'cashbox':
        return _tr('الصندوق', 'Cashbox');
      case 'wallets':
        return _tr('المحافظ', 'Wallets');
      case 'inventory':
        return _tr('المخزون', 'Inventory');
      default:
        return _tr('التقرير الشامل', 'Comprehensive Report');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(_tr('التقارير', 'Reports'))),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : RefreshIndicator(
        onRefresh: _loadReport,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPeriodSection(context),
              const SizedBox(height: 16),
              _buildReportTypeSection(context),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isGeneratingPdf ? null : _generatePdf,
                icon: _isGeneratingPdf
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf),
                label: Text(_isGeneratingPdf ? _tr('جاري الإنشاء...', 'Generating...') : _tr('تصدير PDF', 'Export PDF')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getReportTypeLabel(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
              Text(
                _getPeriodLabel(),
                style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ..._buildReportContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_tr('الفترة الزمنية', 'Time Period'), style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPeriodChip(context, 'daily', _tr('اليوم', 'Today')),
              _buildPeriodChip(context, 'yesterday', _tr('أمس', 'Yesterday')),
              _buildPeriodChip(context, 'weekly', _tr('الأسبوع', 'Week')),
              _buildPeriodChip(context, 'monthly', _tr('الشهر', 'Month')),
              _buildPeriodChip(context, 'custom', _tr('مخصص', 'Custom')),
            ],
          ),
          if (_period == 'custom') ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickCustomDateRange,
              icon: const Icon(Icons.date_range, size: 18),
              label: Text(
                '${_customStartDate.day}/${_customStartDate.month}/${_customStartDate.year} - ${_customEndDate.day}/${_customEndDate.month}/${_customEndDate.year}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodChip(BuildContext context, String value, String label) {
    final isSelected = _period == value;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        if (value == 'custom') {
          _pickCustomDateRange();
        } else {
          setState(() => _period = value);
          _loadReport();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypeSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_tr('نوع التقرير', 'Report Type'), style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip(context, 'comprehensive', _tr('شامل', 'Comprehensive'), Icons.dashboard),
              _buildTypeChip(context, 'sales', _tr('المبيعات', 'Sales'), Icons.trending_up),
              _buildTypeChip(context, 'profit', _tr('الأرباح', 'Profits'), Icons.savings),
              _buildTypeChip(context, 'expenses', _tr('المصروفات', 'Expenses'), Icons.money_off),
              _buildTypeChip(context, 'cashbox', _tr('الصندوق', 'Cashbox'), Icons.account_balance_wallet),
              _buildTypeChip(context, 'wallets', _tr('المحافظ', 'Wallets'), Icons.wallet),
              _buildTypeChip(context, 'inventory', _tr('المخزون', 'Inventory'), Icons.inventory),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, String value, String label, IconData icon) {
    final isSelected = _reportType == value;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => setState(() => _reportType = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : colorScheme.onSurface),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: isSelected ? Colors.white : colorScheme.onSurface, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildReportContent(BuildContext context) {
    final data = _reportData!;
    final sales = data['sales'] as Map<String, dynamic>;
    final profit = data['profit'] as Map<String, dynamic>;
    final expenses = data['expenses'] as Map<String, dynamic>;
    final cashbox = data['cashbox'] as Map<String, dynamic>;
    final wallets = data['wallets'] as Map<String, dynamic>;
    final inventory = data['inventory'] as Map<String, dynamic>;

    switch (_reportType) {
      case 'comprehensive':
        return [
          _buildStatCard(context, _tr('إجمالي المبيعات', 'Total Sales'), sales['total_sales'] ?? 0, Icons.trending_up, const Color(0xFF4CAF50)),
          _buildStatCard(context, _tr('صافي الأرباح', 'Net Profit'), profit['net_profit'] ?? 0, Icons.savings, const Color(0xFF2E7D32)),
          _buildStatCard(context, _tr('المصروفات', 'Expenses'), expenses['total_expenses'] ?? 0, Icons.money_off, const Color(0xFFF44336)),
          _buildStatCard(context, _tr('رصيد الصندوق', 'Cashbox Balance'), cashbox['current_balance'] ?? 0, Icons.account_balance_wallet, const Color(0xFFFF9800)),
          _buildStatCard(context, _tr('رصيد المحافظ', 'Wallet Balance'), wallets['total_wallet_balance'] ?? 0, Icons.wallet, const Color(0xFF2196F3)),
          _buildStatCard(context, _tr('قيمة المخزون', 'Inventory Value'), inventory['inventory_value'] ?? 0, Icons.inventory, const Color(0xFF9C27B0)),
        ];
      case 'sales':
        return [
          _buildStatCard(context, _tr('إجمالي المبيعات', 'Total Sales'), sales['total_sales'] ?? 0, Icons.trending_up, const Color(0xFF4CAF50)),
          _buildStatCard(context, _tr('عدد الفواتير', 'Invoice Count'), (sales['invoice_count'] ?? 0).toDouble(), Icons.receipt, const Color(0xFF2196F3)),
          _buildStatCard(context, _tr('مبيعات نقدية', 'Cash Sales'), sales['cash_total'] ?? 0, Icons.money, const Color(0xFF4CAF50)),
          _buildStatCard(context, _tr('مبيعات محافظ', 'Wallet Sales'), sales['wallet_total'] ?? 0, Icons.wallet, const Color(0xFF2196F3)),
        ];
      case 'profit':
        return [
          _buildStatCard(context, _tr('إجمالي الربح', 'Total Profit'), profit['total_profit'] ?? 0, Icons.savings, const Color(0xFF4CAF50)),
          _buildStatCard(context, _tr('المصروفات', 'Expenses'), profit['total_expenses'] ?? 0, Icons.money_off, const Color(0xFFF44336)),
          _buildStatCard(context, _tr('صافي الربح', 'Net Profit'), profit['net_profit'] ?? 0, Icons.trending_up, const Color(0xFF2E7D32)),
        ];
      case 'expenses':
        return [
          _buildStatCard(context, _tr('إجمالي المصروفات', 'Total Expenses'), expenses['total_expenses'] ?? 0, Icons.money_off, const Color(0xFFF44336)),
          _buildStatCard(context, _tr('عدد المصروفات', 'Expense Count'), (expenses['expense_count'] ?? 0).toDouble(), Icons.receipt, const Color(0xFFFF9800)),
        ];
      case 'cashbox':
        return [
          _buildStatCard(context, _tr('الرصيد الحالي', 'Current Balance'), cashbox['current_balance'] ?? 0, Icons.account_balance_wallet, const Color(0xFF2E7D32)),
          _buildStatCard(context, _tr('الإيداعات', 'Deposits'), cashbox['total_deposits'] ?? 0, Icons.arrow_downward, const Color(0xFF4CAF50)),
          _buildStatCard(context, _tr('السحوبات', 'Withdrawals'), cashbox['total_withdrawals'] ?? 0, Icons.arrow_upward, const Color(0xFFF44336)),
        ];
      case 'wallets':
        return [
          _buildStatCard(context, _tr('رصيد المحافظ', 'Wallet Balance'), wallets['total_wallet_balance'] ?? 0, Icons.wallet, const Color(0xFF2196F3)),
          _buildStatCard(context, _tr('عدد المحافظ', 'Wallet Count'), (wallets['wallet_count'] ?? 0).toDouble(), Icons.wallet, const Color(0xFF9C27B0)),
        ];
      case 'inventory':
        return [
          _buildStatCard(context, _tr('عدد المنتجات', 'Product Count'), (inventory['product_count'] ?? 0).toDouble(), Icons.inventory, const Color(0xFF2196F3)),
          _buildStatCard(context, _tr('قيمة المخزون', 'Inventory Value'), inventory['inventory_value'] ?? 0, Icons.inventory, const Color(0xFF2E7D32)),
          _buildStatCard(context, _tr('منخفض', 'Low'), (inventory['low_stock_count'] ?? 0).toDouble(), Icons.warning, const Color(0xFFFF9800)),
          _buildStatCard(context, _tr('نافذ', 'Out'), (inventory['out_of_stock_count'] ?? 0).toDouble(), Icons.error, const Color(0xFFF44336)),
        ];
      default:
        return [];
    }
  }

  Widget _buildStatCard(BuildContext context, String label, double value, IconData icon, Color accentColor) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('${value.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== PDF Generation مع الخط العربي =====
  Future<void> _generatePdf() async {
    setState(() => _isGeneratingPdf = true);

    try {
      final data = _reportData!;
      final range = data['range'] as DateTimeRange;
      final sales = data['sales'] as Map<String, dynamic>;
      final profit = data['profit'] as Map<String, dynamic>;
      final expenses = data['expenses'] as Map<String, dynamic>;
      final cashbox = data['cashbox'] as Map<String, dynamic>;
      final wallets = data['wallets'] as Map<String, dynamic>;
      final inventory = data['inventory'] as Map<String, dynamic>;

      final isArabic = AppLocalizations.of(context).isArabic;

      final fontData = await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf');
      final fontDataBold = await rootBundle.load('assets/fonts/NotoNaskhArabic-SemiBold.ttf');

      final arabicFont = pw.Font.ttf(fontData);
      final arabicFontBold = pw.Font.ttf(fontDataBold);

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
          build: (context) => [
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.green700,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    _tr('بيت الطفل', 'Toy Store'),
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.white, font: arabicFontBold),
                  ),
                  pw.Text(
                    _getReportTypeLabel(),
                    style: pw.TextStyle(fontSize: 16, color: PdfColors.white, font: arabicFont),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text('${_tr('الفترة', 'Period')}: ${_getPeriodLabel()}', style: pw.TextStyle(font: arabicFont, fontSize: 12)),
            pw.Text(
              '${_tr('من', 'From')}: ${range.start.day}/${range.start.month}/${range.start.year}  ${_tr('إلى', 'To')}: ${range.end.day}/${range.end.month}/${range.end.year}',
              style: pw.TextStyle(font: arabicFont, fontSize: 12),
            ),
            pw.Text(
              '${_tr('تاريخ الإنشاء', 'Generated')}: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}',
              style: pw.TextStyle(font: arabicFont, fontSize: 12),
            ),
            pw.Divider(),
            pw.SizedBox(height: 16),
            pw.Text(
              _tr('الملخص المالي', 'Financial Summary'),
              style: pw.TextStyle(font: arabicFontBold, fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: [_tr('البند', 'Item'), _tr('القيمة', 'Value')],
              data: [
                [_tr('إجمالي المبيعات', 'Total Sales'), '${sales['total_sales']}'],
                [_tr('إجمالي المصروفات', 'Total Expenses'), '${expenses['total_expenses']}'],
                [_tr('صافي الربح', 'Net Profit'), '${profit['net_profit']}'],
                [_tr('رصيد الصندوق', 'Cashbox Balance'), '${cashbox['current_balance']}'],
                [_tr('رصيد المحافظ', 'Wallet Balance'), '${wallets['total_wallet_balance']}'],
                [_tr('قيمة المخزون', 'Inventory Value'), '${inventory['inventory_value']}'],
              ],
              headerStyle: pw.TextStyle(font: arabicFontBold, fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              cellStyle: pw.TextStyle(font: arabicFont, fontSize: 11),
              headerDecoration: pw.BoxDecoration(color: PdfColors.green700),
              cellAlignment: pw.Alignment.centerRight,
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              _tr('نهاية التقرير', 'End of Report'),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: arabicFont, fontSize: 10, color: PdfColors.grey),
            ),
          ],
          footer: (context) => pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              '${_tr('صفحة', 'Page')} ${context.pageNumber}/${context.pagesCount}',
              style: pw.TextStyle(font: arabicFont, fontSize: 9, color: PdfColors.grey),
            ),
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr('فشل إنشاء التقرير', 'Failed to generate report')),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }
}