import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> syncUserData(String mobileNumber) async {
    final db = await LocalDB.database;
    // 1. Fetch user info
    final userDoc = await FirebaseFirestore.instance
        .collection('user_details')
        .doc(mobileNumber)
        .get();

    if (userDoc.exists) {
      print("User info exists");

      // Convert Firestore Timestamps to strings
      String userCreation = '';
      String lastLogin = '';

      if (userDoc['user_creation'] != null) {
        if (userDoc['user_creation'] is Timestamp) {
          userCreation = (userDoc['user_creation'] as Timestamp)
              .toDate()
              .toIso8601String();
        } else {
          userCreation = userDoc['user_creation'].toString();
        }
      }

      if (userDoc['last_login'] != null) {
        if (userDoc['last_login'] is Timestamp) {
          lastLogin = (userDoc['last_login'] as Timestamp)
              .toDate()
              .toIso8601String();
        } else {
          lastLogin = userDoc['last_login'].toString();
        }
      }

      await db.insert('user', {
        'mobile_number': mobileNumber,
        'full_name': userDoc['full_name'],
        'profile_picture': userDoc['profile_picture'],
        'upi_id': userDoc['upi_id'],
        'user_creation': userCreation,
        'last_login': lastLogin,
        'to_get': userDoc['to_get'],
        'to_pay': userDoc['to_pay'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      print("User info does not exist");
    }

    // 2. Fetch all user_data entries
    final types = ['type_0', 'type_1', 'friends_data'];
    // Type_0
    String type = types[0];
    try{
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('user_data')
        .doc(mobileNumber)
        .collection(type)
        .get();
    

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        // Convert timestamps to strings
        String splitTime = '';
        String paidTime = '';

        if (data['split_time'] != null) {
          if (data['split_time'] is Timestamp) {
            splitTime = (data['split_time'] as Timestamp)
                .toDate()
                .toIso8601String();
          } else {
            splitTime = data['split_time'].toString();
          }
        }

        if (data['paid_time'] != null && data['status'] == 'paid') {
          if (data['paid_time'] is Timestamp) {
            paidTime = (data['paid_time'] as Timestamp)
                .toDate()
                .toIso8601String();
          } else {
            paidTime = data['paid_time'].toString();
          }
        }

        await db.insert('user_data', {
          'id': doc.id,
          'type': type,
          'amount': data['amount'],
          'split_by': data['split_by'],
          'split_time': splitTime,
          'status': data['status'],
          'paid_time': paidTime,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
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
        // Convert timestamps to strings
        String splitTime = '';

        if (data['split_time'] != null) {
          if (data['split_time'] is Timestamp) {
            splitTime = (data['split_time'] as Timestamp)
                .toDate()
                .toIso8601String();
          } else {
            splitTime = data['split_time'].toString();
          }
        }

        await db.insert('user_data', {
          'id': doc.id,
          'type': type,
          'amount': data['amount'],
          'split_by': null,
          'split_time': splitTime,
          'status': null,
          'paid_time': null,
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        final splitOn = data['splitted_on'] as List<dynamic>?;
        if (splitOn != null) {
          for (var split in splitOn) {
            final splitData = split as Map<String, dynamic>;

            // Convert timestamps to strings for split_on
            String paidTime = '';
            if (splitData['paid_time'] != null &&
                splitData['status'] == 'paid') {
              if (splitData['paid_time'] is Timestamp) {
                paidTime = (splitData['paid_time'] as Timestamp)
                    .toDate()
                    .toIso8601String();
              } else {
                paidTime = splitData['paid_time'].toString();
              }
            }

            await db.insert('split_on', {
              'user_data_id': doc.id,
              'mobile_no': splitData['mobile_no'],
              'amount': splitData['amount'],
              'status': splitData['status'],
              'paid_time': paidTime,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      }
    }

    // friends_data
    type = types[2];
    snapshot = await FirebaseFirestore.instance
        .collection('user_data')
        .doc(mobileNumber)
        .collection(type)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        await db.insert('friends_data', {
          'mobile_number': doc.id,
          'full_name': data['full_name'],
          'profile_picture': data['profile_picture'],
          'upi_id': data['upi_id'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    }
    catch(e){
      print('❌ Error syncing collection $type: $e');
    }
  }

  
}
