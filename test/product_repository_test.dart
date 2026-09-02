import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sales_management_system/data/database/app_database.dart';
import 'package:sales_management_system/features/products/data/product_model.dart';
import 'package:sales_management_system/features/products/data/product_repository.dart';

void main() {
  late AppDatabase testDatabase;
  late ProductRepository repository;
  late String databasePath;

    setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  

  setUp(() async {
    databasePath = '${Directory.systemTemp.path}'
        '${Platform.pathSeparator}'
        'sales_management_test_${DateTime.now().microsecondsSinceEpoch}.db';

    testDatabase = AppDatabase(
      databasePath: databasePath,
    );

    repository = ProductRepository(
      database: testDatabase,
    );

    await testDatabase.database;
  });

  tearDown(() async {
    await testDatabase.close();

    final databaseFile = File(databasePath);

    if (await databaseFile.exists()) {
      await databaseFile.delete();
    }
  });

  test('product repository CRUD lifecycle', () async {
    final product = await repository.insert(
      name: 'مياه 500ml',
      baseUnitId: 'piece',
      defaultPrice: 2.5,
    );

    expect(product.id, isNotEmpty);
    expect(product.name, 'مياه 500ml');
    expect(product.baseUnitId, 'piece');
    expect(product.defaultPrice, 2.5);
    expect(product.isActive, isTrue);

    final savedProduct = await repository.getById(product.id);

    expect(savedProduct, isNotNull);
    expect(savedProduct!.id, product.id);
    expect(savedProduct.name, 'مياه 500ml');
    expect(savedProduct.baseUnitId, 'piece');
    expect(savedProduct.defaultPrice, 2.5);
    expect(savedProduct.isActive, isTrue);

    final products = await repository.getAll();

    expect(products, hasLength(1));
    expect(products.first.id, product.id);

    final oldUpdatedAt = savedProduct.updatedAt;

    final updatedProduct = Product(
      id: savedProduct.id,
      name: 'مياه 500ml جديد',
      baseUnitId: savedProduct.baseUnitId,
      categoryId: savedProduct.categoryId,
      defaultPrice: 3.0,
      isActive: savedProduct.isActive,
      createdAt: savedProduct.createdAt,
      updatedAt: savedProduct.updatedAt,
    );

    await repository.update(updatedProduct);

    final afterUpdate = await repository.getById(product.id);

    expect(afterUpdate, isNotNull);
    expect(afterUpdate!.name, 'مياه 500ml جديد');
    expect(afterUpdate.defaultPrice, 3.0);
    expect(
      afterUpdate.updatedAt.isAfter(oldUpdatedAt),
      isTrue,
    );

    await repository.deactivate(product.id);

    final afterDeactivate = await repository.getById(product.id);

    expect(afterDeactivate, isNotNull);
    expect(afterDeactivate!.isActive, isFalse);

    final activeProducts = await repository.getAll(
      activeOnly: true,
    );

    expect(activeProducts, isEmpty);

    final allProducts = await repository.getAll();

    expect(allProducts, hasLength(1));
    expect(allProducts.first.id, product.id);
    expect(allProducts.first.isActive, isFalse);
  });
}