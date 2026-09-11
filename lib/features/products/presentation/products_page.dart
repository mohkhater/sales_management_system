import 'package:flutter/material.dart';

import '../data/product_model.dart';
import '../data/product_repository.dart';
import 'product_form_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductRepository _repository = ProductRepository();

  List<Product> _products = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _repository.getAll();

      if (!mounted) {
        return;
      }

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل المنتجات.';
      });
    }
  }

  Future<void> _openAddProduct() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const ProductFormPage(),
      ),
    );

    if (saved == true) {
      await _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
        actions: [
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                onPressed: _openAddProduct,
                icon: const Icon(Icons.add),
                label: const Text('إضافة منتج'),
              ),
            )
          else
            IconButton(
              onPressed: _openAddProduct,
              icon: const Icon(Icons.add),
              tooltip: 'إضافة منتج',
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 12),
        child: Column(
          children: [
            _SearchBar(isDesktop: isDesktop),
            const SizedBox(height: 16),
            Expanded(
              child: _buildProductsContent(isDesktop),
            ),
          ],
        ),
      ),
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton.extended(
              onPressed: _openAddProduct,
              icon: const Icon(Icons.add),
              label: const Text('إضافة منتج'),
            ),
    );
  }

  Widget _buildProductsContent(bool isDesktop) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text('لا توجد منتجات حاليًا.'),
      );
    }

    return _ProductsList(
      products: _products,
      isDesktop: isDesktop,
    );
  }
}

class _SearchBar extends StatelessWidget {
  final bool isDesktop;

  const _SearchBar({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'ابحث عن منتج أو باركود...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune),
          tooltip: 'تصفية',
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _ProductsList extends StatelessWidget {
  final List<Product> products;
  final bool isDesktop;

  const _ProductsList({
    required this.products,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: ListView.separated(
          itemCount: products.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final product = products[index];

            return ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(product.name),
              subtitle: Text(
                'الوحدة الأساسية: ${product.baseUnitId}',
              ),
              trailing: SizedBox(
                width: 180,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${product.defaultPrice.toStringAsFixed(2)} ₪',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'تعديل',
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'حذف',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final product = products[index];

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text(product.name),
            subtitle: Text(
              '${product.baseUnitId} • '
              '${product.defaultPrice.toStringAsFixed(2)} ₪',
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {},
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('تعديل'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('حذف'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}