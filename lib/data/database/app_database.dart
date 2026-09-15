import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations/migration_v1.dart';
import 'migrations/migration_v5.dart';

class AppDatabase {
  AppDatabase({this.databasePath});

  static final AppDatabase instance = AppDatabase();

  final String? databasePath;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final path = databasePath ??
        join(await getDatabasesPath(), 'sales_management.db');

    final db = await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await MigrationV1.create(db);
        await MigrationV5.upgrade(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Versions 2 and 3 were temporary development repairs.
        // Version 4 keeps existing databases safe by ensuring the
        // default units are present without destructive changes.
        if (oldVersion < 4) {
          await _ensureUnits(db);
        }
        if (oldVersion < 5) {
          await MigrationV5.upgrade(db);
        }
      },
    );

    // Idempotent repair for existing v4 databases as well.
    await _ensureUnits(db);
    return db;
  }

  Future<void> _ensureUnits(Database db) async {
    final tableCheck = await db.rawQuery(
      "SELECT name FROM sqlite_master "
      "WHERE type = 'table' AND name = 'units'",
    );

    if (tableCheck.isEmpty) {
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
    }

    final now = DateTime.now().toIso8601String();

    const units = [
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
        VALUES (?, ?, ?, ?, 1, ?, ?)
        ''',
        [unit.$1, unit.$2, unit.$3, unit.$4, now, now],
      );
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
