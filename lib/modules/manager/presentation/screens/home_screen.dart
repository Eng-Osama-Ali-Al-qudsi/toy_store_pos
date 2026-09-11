import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/report_repository.dart';
import 'expenses_screen.dart';
import 'cashbox_screen.dart';
import 'wallets_screen.dart';
import 'users_screen.dart';
import 'reports_screen.dart';
import 'attendance_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ReportRepository _reportRepository = ReportRepository(DatabaseHelper.instance);

  Map<String, dynamic>? _salesReport;
  Map<String, dynamic>? _profitReport;
  Map<String, dynamic>? _cashboxReport;
  Map<String, dynamic>? _inventoryReport;
  Map<String, dynamic>? _walletsReport;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final salesReport = await _reportRepository.getSalesReport(startDate: startOfDay, endDate: endOfDay);
    final profitReport = await _reportRepository.getProfitReport(startDate: startOfDay, endDate: endOfDay);
    final cashboxReport = await _reportRepository.getCashboxReport();
    final inventoryReport = await _reportRepository.getInventoryReport();
    final walletsReport = await _reportRepository.getWalletsReport();

    setState(() {
      _salesReport = salesReport;
      _profitReport = profitReport;
      _cashboxReport = cashboxReport;
      _inventoryReport = inventoryReport;
      _walletsReport = walletsReport;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.welcome} ${widget.user.fullName} 👋'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSummarySection(context),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              _buildAlertsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.todaySummary,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(context, l10n.todaySales, _salesReport?['total_sales'] ?? 0, Icons.trending_up, const Color(0xFF4CAF50)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(context, l10n.profits, _profitReport?['net_profit'] ?? 0, Icons.savings, const Color(0xFF2E7D32)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(context, l10n.cashboxBalance, _cashboxReport?['current_balance'] ?? 0, Icons.account_balance_wallet, const Color(0xFFFF9800)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(context, l10n.invoiceCount, (_salesReport?['invoice_count'] ?? 0).toDouble(), Icons.receipt, const Color(0xFF2196F3)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(context, l10n.walletBalance, _walletsReport?['total_wallet_balance'] ?? 0, Icons.wallet, const Color(0xFF9C27B0)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(context, l10n.inventoryValue, _inventoryReport?['inventory_value'] ?? 0, Icons.inventory, const Color(0xFF009688)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String label,
      double value,
      IconData icon,
      Color accentColor,
      ) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${value.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final actions = [
      (l10n.expenses, Icons.money_off, const Color(0xFFF44336), ExpensesScreen(user: widget.user)),
      (l10n.cashbox, Icons.savings, const Color(0xFFFF9800), CashboxScreen(user: widget.user)),
      (l10n.wallets, Icons.wallet, const Color(0xFF9C27B0), WalletsScreen(user: widget.user)),
      (l10n.users, Icons.people, const Color(0xFF009688), UsersScreen(user: widget.user)),
      (l10n.reports, Icons.bar_chart, const Color(0xFF3F51B5), ReportsScreen(user: widget.user)),
      (l10n.attendance, Icons.access_time, const Color(0xFF795548), AttendanceScreen(user: widget.user)),
      (l10n.settings, Icons.settings, const Color(0xFF607D8B), SettingsScreen(user: widget.user)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.quickActions,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
          children: actions.map((action) {
            return InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => action.$4));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(action.$2, color: action.$3, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      action.$1,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAlertsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final lowStockCount = _inventoryReport?['low_stock_count'] ?? 0;
    final outOfStockCount = _inventoryReport?['out_of_stock_count'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.alerts,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
        if (lowStockCount > 0)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF9800)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Color(0xFFFF9800)),
                const SizedBox(width: 8),
                Text('$lowStockCount ${l10n.lowStockAlerts}', style: TextStyle(color: colorScheme.onSurface)),
              ],
            ),
          ),
        if (outOfStockCount > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF44336).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF44336)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Color(0xFFF44336)),
                const SizedBox(width: 8),
                Text('$outOfStockCount ${l10n.outOfStockAlerts}', style: TextStyle(color: colorScheme.onSurface)),
              ],
            ),
          ),
        ],
        if (lowStockCount == 0 && outOfStockCount == 0)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4CAF50)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                Text(l10n.allProductsAvailable, style: TextStyle(color: colorScheme.onSurface)),
              ],
            ),
          ),
      ],
    );
  }
}