import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sales_management_system/data/database/app_database.dart';
import 'package:sales_management_system/features/products/data/product_barcode_repository.dart';
import 'package:sales_management_system/features/products/data/product_repository.dart';
import 'package:sales_management_system/features/products/data/product_unit_repository.dart';
import 'package:sales_management_system/features/products/data/product_unit_model.dart';

void main() {
  late AppDatabase database;
  late ProductRepository products;
  late ProductUnitRepository productUnits;
  late ProductBarcodeRepository barcodes;
  late String databasePath;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databasePath = '${Directory.systemTemp.path}${Platform.pathSeparator}'
        'sales_management_product_units_${DateTime.now().microsecondsSinceEpoch}.db';
    database = AppDatabase(databasePath: databasePath);
    products = ProductRepository(database: database);
    productUnits = ProductUnitRepository(database: database);
    barcodes = ProductBarcodeRepository(database: database);
    await database.database;
  });

  tearDown(() async {
    await database.close();
    final file = File(databasePath);
    if (await file.exists()) await file.delete();
  });

  test('new product gets a base product unit with its selling price', () async {
    final product = await products.insert(
      name: 'مياه 500ml',
      baseUnitId: 'piece',
      defaultPrice: 2.5,
    );

    final units = await productUnits.getForProduct(product.id);

    expect(units, hasLength(1));
    expect(units.single.unitId, 'piece');
    expect(units.single.conversionToBase, 1.0);
    expect(units.single.sellingPrice, 2.5);
    expect(units.single.isActive, isTrue);
  });

  test('additional selling unit and barcode work', () async {
    final product = await products.insert(
      name: 'مياه 500ml',
      baseUnitId: 'piece',
      defaultPrice: 2.5,
    );

    final carton = await productUnits.insert(
      productId: product.id,
      unitId: 'carton',
      conversionToBase: 24,
      sellingPrice: 55,
    );

    final barcode = await barcodes.insert(
      productId: product.id,
      productUnitId: carton.id,
      barcode: '6291234567890',
    );

    expect(barcode.barcode, '6291234567890');
    expect((await barcodes.findByBarcode(' 6291234567890 '))!.id, barcode.id);

    final units = await productUnits.getForProduct(product.id);
    expect(units, hasLength(2));
    expect(units.any((u) => u.unitId == 'carton' && u.sellingPrice == 55), isTrue);
  });

  test('duplicate unit and duplicate barcode are rejected', () async {
    final product = await products.insert(
      name: 'منتج اختبار',
      baseUnitId: 'piece',
    );

    await productUnits.insert(
      productId: product.id,
      unitId: 'carton',
      conversionToBase: 12,
      sellingPrice: 20,
    );

    expect(
      () => productUnits.insert(
        productId: product.id,
        unitId: 'carton',
        conversionToBase: 12,
        sellingPrice: 20,
      ),
      throwsA(isA<StateError>()),
    );

    final base = (await productUnits.getForProduct(product.id)).firstWhere((u) => u.unitId == 'piece');
    await barcodes.insert(
      productId: product.id,
      productUnitId: base.id,
      barcode: '1111111111111',
    );

    expect(
      () => barcodes.insert(
        productId: product.id,
        productUnitId: base.id,
        barcode: '1111111111111',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('invalid conversion and price are rejected', () async {
    final product = await products.insert(
      name: 'منتج اختبار',
      baseUnitId: 'piece',
    );

    expect(
      () => productUnits.insert(
        productId: product.id,
        unitId: 'carton',
        conversionToBase: 0,
        sellingPrice: 10,
      ),
      throwsA(isA<ArgumentError>()),
    );

    expect(
      () => productUnits.insert(
        productId: product.id,
        unitId: 'carton',
        conversionToBase: 10,
        sellingPrice: -1,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
  test('base unit conversion remains exactly one', () async {
    final product = await products.insert(
      name: 'منتج أساسي',
      baseUnitId: 'piece',
      defaultPrice: 3,
    );

    final base = (await productUnits.getForProduct(product.id)).single;

    expect(
      () => productUnits.update(
        ProductUnit(
          id: base.id,
          productId: base.productId,
          unitId: base.unitId,
          conversionToBase: 2,
          sellingPrice: base.sellingPrice,
          isActive: base.isActive,
          createdAt: base.createdAt,
          updatedAt: base.updatedAt,
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

}
