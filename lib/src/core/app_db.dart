import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDb {
  static final AppDb _appDb = AppDb._singleton();

  factory AppDb() {
    return _appDb;
  }

  AppDb._singleton();

  Future<Database> openDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'machinist.db');

    return await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE signal (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipe TEXT,
            nama TEXT,
            latitude TEXT,
            longitude TEXT,
            is_aktif INTEGER 
          )
        ''');

        await db.execute('''
          CREATE TABLE route (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            kode TEXT,
            deskripsi TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE route_signals (
            route_id INTEGER NOT NULL,
            signal_id INTEGER NOT NULL,
            delete_at INT DEFAULT 0,

            PRIMARY KEY (route_id, signal_id),
            FOREIGN KEY (route_id) REFERENCES route (id) ON DELETE CASCADE,
            FOREIGN KEY (signal_id) REFERENCES signal (id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE signal (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipe TEXT,
            nama TEXT,
            latitude TEXT,
            longitude TEXT,
            is_aktif INTEGER 
          )
        ''');

          await db.execute('''
          CREATE TABLE route (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            kode TEXT,
            deskripsi TEXT
          )
        ''');

          await db.execute('''
          CREATE TABLE route_signals (
            route_id INTEGER NOT NULL,
            signal_id INTEGER NOT NULL,
            delete_at INT DEFAULT 0,

            PRIMARY KEY (route_id, signal_id),
            FOREIGN KEY (route_id) REFERENCES route (id) ON DELETE CASCADE,
            FOREIGN KEY (signal_id) REFERENCES signal (id) ON DELETE CASCADE
          )
        ''');
        }
      },
    );
  }
}
