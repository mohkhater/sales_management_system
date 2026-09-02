import 'package:sqflite/sqflite.dart';

class MigrationV1 {
  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE units (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        symbol TEXT,
        type TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        base_unit_id TEXT NOT NULL,
        category_id TEXT,
        default_price REAL NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (base_unit_id) REFERENCES units(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE product_units (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        unit_id TEXT NOT NULL,
        conversion_to_base REAL NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (unit_id) REFERENCES units(id),
        UNIQUE(product_id, unit_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE product_barcodes (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        product_unit_id TEXT NOT NULL,
        barcode TEXT NOT NULL UNIQUE,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (product_unit_id) REFERENCES product_units(id)
      )
    ''');

    await _insertDefaultUnits(db);
  }

  static Future<void> _insertDefaultUnits(Database db) async {
    final now = DateTime.now().toIso8601String();

    final units = [
      ('piece', 'حبة', 'حبة', 'piece'),
      ('kilogram', 'كيلوجرام', 'كجم', 'weight'),
      ('gram', 'جرام', 'جم', 'weight'),
      ('ton', 'طن', 'طن', 'weight'),
      ('liter', 'لتر', 'لتر', 'volume'),
      ('milliliter', 'ملليلتر', 'مل', 'volume'),
      ('meter', 'متر', 'م', 'length'),
      ('square_meter', 'متر مربع', 'م²', 'area'),
      ('pair', 'زوج', 'زوج', 'piece'),
      ('box', 'علبة', 'علبة', 'package'),
      ('carton', 'كرتونة', 'كرتون', 'package'),
      ('bag', 'شوال', 'شوال', 'package'),
      ('sack', 'كيس', 'كيس', 'package'),
    ];

    for (final unit in units) {
      await db.insert('units', {
        'id': unit.$1,
        'name': unit.$2,
        'symbol': unit.$3,
        'type': unit.$4,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }
}