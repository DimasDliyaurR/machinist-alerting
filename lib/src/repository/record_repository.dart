import 'package:masinis_helper/src/core/app_db.dart';

class RecordRepository {
  final AppDb _appDb;

  RecordRepository(this._appDb);

  Future<List<Map<String, dynamic>>> getRecord(int pagination) async {
    final db = await _appDb.openDb();
    List<Map<String, dynamic>> result = await db.query(
      'record',
      limit: pagination,
      orderBy: "id DESC",
    );

    return result;
  }

  Future<int> insertRecord({
    required String nama,
    required String latitude,
    required String longitude,
  }) async {
    final db = await _appDb.openDb();
    return await db.insert("record", {
      "nama": nama,
      "latitude": latitude,
      "longitude": longitude,
    });
  }
}
