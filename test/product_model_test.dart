import 'package:flutter_test/flutter_test.dart';
import 'package:sales_management_system/features/products/data/product_model.dart';

void main() {
  test('Product converts to map and back correctly', () {
    final createdAt = DateTime.parse('2026-09-02T18:00:00.000Z');
    final updatedAt = DateTime.parse('2026-09-02T19:00:00.000Z');

    final product = Product(
      id: 'product-001',
      name: 'مياه 500ml',
      baseUnitId: 'piece',
      categoryId: null,
      defaultPrice: 2.50,
      isActive: true,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final map = product.toMap();
    final restored = Product.fromMap(map);

    expect(restored.id, product.id);
    expect(restored.name, product.name);
    expect(restored.baseUnitId, product.baseUnitId);
    expect(restored.categoryId, isNull);
    expect(restored.defaultPrice, product.defaultPrice);
    expect(restored.isActive, product.isActive);
    expect(restored.createdAt, product.createdAt);
    expect(restored.updatedAt, product.updatedAt);
  });
}