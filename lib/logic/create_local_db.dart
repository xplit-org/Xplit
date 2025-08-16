import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocalDB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
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
            profile_pic TEXT,
            user_creation TEXT,
            last_login TEXT,
            to_get REAL DEFAULT 0,
            to_pay REAL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE user_data (
            id TEXT PRIMARY KEY,
            type INTEGER,
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
      },
    );
  }

  Future<void> syncUserData(String mobileNumber) async {
    final db = await LocalDB.database;

    // 1. Fetch user info
    final userDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(mobileNumber)
        .get();

    if (userDoc.exists) {
      await db.insert(
        'user',
        {
          'mobile_number': mobileNumber,
          'full_name': userDoc['full_name'],
          'profile_pic': userDoc['profile_pic'],
          'user_creation': userDoc['user_creation'],
          'last_login': userDoc['last_login'],
          'to_get': userDoc['to_get'],
          'to_pay': userDoc['to_pay'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // 2. Fetch all user_data entries
    final types = ['type_0', 'type_1'];
    // Type_0
    String type = types[0];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('user_data')
        .doc(mobileNumber)
        .collection(type)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        await db.insert(
          'user_data',
          {
            'id': doc.id,
            'type': type,
            'amount': data['amount'],
            'split_by': data['split_by'],
            'split_time': data['split_time'],
            'status': data['status'],
            'paid_time': data['status'] == 'paid' ? data['paid_time'] : null,
            'mobile_number': mobileNumber,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    // Type_1
    type = types[1];
    snapshot = await FirebaseFirestore.instance
        .collection('user_data')
        .doc(mobileNumber)
        .collection(type)
        .get();
    
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        await db.insert(
          'user_data',
          {
            'id': doc.id,
            'type': type,
            'amount': data['amount'],
            'split_by': null,
            'split_time': data['split_time'],
            'status': null,
            'paid_time': null,
            'mobile_number': mobileNumber,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        final splitOn = data['split_on'] as List<dynamic>?;
        if (splitOn != null) {
          for (var split in splitOn) {
            final splitData = split as Map<String, dynamic>;
            await db.insert(
              'split_on',
              {
                'user_data_id': doc.id,
                'mobile_no': splitData['mobile_no'],
                'amount': splitData['amount'],
                'status': splitData['status'],
                'paid_time': splitData['status'] == 'paid' ? splitData['paid_time'] : null,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }
    }
  }
}
