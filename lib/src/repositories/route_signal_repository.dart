import 'package:masinis_helper/src/core/app_db.dart';
import 'package:masinis_helper/src/dto/route_signal_dto.dart';
import 'package:masinis_helper/src/repositories/repository_base.dart';

class RouteSignalRepository extends BaseRepository<RouteSignalDto> {
  RouteSignalRepository(AppDb appDb)
    : super(
        appDb: appDb,
        tableName: "route_signals",
        fromMap: (map) => RouteSignalDto.formMap(map),
      );

  Future<RouteSignalWithSignalDto?> getRouteWithSignals(int routeId) async {
    final db = await appDb.openDb();

    const String sql = '''
    SELECT 
      r.id AS route_id, r.nama AS route_nama, r.kode AS route_kode,
      s.id AS signal_id, s.nama AS signal_nama, s.jenis AS signal_jenis
    FROM route r
    LEFT JOIN route_signals rs ON r.id = rs.route_id
    LEFT JOIN signal s ON rs.signal_id = s.id
    WHERE r.id = ?
  ''';

    List<Map<String, dynamic>> rawResult = await db.rawQuery(sql, [routeId]);

    if (rawResult.isEmpty) {
      return null;
    }

    Map<String, dynamic> routeMap = {
      "id": rawResult.first["route_id"],
      "nama": rawResult.first["route_nama"],
      "kode": rawResult.first["route_kode"],
    };

    List<Map<String, dynamic>> signalMaps = [];

    for (var row in rawResult) {
      if (row["signal_id"] != null) {
        signalMaps.add({
          "id": row["signal_id"],
          "nama": row["signal_nama"],
          "jenis": row["signal_jenis"],
        });
      }
    }

    return RouteSignalWithSignalDto.fromMap(routeMap, signalMaps);
  }

  @override
  Future<int> destroy(int id) async {
    final db = await appDb.openDb();
    return await db.update(
      tableName,
      {"deleted_at": 1},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> restore(int id) async {
    final db = await appDb.openDb();
    return await db.update(
      tableName,
      {"deleted_at": 0},
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
