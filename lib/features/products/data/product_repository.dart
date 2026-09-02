import 'dart:math';

import '../../../data/database/app_database.dart';
import 'product_model.dart';

class ProductRepository {
  ProductRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  static const String _tableName = 'products';

  Future<List<Product>> getAll({
    bool activeOnly = false,
  }) async {
    final db = await _database.database;

    final rows = await db.query(
      _tableName,
      where: activeOnly ? 'is_active = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return rows.map(Product.fromMap).toList(growable: false);
  }

  Future<Product?> getById(String id) async {
    final db = await _database.database;

    final rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return Product.fromMap(rows.first);
  }

  Future<Product> insert({
    required String name,
    required String baseUnitId,
    String? categoryId,
    double defaultPrice = 0,
    bool isActive = true,
  }) async {
    final now = DateTime.now();

    final product = Product(
      id: _generateId(),
      name: name,
      baseUnitId: baseUnitId,
      categoryId: categoryId,
      defaultPrice: defaultPrice,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );

    final db = await _database.database;

    await db.insert(
      _tableName,
      product.toMap(),
    );

    return product;
  }

  Future<void> update(Product product) async {
    final updatedProduct = Product(
      id: product.id,
      name: product.name,
      baseUnitId: product.baseUnitId,
      categoryId: product.categoryId,
      defaultPrice: product.defaultPrice,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: DateTime.now(),
    );

    final db = await _database.database;

    final affectedRows = await db.update(
      _tableName,
      updatedProduct.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );

    if (affectedRows == 0) {
      throw StateError(
        'Product not found: ${product.id}',
      );
    }
  }

  Future<void> deactivate(String id) async {
    final db = await _database.database;

    final affectedRows = await db.update(
      _tableName,
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (affectedRows == 0) {
      throw StateError(
        'Product not found: $id',
      );
    }
  }

  String _generateId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = Random.secure().nextInt(1 << 32);

    return '$timestamp-$random';
  }
}