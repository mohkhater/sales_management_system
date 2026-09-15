import 'dart:math';

import '../../../data/database/app_database.dart';
import 'product_barcode_model.dart';

class ProductBarcodeRepository {
  ProductBarcodeRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  static const String _tableName = 'product_barcodes';

  Future<List<ProductBarcode>> getForProductUnit(
    String productUnitId, {
    bool activeOnly = false,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      _tableName,
      where: activeOnly
          ? 'product_unit_id = ? AND is_active = ?'
          : 'product_unit_id = ?',
      whereArgs: activeOnly ? [productUnitId, 1] : [productUnitId],
      orderBy: 'barcode ASC',
    );
    return rows.map(ProductBarcode.fromMap).toList(growable: false);
  }

  Future<ProductBarcode?> findByBarcode(
    String barcode, {
    bool activeOnly = true,
  }) async {
    final normalized = barcode.trim();
    if (normalized.isEmpty) return null;

    final db = await _database.database;
    final rows = await db.query(
      _tableName,
      where: activeOnly
          ? 'barcode = ? AND is_active = ?'
          : 'barcode = ?',
      whereArgs: activeOnly ? [normalized, 1] : [normalized],
      limit: 1,
    );
    return rows.isEmpty ? null : ProductBarcode.fromMap(rows.first);
  }

  Future<ProductBarcode> insert({
    required String productId,
    required String productUnitId,
    required String barcode,
  }) async {
    final normalized = _normalize(barcode);
    final db = await _database.database;

    final productUnit = await db.query(
      'product_units',
      columns: ['product_id'],
      where: 'id = ?',
      whereArgs: [productUnitId],
      limit: 1,
    );
    if (productUnit.isEmpty || productUnit.first['product_id'] != productId) {
      throw StateError('Product unit does not belong to product: $productUnitId');
    }

    final duplicate = await db.query(
      _tableName,
      columns: ['id'],
      where: 'barcode = ?',
      whereArgs: [normalized],
      limit: 1,
    );
    if (duplicate.isNotEmpty) {
      throw StateError('Barcode already exists: $normalized');
    }

    final now = DateTime.now();
    final item = ProductBarcode(
      id: _generateId(),
      productId: productId,
      productUnitId: productUnitId,
      barcode: normalized,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(_tableName, item.toMap());
    return item;
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
      throw StateError('Barcode not found: $id');
    }
  }

  String _normalize(String barcode) {
    final normalized = barcode.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(barcode, 'barcode', 'Barcode cannot be empty.');
    }
    return normalized;
  }

  String _generateId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = Random.secure().nextInt(1 << 32);
    return '$timestamp-$random';
  }
}
