import 'package:sqflite/sqflite.dart';

class MigrationV5 {
  static Future<void> upgrade(Database db) async {
    await db.execute(
      'ALTER TABLE product_units ADD COLUMN selling_price REAL NOT NULL DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE product_units ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1',
    );
    await db.execute(
      "ALTER TABLE product_units ADD COLUMN created_at TEXT NOT NULL DEFAULT ''",
    );
    await db.execute(
      "ALTER TABLE product_units ADD COLUMN updated_at TEXT NOT NULL DEFAULT ''",
    );

    await db.execute(
      'ALTER TABLE product_barcodes ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1',
    );
    await db.execute(
      'ALTER TABLE product_barcodes ADD COLUMN created_at TEXT NOT NULL DEFAULT \'\'',
    );
    await db.execute(
      'ALTER TABLE product_barcodes ADD COLUMN updated_at TEXT NOT NULL DEFAULT \'\'',
    );

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_product_units_product_id '
      'ON product_units(product_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_product_barcodes_product_id '
      'ON product_barcodes(product_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_product_barcodes_product_unit_id '
      'ON product_barcodes(product_unit_id)',
    );

    final now = DateTime.now().toIso8601String();

    await db.update(
      'product_units',
      {'created_at': now, 'updated_at': now},
      where: "created_at = '' OR updated_at = ''",
    );
    await db.update(
      'product_barcodes',
      {'created_at': now, 'updated_at': now},
      where: "created_at = '' OR updated_at = ''",
    );

    final products = await db.query(
      'products',
      columns: ['id', 'base_unit_id', 'default_price'],
    );

    for (final product in products) {
      final productId = product['id'] as String;
      final baseUnitId = product['base_unit_id'] as String;
      final existing = await db.query(
        'product_units',
        columns: ['id'],
        where: 'product_id = ? AND unit_id = ?',
        whereArgs: [productId, baseUnitId],
        limit: 1,
      );

      if (existing.isEmpty) {
        await db.insert('product_units', {
          'id': 'base-$productId',
          'product_id': productId,
          'unit_id': baseUnitId,
          'conversion_to_base': 1.0,
          'selling_price': (product['default_price'] as num).toDouble(),
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        });
        await db.update(
          'product_units',
          {'updated_at': now},
          where: 'id = ?',
          whereArgs: ['base-$productId'],
        );
      }
    }
  }
}
