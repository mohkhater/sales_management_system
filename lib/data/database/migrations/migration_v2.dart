import 'package:sqflite/sqflite.dart';

class MigrationV2 {
  static Future<void> upgrade(Database db) async {
    // Ensure the units table exists.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS units (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        symbol TEXT,
        type TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
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
      await db.rawInsert(
        '''
        INSERT OR IGNORE INTO units
        (id, name, symbol, type, is_active, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          unit.$1,
          unit.$2,
          unit.$3,
          unit.$4,
          1,
          now,
          now,
        ],
      );
    }
  }
}