import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/models/user_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductsScreen extends StatefulWidget {
  final UserModel user;

  const ProductsScreen({super.key, required this.user});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductRepository _productRepository = ProductRepository(DatabaseHelper.instance);

  List<ProductModel> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  String _tr(String ar, String en) {
    return AppLocalizations.of(context).isArabic ? ar : en;
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await _productRepository.getAllProducts();
    final categories = await _productRepository.getAllCategories();
    setState(() {
      _products = products;
      _categories = categories;
      _isLoading = false;
    });
  }

  void _searchProducts(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(
        categories: _categories,
        onSave: (product) async {
          await _productRepository.addProduct(product);
          await _loadProducts();
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_tr('تم إضافة المنتج', 'Product added')),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditProductDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(
        categories: _categories,
        product: product,
        onSave: (updatedProduct) async {
          await _productRepository.updateProduct(updatedProduct);
          await _loadProducts();
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_tr('تم تحديث المنتج', 'Product updated')),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
          }
        },
      ),
    );
  }

  void _deleteProduct(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr('حذف المنتج', 'Delete Product')),
        content: Text('${_tr('هل تريد حذف', 'Do you want to delete')} ${product.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_tr('إلغاء', 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF44336)),
            child: Text(_tr('حذف', 'Delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _productRepository.deleteProduct(product.id!);
      await _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr('تم حذف المنتج', 'Product deleted')),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    }
  }

  String _getCategoryName(int? categoryId) {
    for (var category in _categories) {
      if (category['id'] == categoryId) {
        return category['name'] as String? ?? _tr('غير محدد', 'Uncategorized');
      }
    }
    return _tr('غير محدد', 'Uncategorized');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final filteredProducts = _searchQuery.isEmpty
        ? _products
        : _products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product.sku?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_tr('المنتجات', 'Products')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddProductDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + MediaQuery.of(context).padding.bottom),
            child: TextField(
              onChanged: _searchProducts,
              decoration: InputDecoration(
                hintText: _tr('بحث عن منتج...', 'Search product...'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surface,
              ),
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
              child: Text(
                _tr('لا توجد منتجات', 'No products available'),
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return _buildProductCard(context, product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryName = _getCategoryName(product.categoryId);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: product.isLowStock
                ? const Color(0xFFF44336).withValues(alpha: 0.1)
                : const Color(0xFF2E7D32).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.toys,
            color: product.isLowStock ? const Color(0xFFF44336) : const Color(0xFF2E7D32),
          ),
        ),
        title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_tr('الصنف', 'Category')}: $categoryName', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
            if (product.sku != null) Text('SKU: ${product.sku}', style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
            Text('${_tr('الكمية', 'Quantity')}: ${product.quantity}', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
            Text(
              '${_tr('الشراء', 'Purchase')}: ${product.purchasePrice} | ${_tr('البيع', 'Sale')}: ${product.salePrice}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.primary),
            ),
            if (product.isLowStock)
              Text(
                _tr('⚠️ مخزون منخفض', '⚠️ Low stock'),
                style: const TextStyle(fontSize: 10, color: Color(0xFFF44336), fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
              onPressed: () => _showEditProductDialog(product),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFF44336)),
              onPressed: () => _deleteProduct(product),
            ),
          ],
        ),
        onTap: () => _showEditProductDialog(product),
      ),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final ProductModel? product;
  final Function(ProductModel) onSave;

  const _ProductDialog({
    required this.categories,
    this.product,
    required this.onSave,
  });

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _quantityController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();

  int? _selectedCategoryId;

  String _tr(String ar, String en) {
    return AppLocalizations.of(context).isArabic ? ar : en;
  }

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _skuController.text = widget.product!.sku ?? '';
      _quantityController.text = widget.product!.quantity.toString();
      _purchasePriceController.text = widget.product!.purchasePrice.toString();
      _salePriceController.text = widget.product!.salePrice.toString();
      _selectedCategoryId = widget.product!.categoryId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final product = ProductModel(
        id: widget.product?.id,
        uuid: widget.product?.uuid ?? '',
        name: _nameController.text,
        sku: _skuController.text.isEmpty ? null : _skuController.text,
        categoryId: _selectedCategoryId,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0,
        salePrice: double.tryParse(_salePriceController.text) ?? 0,
        createdBy: widget.product?.createdBy,
      );
      widget.onSave(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? _tr('إضافة منتج', 'Add Product') : _tr('تعديل منتج', 'Edit Product')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: _tr('اسم المنتج', 'Product Name')),
                validator: (v) => v!.isEmpty ? _tr('مطلوب', 'Required') : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _skuController,
                decoration: InputDecoration(labelText: 'SKU (${_tr('اختياري', 'optional')})'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: _selectedCategoryId,
                decoration: InputDecoration(labelText: _tr('التصنيف', 'Category')),
                items: widget.categories.map((category) {
                  return DropdownMenuItem(
                    value: category['id'] as int?,
                    child: Text(category['name'] as String? ?? ''),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategoryId = value),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: _tr('الكمية', 'Quantity')),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? _tr('مطلوب', 'Required') : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _purchasePriceController,
                decoration: InputDecoration(labelText: _tr('سعر الشراء', 'Purchase Price')),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? _tr('مطلوب', 'Required') : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _salePriceController,
                decoration: InputDecoration(labelText: _tr('سعر البيع', 'Sale Price')),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? _tr('مطلوب', 'Required') : null,
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