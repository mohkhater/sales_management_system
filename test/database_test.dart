import 'package:flutter_test/flutter_test.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:sales_management_system/data/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite for Windows/Dart VM tests.
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    await deleteDatabase(
      '${await getDatabasesPath()}/sales_management.db',
    );
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  test('database creates tables and default units', () async {
    final db = await AppDatabase.instance.database;

    final tables = await db.rawQuery('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
      AND name NOT LIKE 'sqlite_%'
      ORDER BY name
    ''');

    final tableNames = tables
        .map((row) => row['name'] as String)
        .toList();

    expect(
      tableNames,
      containsAll([
        'units',
        'products',
        'product_units',
        'product_barcodes',
      ]),
    );

    final units = await db.query('units');

    expect(units.length, 13);

    expect(
      units.any((unit) => unit['id'] == 'piece'),
      isTrue,
    );

    expect(
      units.any((unit) => unit['id'] == 'kilogram'),
      isTrue,
    );

    expect(
      units.any((unit) => unit['id'] == 'carton'),
      isTrue,
    );
  });
}