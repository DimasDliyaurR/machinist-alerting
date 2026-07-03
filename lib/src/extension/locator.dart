import 'package:get_it/get_it.dart';
import 'package:masinis_helper/src/core/app_db.dart';

final locator = GetIt.instance;

void setUpLocator() {
  locator.registerSingleton<AppDb>(AppDb());
}
