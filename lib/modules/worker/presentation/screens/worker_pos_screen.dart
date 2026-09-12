import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../manager/data/models/user_model.dart';
import '../../../manager/data/models/product_model.dart';
import '../../../manager/data/models/sale_model.dart';
import '../../../manager/data/models/sale_item_model.dart';
import '../../../manager/data/models/wallet_model.dart';
import '../../../manager/data/repositories/product_repository.dart';
import '../../../manager/data/repositories/sale_repository.dart';
import '../../../manager/data/repositories/wallet_repository.dart';
import '../../../manager/data/repositories/settings_repository.dart';
import 'package:flutter/services.dart' show rootBundle;





class WorkerPosScreen extends StatefulWidget {
  final UserModel user;

  const WorkerPosScreen({super.key, required this.user});

  @override
  State<WorkerPosScreen> createState() => _WorkerPosScreenState();
}

class _WorkerPosScreenState extends State<WorkerPosScreen> {
  final ProductRepository _productRepository = ProductRepository(DatabaseHelper.instance);
  final SaleRepository _saleRepository = SaleRepository(DatabaseHelper.instance);
  final WalletRepository _walletRepository = WalletRepository(DatabaseHelper.instance);
  final SettingsRepository _settingsRepository = SettingsRepository(DatabaseHelper.instance);

  final List<CartItem> _cartItems = [];
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  List<WalletModel> _wallets = [];
  String _currentInvoiceNumber = '';
  String _paymentMethod = 'cash';
  int? _selectedWalletId;
  bool _isLoading = true;
  bool _allowPriceOverride = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final products = await _productRepository.getAllProducts();
    final wallets = await _walletRepository.getAllWallets();
    final invoiceNumber = await _saleRepository.generateInvoiceNumber();
    final settings = await _settingsRepository.getAllSettings();
    final allowPriceOverride = settings['allow_price_override'] == 'true';

