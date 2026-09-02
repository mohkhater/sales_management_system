import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations/migration_v1.dart';

class AppDatabase {
  AppDatabase({
    this.databasePath,
  });

  static final AppDatabase instance = AppDatabase();

  final String? databasePath;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final path = databasePath ??
        join(
          await getDatabasesPath(),
          'sales_management.db',
        );

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await MigrationV1.create(db);
      },
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}