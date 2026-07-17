import 'package:masinis_helper/src/core/app_db.dart';
import 'package:masinis_helper/src/dto/signal_dto.dart';
import 'package:masinis_helper/src/repositories/repository_base.dart';

class SignalRepository extends BaseRepository<SignalDto> {
  SignalRepository(AppDb appDb)
    : super(
        appDb: appDb,
        tableName: 'signal',
        fromMap: (map) => SignalDto.formMap(map),
      );
}
