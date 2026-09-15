import 'package:flutter/material.dart';

import '../../units/data/unit_model.dart';
import '../../units/data/unit_repository.dart';
import '../data/product_model.dart';
import '../data/product_repository.dart';
import 'product_form_page.dart';
import 'product_units_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductRepository _productRepository = ProductRepository();
  final UnitRepository _unitRepository = UnitRepository();

  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = const [];
  List<Unit> _units = const [];

  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query == _searchQuery) {
      return;
    }

    setState(() {
      _searchQuery = query;
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _productRepository.getAll(activeOnly: true),
        _unitRepository.getAll(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _products = results[0] as List<Product>;
        _units = results[1] as List<Unit>;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل بيانات المنتجات.';
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
      await _loadData();
    }
  }

  Future<void> _openEditProduct(Product product) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProductFormPage(
          product: product,
        ),
      ),
    );

    if (saved == true) {
      await _loadData();
    }
  }

  Future<void> _openProductUnits(Product product) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductUnitsPage(product: product),
      ),
    );
  }

  Future<void> _deactivateProduct(Product product) async {
    final shouldDeactivate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعطيل المنتج'),
          content: Text(
            'هل تريد تعطيل المنتج «${product.name}»؟\n\n'
            'لن يتم حذف بياناته من قاعدة البيانات.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('تعطيل'),
            ),
          ],
        );
      },
    );

    if (shouldDeactivate != true) {
      return;
    }

    try {
      await _productRepository.deactivate(product.id);

      if (!mounted) {
        return;
      }

      await _loadData();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تعطيل المنتج بنجاح.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تعطيل المنتج.'),
        ),
      );
    }
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) {
      return _products;
    }

    final query = _searchQuery.toLowerCase();

    return _products
        .where(
          (product) => product.name.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  String _unitName(String unitId) {
    for (final unit in _units) {
      if (unit.id == unitId) {
        return unit.symbol == null || unit.symbol!.isEmpty
            ? unit.name
            : '${unit.name} (${unit.symbol})';
      }
    }

    return 'وحدة غير معروفة';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;
    final products = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
        actions: [
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _openAddProduct,
                icon: const Icon(Icons.add),
                label: const Text('إضافة منتج'),
              ),
            )
          else
            IconButton(
              onPressed: _isLoading ? null : _openAddProduct,
              icon: const Icon(Icons.add),
              tooltip: 'إضافة منتج',
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchBar(
              controller: _searchController,
              isDesktop: isDesktop,
            ),
            const SizedBox(height: 12),
            _ProductsHeader(
              totalCount: _products.length,
              visibleCount: products.length,
              isSearching: _searchQuery.isNotEmpty,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _buildProductsContent(
                products: products,
                isDesktop: isDesktop,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton.extended(
              onPressed: _isLoading ? null : _openAddProduct,
              icon: const Icon(Icons.add),
              label: const Text('إضافة منتج'),
            ),
    );
  }

  Widget _buildProductsContent({
    required List<Product> products,
    required bool isDesktop,
  }) {
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
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return _EmptyProductsState(
        onAddProduct: _openAddProduct,
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Text('لا توجد نتائج مطابقة للبحث.'),
      );
    }

    return _ProductsList(
      products: products,
      isDesktop: isDesktop,
      unitName: _unitName,
      onEdit: _openEditProduct,
      onManageUnits: _openProductUnits,
      onDeactivate: _deactivateProduct,
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDesktop;

  const _SearchBar({
    required this.controller,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'ابحث عن منتج...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: controller.clear,
                icon: const Icon(Icons.clear),
                tooltip: 'مسح البحث',
              ),
        border: const OutlineInputBorder(),
        isDense: !isDesktop,
      ),
    );
  }
}

class _ProductsHeader extends StatelessWidget {
  final int totalCount;
  final int visibleCount;
  final bool isSearching;

  const _ProductsHeader({
    required this.totalCount,
    required this.visibleCount,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    final text = isSearching
        ? 'عرض $visibleCount من أصل $totalCount منتج'
        : '$totalCount منتج';

    return Row(
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  final VoidCallback onAddProduct;

  const _EmptyProductsState({
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد منتجات حاليًا.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة أول منتج إلى النظام.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAddProduct,
            icon: const Icon(Icons.add),
            label: const Text('إضافة أول منتج'),
          ),
        ],
      ),
    );
  }
}

class _ProductsList extends StatelessWidget {
  final List<Product> products;
  final bool isDesktop;
  final String Function(String unitId) unitName;
  final Future<void> Function(Product product) onEdit;
  final Future<void> Function(Product product) onManageUnits;
  final Future<void> Function(Product product) onDeactivate;

  const _ProductsList({
    required this.products,
    required this.isDesktop,
    required this.unitName,
    required this.onEdit,
    required this.onManageUnits,
    required this.onDeactivate,
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
                'الوحدة الأساسية: ${unitName(product.baseUnitId)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${product.defaultPrice.toStringAsFixed(2)} ₪',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => onManageUnits(product),
                    icon: const Icon(Icons.sell_outlined),
                    tooltip: 'وحدات البيع والباركود',
                  ),
                  IconButton(
                    onPressed: () => onEdit(product),
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'تعديل',
                  ),
                  IconButton(
                    onPressed: () => onDeactivate(product),
                    icon: const Icon(Icons.block_outlined),
                    tooltip: 'تعطيل',
                  ),
                ],
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
              '${unitName(product.baseUnitId)} • '
              '${product.defaultPrice.toStringAsFixed(2)} ₪',
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'units':
                    onManageUnits(product);
                    break;
                  case 'edit':
                    onEdit(product);
                    break;
                  case 'deactivate':
                    onDeactivate(product);
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'units',
                  child: Text('وحدات البيع والباركود'),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Text('تعديل'),
                ),
                PopupMenuItem(
                  value: 'deactivate',
                  child: Text('تعطيل'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}