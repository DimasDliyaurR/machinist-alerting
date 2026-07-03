import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDb {
  static final AppDb _appDb = AppDb._singelton();

  factory AppDb() {
    return _appDb;
  }

  AppDb._singelton();

  Future<Database> openDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'machinist.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE record (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            latitude TEXT,
            longitude TEXT
          )
        ''');
      },
    );
  }
}
