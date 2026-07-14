import 'package:masinis_helper/src/core/app_db.dart';
import 'package:masinis_helper/src/dto/record_dto.dart';

class RecordRepository {
  final String _tableName = "record";
  final AppDb _appDb;

  RecordRepository(this._appDb);

  Future<List<Map<String, dynamic>>> getRecord(int pagination) async {
    final db = await _appDb.openDb();
    List<Map<String, dynamic>> result = await db.query(
      _tableName,
      limit: pagination,
      orderBy: "id DESC",
    );
    return result;
  }

  Future<Map<String, dynamic>> getOneRecord({required String id}) async {
    final db = await _appDb.openDb();
    List<Map<String, dynamic>> result = await db.query(
      _tableName,
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
      orderBy: "id DESC",
    );
    return result[0];
  }

  Future<int> insertRecord({required RecordDto record}) async {
    final db = await _appDb.openDb();
    return await db.insert(_tableName, record.toMap());
  }

  Future<int> destroyRecord({required int id}) async {
    final db = await _appDb.openDb();
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
