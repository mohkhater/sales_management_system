import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../../../data/database/app_database.dart';
import 'product_unit_model.dart';

class ProductUnitRepository {
  ProductUnitRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  static const String _tableName = 'product_units';

  Future<List<ProductUnit>> getForProduct(
    String productId, {
    bool activeOnly = false,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      _tableName,
      where: activeOnly
          ? 'product_id = ? AND is_active = ?'
          : 'product_id = ?',
      whereArgs: activeOnly ? [productId, 1] : [productId],
      orderBy: 'conversion_to_base ASC, id ASC',
    );
    return rows.map(ProductUnit.fromMap).toList(growable: false);
  }

  Future<ProductUnit?> getById(String id) async {
    final db = await _database.database;
    final rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : ProductUnit.fromMap(rows.first);
  }

  Future<ProductUnit> insert({
    required String productId,
    required String unitId,
    required double conversionToBase,
    required double sellingPrice,
  }) async {
    _validate(conversionToBase, sellingPrice);
    final db = await _database.database;

    await _requireProductAndUnit(db, productId, unitId);

    final productRows = await db.query(
      'products',
      columns: ['base_unit_id'],
      where: 'id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    if (productRows.isNotEmpty &&
        productRows.first['base_unit_id'] == unitId &&
        conversionToBase != 1.0) {
      throw ArgumentError.value(
        conversionToBase,
        'conversionToBase',
        'The base unit conversion must be exactly 1.',
      );
    }

    final duplicate = await db.query(
      _tableName,
      columns: ['id'],
      where: 'product_id = ? AND unit_id = ?',
      whereArgs: [productId, unitId],
      limit: 1,
    );
    if (duplicate.isNotEmpty) {
      throw StateError('Product unit already exists: $unitId');
    }

    final now = DateTime.now();
    final productUnit = ProductUnit(
      id: _generateId(),
      productId: productId,
      unitId: unitId,
      conversionToBase: conversionToBase,
      sellingPrice: sellingPrice,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(_tableName, productUnit.toMap());
    return productUnit;
  }

  Future<void> update(ProductUnit productUnit) async {
    _validate(productUnit.conversionToBase, productUnit.sellingPrice);
    final db = await _database.database;

    await _requireProductAndUnit(
      db,
      productUnit.productId,
      productUnit.unitId,
    );

    final productRows = await db.query(
      'products',
      columns: ['base_unit_id'],
      where: 'id = ?',
      whereArgs: [productUnit.productId],
      limit: 1,
    );
    if (productRows.isNotEmpty &&
        productRows.first['base_unit_id'] == productUnit.unitId &&
        productUnit.conversionToBase != 1.0) {
      throw ArgumentError.value(
        productUnit.conversionToBase,
        'conversionToBase',
        'The base unit conversion must be exactly 1.',
      );
    }

    final duplicate = await db.query(
      _tableName,
      columns: ['id'],
      where: 'product_id = ? AND unit_id = ? AND id != ?',
      whereArgs: [productUnit.productId, productUnit.unitId, productUnit.id],
      limit: 1,
    );
    if (duplicate.isNotEmpty) {
      throw StateError('Product unit already exists: ${productUnit.unitId}');
    }

    final updated = ProductUnit(
      id: productUnit.id,
      productId: productUnit.productId,
      unitId: productUnit.unitId,
      conversionToBase: productUnit.conversionToBase,
      sellingPrice: productUnit.sellingPrice,
      isActive: productUnit.isActive,
      createdAt: productUnit.createdAt,
      updatedAt: DateTime.now(),
    );

    final affected = await db.update(
      _tableName,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [productUnit.id],
    );
    if (affected == 0) {
      throw StateError('Product unit not found: ${productUnit.id}');
    }
  }

  Future<void> deactivate(String id) async {
    final db = await _database.database;
    final affected = await db.update(
      _tableName,
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    if (affected == 0) {
      throw StateError('Product unit not found: $id');
    }
  }

  Future<void> _requireProductAndUnit(
    Database db,
    String productId,
    String unitId,
  ) async {
    final product = await db.query(
      'products',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    if (product.isEmpty) {
      throw StateError('Product not found: $productId');
    }

    final unit = await db.query(
      'units',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [unitId],
      limit: 1,
    );
    if (unit.isEmpty) {
      throw StateError('Unit not found: $unitId');
    }
  }

  void _validate(double conversionToBase, double sellingPrice) {
    if (!conversionToBase.isFinite || conversionToBase <= 0) {
      throw ArgumentError.value(
        conversionToBase,
        'conversionToBase',
        'Conversion must be a finite number greater than zero.',
      );
    }
    if (!sellingPrice.isFinite || sellingPrice < 0) {
      throw ArgumentError.value(
        sellingPrice,
        'sellingPrice',
        'Selling price must be a finite number greater than or equal to zero.',
      );
    }
  }

  String _generateId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = Random.secure().nextInt(1 << 32);
    return '$timestamp-$random';
  }
}
