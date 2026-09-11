import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:sales_management_system/data/database/app_database.dart';
import 'package:sales_management_system/features/units/data/unit_model.dart';
import 'package:sales_management_system/features/units/data/unit_repository.dart';

void main() {
  late AppDatabase testDatabase;
  late UnitRepository repository;
  late String databasePath;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databasePath = '${Directory.systemTemp.path}'
        '${Platform.pathSeparator}'
        'sales_management_unit_test_'
        '${DateTime.now().microsecondsSinceEpoch}.db';

    testDatabase = AppDatabase(
      databasePath: databasePath,
    );

    repository = UnitRepository(
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

  test('unit repository reads default units', () async {
    final units = await repository.getAll();

    expect(units, isNotEmpty);
    expect(units, everyElement(isA<Unit>()));

    final piece = await repository.getById('piece');

    expect(piece, isNotNull);
    expect(piece!.id, 'piece');
    expect(piece.name, 'حبة');
    expect(piece.isActive, isTrue);
  });

  test('unit repository returns active units only', () async {
    final db = await testDatabase.database;

    await db.update(
      'units',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: ['piece'],
    );

    final allUnits = await repository.getAll();
    final activeUnits = await repository.getAll(activeOnly: true);

    expect(allUnits, isNotEmpty);
    expect(activeUnits, isNotEmpty);

    expect(
      allUnits.any((unit) => unit.id == 'piece'),
      isTrue,
    );

    expect(
      activeUnits.any((unit) => unit.id == 'piece'),
      isFalse,
    );
  });

  test('unit repository returns null for unknown unit', () async {
    final unit = await repository.getById('unknown-unit');

    expect(unit, isNull);
  });
}