    if (mounted) {
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _wallets = wallets;
        _currentInvoiceNumber = invoiceNumber;
        _allowPriceOverride = allowPriceOverride;
        _isLoading = false;
      });
    }
  }

  Future<void> _newSale() async {
    final invoiceNumber = await _saleRepository.generateInvoiceNumber();
    setState(() {
      _cartItems.clear();
      _paymentMethod = 'cash';
      _selectedWalletId = null;
      _currentInvoiceNumber = invoiceNumber;
    });
  }

  void _searchProducts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredProducts = _allProducts);
    } else {
      final filtered = _allProducts.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
            (product.sku?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (product.barcode?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
      setState(() => _filteredProducts = filtered);
    }
  }

  void _addToCart(ProductModel product) {
    final index = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      if (_cartItems[index].quantity < product.quantity) {
        setState(() => _cartItems[index].quantity++);
      } else {
        _showMessage(_tr('الكمية غير متوفرة', 'Quantity not available'));
      }
    } else {
      if (product.quantity > 0) {
        setState(() => _cartItems.add(CartItem(product: product, salePrice: product.salePrice)));
      } else {
        _showMessage(_tr('المنتج غير متوفر', 'Product not available'));
      }
    }
  }

  void _removeFromCart(int productId) {
    setState(() => _cartItems.removeWhere((item) => item.product.id == productId));
  }

  void _incrementQuantity(int productId) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (_cartItems[index].quantity < _cartItems[index].product.quantity) {
        setState(() => _cartItems[index].quantity++);
      } else {
        _showMessage(_tr('الكمية غير متوفرة', 'Quantity not available'));
      }
    }
  }

  void _decrementQuantity(int productId) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (_cartItems[index].quantity > 1) {
        setState(() => _cartItems[index].quantity--);
      } else {
        setState(() => _cartItems.removeAt(index));
      }
    }
  }

  void _updateSalePrice(int productId, double newPrice) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1 && newPrice > 0) {
      setState(() => _cartItems[index].salePrice = newPrice);
    }
  }

  double get _totalAmount {
    double total = 0;
    for (var item in _cartItems) {
      total += item.totalPrice;
    }
    return total;
  }

  int get _totalItems {
    int count = 0;
    for (var item in _cartItems) {
      count += item.quantity;
    }
    return count;
  }

  String _tr(String ar, String en) {
    return AppLocalizations.of(context).isArabic ? ar : en;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

// ===== فتح السلة =====
  void _openCartSheet() {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ===== Drag Handle =====
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ===== Header ثابت =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.shopping_cart, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.cart,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$_totalItems',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // ===== قائمة المنتجات - قابلة للتمرير =====
                  Expanded(
                    child: _cartItems.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 48,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.emptyCart,
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return _buildCartItem(sheetContext, item, setSheetState);
                      },
                    ),
                  ),
                  const Divider(),
                  // ===== منطقة الدفع والإجمالي ثابتة =====
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // طريقة الدفع
                        Row(
                          children: [
                            Text(
                              '${l10n.paymentMethod}:',
                              style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SegmentedButton<String>(
                                segments: [
                                  ButtonSegment(
                                    value: 'cash',
                                    label: Text(l10n.cash, style: const TextStyle(fontSize: 12)),
                                    icon: const Icon(Icons.money, size: 16),
                                  ),
                                  ButtonSegment(
                                    value: 'wallet',
                                    label: Text(l10n.wallet, style: const TextStyle(fontSize: 12)),
                                    icon: const Icon(Icons.wallet, size: 16),
                                  ),
                                ],
                                selected: {_paymentMethod},
                                onSelectionChanged: (value) {
                                  setState(() => _paymentMethod = value.first);
                                  setSheetState(() {});
                                },
                                style: ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_paymentMethod == 'wallet') ...[
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue: _selectedWalletId,
                            decoration: InputDecoration(
                              labelText: l10n.selectWallet,
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: _wallets.map((wallet) {
                              return DropdownMenuItem(
                                value: wallet.id,
                                child: Text('${wallet.name} (${wallet.currentBalance})', style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedWalletId = value);
                            },
                          ),
                        ],
                        const SizedBox(height: 8),
                        // الإجمالي + زر التأكيد
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.total,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '$_totalAmount',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _cartItems.isEmpty
                                  ? null
                                  : () {
                                Navigator.of(sheetContext).pop();
                                _showCheckoutDialog();
                              },
                              icon: const Icon(Icons.check, size: 18),
                              label: Text(l10n.confirmSale, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildCartItem(BuildContext context, CartItem item, StateSetter setSheetState) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${l10n.purchasePrice}: ${item.product.purchasePrice}',
                  style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                ),
                if (_allowPriceOverride)
                  SizedBox(
                    width: 80,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.salePrice,
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                      onChanged: (value) {
                        final newPrice = double.tryParse(value);
                        if (newPrice != null && newPrice > 0) {
                          _updateSalePrice(item.product.id!, newPrice);
                          setSheetState(() {});
                        }
                      },
                    ),
                  )
                else
                  Text(
                    '${l10n.salePrice}: ${item.salePrice}',
                    style: TextStyle(fontSize: 11, color: colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  _incrementQuantity(item.product.id!);
                  setSheetState(() {});
                },
                icon: const Icon(Icons.add_circle, color: Color(0xFF4CAF50), size: 28),
                visualDensity: VisualDensity.compact,
              ),
              Text(
                '${item.quantity}',
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
              IconButton(
                onPressed: () {
                  _decrementQuantity(item.product.id!);
                  setSheetState(() {});
                },
                icon: const Icon(Icons.remove_circle, color: Color(0xFFF44336), size: 28),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              _removeFromCart(item.product.id!);
              setSheetState(() {});
            },
            icon: const Icon(Icons.delete_outline, color: Color(0xFFF44336), size: 22),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  // ===== Checkout Dialog =====
  Future<void> _showCheckoutDialog() async {
    if (_cartItems.isEmpty) return;

    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.shopping_cart_checkout, color: colorScheme.primary, size: 50),
            const SizedBox(height: 10),
            Text(l10n.confirmSale, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(dialogContext, l10n.invoiceCount, _currentInvoiceNumber),
            const SizedBox(height: 8),
            _buildInfoRow(dialogContext, l10n.cart, '$_totalItems'),
            const SizedBox(height: 8),
            _buildInfoRow(dialogContext, l10n.total, '$_totalAmount'),
            const SizedBox(height: 8),
            _buildInfoRow(
              dialogContext,
              l10n.paymentMethod,
              _paymentMethod == 'cash' ? l10n.cash : l10n.wallet,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () {
              Navigator.pop(dialogContext);
              _completeSale();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isProcessing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
      ],
    );
  }

  // ===== تنفيذ البيع =====
  Future<void> _completeSale() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final sale = SaleModel(
      uuid: '',
      invoiceNumber: _currentInvoiceNumber,
      saleDate: DateTime.now(),
      subtotal: _totalAmount,
      totalAmount: _totalAmount,
      paymentMethod: _paymentMethod,
      soldBy: widget.user.id!,
    );

    final saleItems = _cartItems.map((item) {
      return SaleItemModel(
        uuid: '',
        saleId: 0,
        productId: item.product.id!,
        quantity: item.quantity,
        unitPrice: item.salePrice,
        purchasePriceAtSale: item.product.purchasePrice,
        totalPrice: item.totalPrice,
        profitAmount: item.profit,
      );
    }).toList();

    final saleId = await _saleRepository.createSale(sale: sale, saleItems: saleItems);

    if (mounted) {
      setState(() => _isProcessing = false);
    }

    if (saleId > 0) {
      final completedItems = List<CartItem>.from(_cartItems);
      final completedSale = SaleModel(
        uuid: '',
        invoiceNumber: _currentInvoiceNumber,
        saleDate: DateTime.now(),
        totalAmount: _totalAmount,
        paymentMethod: _paymentMethod,
        soldBy: widget.user.id!,
      );
      setState(() => _cartItems.clear());
      _showInvoiceDialog(completedSale, completedItems);
    } else {
      _showMessage(_tr('فشل إتمام البيع', 'Sale failed'));
    }
  }

  // ===== Invoice Dialog =====
  void _showInvoiceDialog(SaleModel sale, List<CartItem> items) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 60),
            const SizedBox(height: 10),
            Text(l10n.saleSuccess, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  sale.invoiceNumber,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
              ),
              const Divider(),
              ...items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item.product.name, style: TextStyle(color: colorScheme.onSurface)),
                      ),
                      Text(
                        '${item.quantity} × ${item.salePrice} = ${item.totalPrice}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(),
              _buildInfoRow(dialogContext, l10n.total, '${sale.totalAmount}'),
              _buildInfoRow(dialogContext, l10n.paymentMethod, sale.paymentMethod == 'cash' ? l10n.cash : l10n.wallet),
              _buildInfoRow(dialogContext, l10n.username, widget.user.fullName),
            ],
          ),
        ),
        actions: [
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _printInvoice(dialogContext, sale, items),
                      icon: const Icon(Icons.print, size: 18),
                      label: Text(l10n.printInvoice),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareInvoicePdf(sale, items),
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: Text(l10n.sharePdf),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _newSale();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.newSale),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// ===== طباعة الفاتورة - تصميم احترافي مع خط عربي =====
  Future<void> _printInvoice(BuildContext dialogContext, SaleModel sale, List<CartItem> items) async {
    final isArabic = AppLocalizations.of(context).isArabic;

    // تحميل الخطوط العربية
    final fontDataRegular = await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf');
    final fontDataBold = await rootBundle.load('assets/fonts/NotoNaskhArabic-SemiBold.ttf');

    final regularFont = pw.Font.ttf(fontDataRegular);
    final boldFont = pw.Font.ttf(fontDataBold);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          // ===== Header =====
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
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                ),
                pw.Text(
                  _tr('فاتورة بيع', 'Sale Invoice'),
                  style: pw.TextStyle(fontSize: 16, color: PdfColors.white),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          // ===== معلومات الفاتورة =====
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${_tr('رقم الفاتورة', 'Invoice No')}: ${sale.invoiceNumber}', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('${_tr('التاريخ', 'Date')}: ${sale.saleDate.year}/${sale.saleDate.month}/${sale.saleDate.day} ${sale.saleDate.hour}:${sale.saleDate.minute.toString().padLeft(2, '0')}', style: pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 4),
                pw.Text('${_tr('العامل', 'Worker')}: ${widget.user.fullName}', style: pw.TextStyle(fontSize: 11)),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          // ===== جدول المنتجات =====
          pw.Table.fromTextArray(
            headers: [_tr('المنتج', 'Product'), _tr('الكمية', 'Qty'), _tr('السعر', 'Price'), _tr('الإجمالي', 'Total')],
            data: items.map((item) => [
              item.product.name,
              '${item.quantity}',
              '${item.salePrice}',
              '${item.totalPrice}',
            ]).toList(),
            headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            cellStyle: pw.TextStyle(fontSize: 11),
            headerDecoration: pw.BoxDecoration(color: PdfColors.green700),
            cellAlignment: pw.Alignment.centerRight,
            border: pw.TableBorder.all(color: PdfColors.grey300),
          ),
          pw.SizedBox(height: 16),
          // ===== الإجمالي =====
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.green100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(_tr('الإجمالي', 'Total'), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('${sale.totalAmount}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('${_tr('طريقة الدفع', 'Payment Method')}: ${sale.paymentMethod == 'cash' ? _tr('نقداً', 'Cash') : _tr('محفظة', 'Wallet')}', style: pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.SizedBox(height: 8),
          // ===== Footer =====
          pw.Center(
            child: pw.Text(
              _tr('شكراً لتعاملكم معنا', 'Thank you for your business'),
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              '${_tr('بيت الطفل للألعاب', 'Toy Store')} - ${_tr('صنعاء، اليمن', 'Sana\'a, Yemen')}',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
            ),
          ),
        ],
        footer: (context) => pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            '${_tr('صفحة', 'Page')} ${context.pageNumber}/${context.pagesCount}',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
          ),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
  // ===== مشاركة الفاتورة PDF =====
  Future<void> _shareInvoicePdf(SaleModel sale, List<CartItem> items) async {
    final isArabic = AppLocalizations.of(context).isArabic;

    final fontDataRegular = await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf');
    final fontDataBold = await rootBundle.load('assets/fonts/NotoNaskhArabic-SemiBold.ttf');

    final regularFont = pw.Font.ttf(fontDataRegular);
    final boldFont = pw.Font.ttf(fontDataBold);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        margin: const pw.EdgeInsets.all(20),
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
                pw.Text(_tr('بيت الطفل', 'Toy Store'), style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                pw.Text(_tr('فاتورة بيع', 'Sale Invoice'), style: pw.TextStyle(fontSize: 16, color: PdfColors.white)),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${_tr('رقم الفاتورة', 'Invoice No')}: ${sale.invoiceNumber}', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('${_tr('التاريخ', 'Date')}: ${sale.saleDate.year}/${sale.saleDate.month}/${sale.saleDate.day} ${sale.saleDate.hour}:${sale.saleDate.minute.toString().padLeft(2, '0')}', style: pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 4),
                pw.Text('${_tr('العامل', 'Worker')}: ${widget.user.fullName}', style: pw.TextStyle(fontSize: 11)),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: [_tr('المنتج', 'Product'), _tr('الكمية', 'Qty'), _tr('السعر', 'Price'), _tr('الإجمالي', 'Total')],
            data: items.map((item) => [
              item.product.name,
              '${item.quantity}',
              '${item.salePrice}',
              '${item.totalPrice}',
            ]).toList(),
            headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            cellStyle: pw.TextStyle(fontSize: 11),
            headerDecoration: pw.BoxDecoration(color: PdfColors.green700),
            cellAlignment: pw.Alignment.centerRight,
            border: pw.TableBorder.all(color: PdfColors.grey300),
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.green100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(_tr('الإجمالي', 'Total'), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('${sale.totalAmount}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('${_tr('طريقة الدفع', 'Payment Method')}: ${sale.paymentMethod == 'cash' ? _tr('نقداً', 'Cash') : _tr('محفظة', 'Wallet')}', style: pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              _tr('شكراً لتعاملكم معنا', 'Thank you for your business'),
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              '${_tr('بيت الطفل للألعاب', 'Toy Store')} - ${_tr('صنعاء، اليمن', 'Sana\'a, Yemen')}',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
            ),
          ),
        ],
        footer: (context) => pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            '${_tr('صفحة', 'Page')} ${context.pageNumber}/${context.pagesCount}',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
          ),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
  // ===== Build =====
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pointOfSale),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currentInvoiceNumber,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              onChanged: _searchProducts,
              decoration: InputDecoration(
                hintText: l10n.searchProduct,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true,
                fillColor: colorScheme.surface,
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(child: Text(l10n.noProducts, style: TextStyle(color: colorScheme.onSurfaceVariant)))
                : GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return _buildProductCard(context, product);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2))),
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_cart, color: colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text('$_totalItems ${l10n.cart}', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                const Spacer(),
                Text('${l10n.total}: $_totalAmount', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _cartItems.isEmpty ? null : _openCartSheet,
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(l10n.completeSale),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: () => _addToCart(product),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (product.quantity > 0 ? colorScheme.primary : colorScheme.error).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.toys,
                    size: 24,
                    color: product.quantity > 0 ? colorScheme.primary : colorScheme.error,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${l10n.available}: ${product.quantity}',
              style: TextStyle(fontSize: 10, color: product.quantity > 0 ? colorScheme.onSurfaceVariant : colorScheme.error),
            ),
            const SizedBox(height: 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.purchasePrice}: ${product.purchasePrice}',
                  style: TextStyle(fontSize: 9, color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${l10n.salePrice}: ${product.salePrice}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem {
  final ProductModel product;
  int quantity;
  double salePrice;

  CartItem({required this.product, this.quantity = 1, required this.salePrice});

  double get totalPrice => salePrice * quantity;
  double get profit => (salePrice - product.purchasePrice) * quantity;
}