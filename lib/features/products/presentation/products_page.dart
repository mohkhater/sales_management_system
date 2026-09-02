import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

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
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('إضافة منتج'),
              ),
            )
          else
            IconButton(
              onPressed: () {},
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
              child: _ProductsList(isDesktop: isDesktop),
            ),
          ],
        ),
      ),
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('إضافة منتج'),
            ),
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
  final bool isDesktop;

  const _ProductsList({required this.isDesktop});

  static const products = [
    ('مياه معدنية 500 مل', '628100000001', 'حبة', '3.00'),
    ('عصير برتقال', '628100000002', 'علبة', '4.50'),
    ('أرز 5 كجم', '628100000003', 'كيس', '28.00'),
    ('شيبس', '628100000004', 'حبة', '2.00'),
  ];

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
              title: Text(product.$1),
              subtitle: Text(
                'باركود: ${product.$2}  •  الوحدة: ${product.$3}',
              ),
              trailing: SizedBox(
                width: 180,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${product.$4} ₪',
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
            title: Text(product.$1),
            subtitle: Text(
              '${product.$3} • ${product.$4} ₪\n${product.$2}',
            ),
            isThreeLine: true,
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