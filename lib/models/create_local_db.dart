import 'package:sqflite/sqflite.dart';

class LocalDB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await _initDB();
    return _db!;
  }

  static Future<void> clearDatabase() async {
    String path = '${await getDatabasesPath()}/split_app.db';
    await deleteDatabase(path);
    _db = null; // Reset the database instance
  }

  static Future<Database> _initDB() async {
    String path = '${await getDatabasesPath()}/split_app.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user (
            mobile_number TEXT PRIMARY KEY,
            full_name TEXT,
            upi_id TEXT,
            profile_picture TEXT,
            user_creation TEXT,
            last_login TEXT,
            to_get REAL DEFAULT 0,
            to_pay REAL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE user_data (
            id TEXT PRIMARY KEY,
            type TEXT,
            amount REAL,
            split_by TEXT NULL,
            split_time TEXT,
            status TEXT NULL,
            paid_time TEXT DEFAULT NULL,
            FOREIGN KEY(split_by) REFERENCES user(mobile_number)
          )
        ''');
        await db.execute('''
          CREATE TABLE split_on (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_data_id TEXT,
            mobile_no TEXT,
            amount REAL,
            status TEXT,
            paid_time TEXT DEFAULT NULL,
            FOREIGN KEY(user_data_id) REFERENCES user_data(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE friends_data (
            mobile_number TEXT PRIMARY KEY,
            full_name TEXT,
            profile_picture TEXT,
            upi_id TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE friend_requests (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sender_mobile TEXT NOT NULL,
            receiver_mobile TEXT NOT NULL,
            full_name TEXT,
            profile_picture TEXT DEFAULT NULL,
            upi_id TEXT DEFAULT NULL,
            status TEXT DEFAULT 'pending' CHECK(status IN ('pending','accepted','rejected')),
            created_at TEXT DEFAULT NULL
          )
        ''');        
      },
    );
  }
}
