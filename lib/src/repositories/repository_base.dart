import 'package:masinis_helper/src/core/app_db.dart';
import 'package:masinis_helper/src/dto/dto_base.dart';

abstract class BaseRepository<T extends DtoBase> {
  final AppDb appDb;
  final String tableName;

  final T Function(Map<String, dynamic>) fromMap;

  BaseRepository({
    required this.appDb,
    required this.tableName,
    required this.fromMap,
  });

  Future<List<T>?> getAll(int pagination) async {
    final db = await appDb.openDb();
    List<Map<String, dynamic>> result = await db.query(
      tableName,
      limit: pagination,
      orderBy: "id DESC",
    );

    if (result.isEmpty) return null;

    return result.map((row) => fromMap(row)).toList();
  }

  Future<T?> getOne(int id) async {
    final db = await appDb.openDb();
    List<Map<String, dynamic>> result = await db.query(
      tableName,
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
      orderBy: "id DESC",
    );

    if (result.isEmpty) return null;
    return fromMap(result.first);
  }

  Future<int> insert(T item) async {
    final db = await appDb.openDb();
    return await db.insert(tableName, item.toMap());
  }

  Future<int> destroy(int id) async {
    final db = await appDb.openDb();
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
