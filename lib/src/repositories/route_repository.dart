import 'package:masinis_helper/src/core/app_db.dart';
import 'package:masinis_helper/src/dto/route_dto.dart';
import 'package:masinis_helper/src/repositories/repository_base.dart';

class RouteRepository extends BaseRepository<RouteDto> {
  RouteRepository(AppDb appDb)
    : super(
        appDb: appDb,
        tableName: 'route',
        fromMap: (map) => RouteDto.formMap(map),
      );
}
