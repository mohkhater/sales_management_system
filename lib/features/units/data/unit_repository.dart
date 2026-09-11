import '../../../data/database/app_database.dart';
import 'unit_model.dart';

class UnitRepository {
  UnitRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  static const String _tableName = 'units';

  Future<List<Unit>> getAll({
    bool activeOnly = false,
  }) async {
    final db = await _database.database;

    final rows = await db.query(
      _tableName,
      where: activeOnly ? 'is_active = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return rows.map(Unit.fromMap).toList(growable: false);
  }

  Future<Unit?> getById(String id) async {
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

    return Unit.fromMap(rows.first);
  }
}

