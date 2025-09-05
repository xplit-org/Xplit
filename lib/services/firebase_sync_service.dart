import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenser/models/create_local_db.dart';
import 'package:expenser/core/get_local_data.dart';
import 'package:flutter/material.dart';
import 'friend_request_notification_service.dart';
import 'package:expenser/screens/split_now/select_friends.dart';
import 'expense_notification_service.dart';
import 'package:expenser/core/get_firebase_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:expenser/core/app_constants.dart';
import 'dart:math';

class FirebaseSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final getFirebase = GetFirebaseData();

  /// Check if a mobile number exists in Firebase user_data collection
  static Future<bool> checkUserExistsInFirebase(String mobileNumber) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('user_details')
          .doc(mobileNumber)
          .get();

      if (doc.exists) {
        print('User exists in Firebase: $mobileNumber');
        return true;
      } else {
        print('User does not exist in Firebase: $mobileNumber');
        return false;
      }
    } catch (e) {
      print('Error checking user existence in Firebase: $e');
      return false;
    }
  }

  /// Sync friend request from SQLite to Firebase
  static Future<bool> syncFriendRequestToFirebase({
    required String sender_mobile,
    required String receiver_mobile,
    required String full_name,
    required String id,
    required String created_at,
  }) async {
    try {
      final db = await LocalDB.database;
      // Get user details first
      final userDetails = await GetLocalData.getUserProfile();

      // Add to Firebase friend_requests collection
      await _firestore
          .collection('user_data')
          .doc(sender_mobile)
          .collection('friend_requests')
          .doc(id)
          .set({
            'sender_mobile': sender_mobile,
            'receiver_mobile': receiver_mobile,
            'full_name': full_name,
            'profile_picture': userDetails['profile_picture'],
            'upi_id': userDetails['upi_id'],
            'status': 'pending',
            'created_at': created_at,
            'local_synced': true,
          });

      await _firestore
          .collection('user_data')
          .doc(receiver_mobile)
          .collection('friend_requests')
          .doc(id)
          .set({
            'sender_mobile': sender_mobile,
            'receiver_mobile': receiver_mobile,
            'full_name': full_name,
            'profile_picture': userDetails['profile_picture'],
            'upi_id': userDetails['upi_id'] ?? '',
            'status': 'pending',
            'created_at': created_at,
            'local_synced': false, // Mark as synced from local DB
          });

      // Insert sender as friend for receiver in local database
      await db.insert('friend_requests', {
        'sender_mobile': sender_mobile,
        'receiver_mobile': receiver_mobile,
        'full_name': full_name,
        'profile_picture': userDetails['profile_picture'],
        'upi_id': userDetails['upi_id'],
        'status': 'pending',
        'created_at': created_at,
        'local_synced': true, // Mark as synced from local DB
      });

      print('Friend request synced to Firebase successfully');
      return true;
    } catch (e) {
      print('Error syncing friend request to Firebase: $e');
      return false;
    }
  }

  /// Get pending friend requests for current user from Firebase
  static Future<List<Map<String, dynamic>>> getPendingFriendRequests() async {
    try {
      final currentUserMobile = getFirebase.getCurrentUserMobile();
      if (currentUserMobile == "") {
        return [];
      }

      final QuerySnapshot snapshot = await _firestore
          .collection('user_data')
          .doc(currentUserMobile)
          .collection('friend_requests')
          .where('local_synced', isEqualTo: false)
          .get();

      List<Map<String, dynamic>> requests = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        requests.add({
          'id': doc.id,
          'sender_mobile': data['sender_mobile'],
          'receiver_mobile': data['receiver_mobile'],
          'full_name': data['full_name'],
          'profile_picture': data['profile_picture'],
          'upi_id': data['upi_id'],
          'status': data['status'],
          'timestamp': data['timestamp'],
        });
      }

      print('📨 Pending friend requests from Firebase: ${requests.length}');
      return requests;
    } catch (e) {
      print('Error getting pending friend requests: $e');
      return [];
    }
  }

  /// Start listening for new friend requests and sync them automatically
  static Stream<void> startFriendRequestListener() {
    final currentUserMobile = getFirebase.getCurrentUserMobile();
    if (currentUserMobile == "") {
      return Stream.empty();
    }

    return _firestore
        .collection('user_data')
        .doc(currentUserMobile)
        .collection('friend_requests')
        .where('local_synced', isEqualTo: false)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isNotEmpty) {
            await _syncIncomingFriendRequests();
          }
        });
  }

  /// Sync incoming friend requests from Firebase to local database
  static Future<void> _syncIncomingFriendRequests() async {
    try {
      final currentUserMobile = getFirebase.getCurrentUserMobile();
      if (currentUserMobile == "") return;

      final db = await LocalDB.database;

      // Get all friend requests with local_synced = false
      final QuerySnapshot snapshot = await _firestore
          .collection('user_data')
          .doc(currentUserMobile)
          .collection('friend_requests')
          .where('local_synced', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Send Notification on drawer
        await FriendRequestNotificationService().showFriendRequestNotification(
          name: data['full_name'],
          mobile: data['sender_mobile'],
        );

        // Check if already exists in local database
        final List<Map<String, dynamic>> existingRequests = await db.query(
          'friend_requests',
          where: 'sender_mobile = ? AND receiver_mobile = ? AND status = ?',
          whereArgs: [
            data['sender_mobile'],
            data['receiver_mobile'],
            'pending',
          ],
        );

        if (existingRequests.isEmpty) {
          // Insert into local database
          await db.insert('friend_requests', {
            'sender_mobile': data['sender_mobile'],
            'receiver_mobile': data['receiver_mobile'],
            'full_name': data['full_name'],
            'profile_picture': data['profile_picture'],
            'upi_id': data['upi_id'],
            'status': 'pending',
            'created_at': data['created_at'],
          });
        }

        print('New friend request synced to local DB: ${data['full_name']}');

        // Mark as synced in Firebase
        await _firestore
            .collection('user_data')
            .doc(currentUserMobile)
            .collection('friend_requests')
            .doc(doc.id)
            .update({'local_synced': true});
      }
    } catch (e) {
      print('Error syncing incoming friend requests: $e');
    }
  }

  /// Start listening for new expenses (type_0) and sync them automatically
  static Stream<void> startExpenseSyncListener() {
    final currentUserMobile = getFirebase.getCurrentUserMobile();
    if (currentUserMobile == "") {
      return Stream.empty();
    }

    return _firestore
        .collection('user_data')
        .doc(currentUserMobile)
        .collection('type_0')
        .where('local_synced', isEqualTo: false)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isNotEmpty) {
            await _syncIncomingExpenses();
          }
        });
  }

  /// Sync incoming expenses from Firebase to local database
  static Future<void> _syncIncomingExpenses() async {
    try {
      final currentUserMobile = getFirebase.getCurrentUserMobile();
      if (currentUserMobile == "") return;

      final db = await LocalDB.database;

      // Get all expenses with local_synced = false
      final QuerySnapshot snapshot = await _firestore
          .collection('user_data')
          .doc(currentUserMobile)
          .collection('type_0')
          .where('local_synced', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Send notification about the split request
        await ExpenseNotificationService().showExpenseNotification(
          amount: data['amount']?.toString() ?? '0',
          splitBy: data['split_by'] ?? 'Unknown',
        );

        // Check if already exists in local database
        final List<Map<String, dynamic>> existingExpenses = await db.query(
          'user_data',
          where: 'id = ? AND type = ?',
          whereArgs: [doc.id, 'type_0'],
        );

        if (existingExpenses.isEmpty) {
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

          // Insert into local database
          await db.insert('user_data', {
            'id': doc.id,
            'type': 'type_0',
            'amount': data['amount'] ?? 0.0,
            'split_by': data['split_by'],
            'split_time': splitTime,
            'status': data['status'],
            'paid_time': null,
          });

          print('New expense synced to local DB: ${doc.id}');
        }

        // Update to_pay in user table
        final currentUser = await db.query(
          'user',
          where: 'mobile_number = ?',
          whereArgs: [currentUserMobile],
        );

        if (currentUser.isNotEmpty) {
          final currentToPay = (currentUser.first['to_pay'] as num?) ?? 0.0;
          final expenseAmount = (data['amount'] as num?) ?? 0.0;
          final newToPay = currentToPay + expenseAmount;

          await db.update(
            'user',
            {'to_pay': newToPay},
            where: 'mobile_number = ?',
            whereArgs: [currentUserMobile],
          );

          print(
            'Updated to_pay for user $currentUserMobile: $currentToPay -> $newToPay',
          );
        }

        // Mark as synced in Firebase
        await _firestore
            .collection('user_data')
            .doc(currentUserMobile)
            .collection('type_0')
            .doc(doc.id)
            .update({'local_synced': true});
      }
    } catch (e) {
      print('Error syncing incoming expenses: $e');
    }
  }

  /// Sync firebase to local on login/signup
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
    try {
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
    } catch (e) {
      print('Error syncing collection $type: $e');
    }
  }

  // Generate a unique ID for the split with database check
  static Future<String> _generateUniqueSplitId() async {
    final db = await LocalDB.database;
    String splitId;
    bool isUnique = false;
    int attempts = 0;
    const maxAttempts = 10;

    do {
      // Generate a UUID-like string
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random();
      final randomPart = random.nextInt(999999).toString().padLeft(6, '0');
      splitId = 'split_${timestamp}_$randomPart';

      // Check if this ID already exists in the database
      final List<Map<String, dynamic>> existing = await db.query(
        'user_data',
        where: 'id = ?',
        whereArgs: [splitId],
      );

      isUnique = existing.isEmpty;
      attempts++;

      if (!isUnique && attempts < maxAttempts) {
        // Wait a bit before trying again to ensure timestamp changes
        await Future.delayed(Duration(milliseconds: 10));
      }
    } while (!isUnique && attempts < maxAttempts);

    if (!isUnique) {
      // Fallback: use timestamp with microsecond precision
      final now = DateTime.now();
      splitId = 'split_${now.microsecondsSinceEpoch}_${Random().nextInt(9999)}';
    }

    print('Generated unique split ID: $splitId');
    return splitId;
  }

  /// Save split data to local database and Firebase
  static Future<String> saveSplitToDatabase({
    required double totalAmount,
    required List<Friend> selectedFriends,
    required Map<String, TextEditingController> amountControllers,
  }) async {
    final String currentUserMobile = getFirebase.getCurrentUserMobile();
    try {
      final db = await LocalDB.database;

      if (currentUserMobile == "") {
        throw Exception('User not logged in');
      }

      // Generate unique ID for this split
      final splitId = await _generateUniqueSplitId();
      final currentTime = DateTime.now().toIso8601String();

      // 1. Insert main split record into user_data table
      await db.insert(AppConstants.TABLE_USER_DATA, {
        AppConstants.COL_ID: splitId,
        AppConstants.COL_TYPE: AppConstants.TYPE_1, // Split by me
        AppConstants.COL_AMOUNT: totalAmount,
        AppConstants.COL_SPLIT_BY: null,
        AppConstants.COL_SPLIT_TIME: currentTime,
        AppConstants.COL_STATUS: null,
        AppConstants.COL_PAID_TIME: null,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      double update_to_get = 0;
      List<Map<String, dynamic>> splitOnRecords = [];

      // 2. Insert individual split records into split_on table
      for (var friend in selectedFriends) {
        final amount =
            double.tryParse(amountControllers[friend.id]?.text ?? '0') ?? 0.0;

        // Check if this friend is the current user
        final isCurrentUser = friend.id == currentUserMobile;
        if (!isCurrentUser) {
          update_to_get += amount;
        }

        await db.insert(
          AppConstants.TABLE_SPLIT_ON,
          {
            AppConstants.COL_USER_DATA_ID: splitId,
            AppConstants.COL_MOBILE_NO: friend.id,
            AppConstants.COL_AMOUNT: amount,
            AppConstants.COL_STATUS: isCurrentUser
                ? AppConstants.STATUS_PAID
                : AppConstants.STATUS_UNPAID, // Current user is marked as paid
            AppConstants.COL_PAID_TIME: isCurrentUser ? currentTime : null,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // For each friend (except current user), insert a payment request in their type_0 (owed_by_me) in Firebase
        if (!isCurrentUser && amount > 0) {
          try {
            await FirebaseFirestore.instance
                .collection('user_data')
                .doc(friend.id)
                .collection('type_0')
                .add({
                  'amount': amount,
                  'split_time': currentTime,
                  'split_by': currentUserMobile,
                  'status': AppConstants.STATUS_UNPAID,
                  'local_synced': false,
                });
            print('Payment request added to type_0 for ${friend.id}');
          } catch (e) {
            print(
              'Warning: Failed to add payment request to type_0 for ${friend.id}: $e',
            );
          }
        }

        splitOnRecords.add({
          AppConstants.COL_MOBILE_NO: friend.id,
          AppConstants.COL_AMOUNT: amount,
          AppConstants.COL_STATUS: isCurrentUser
              ? AppConstants.STATUS_PAID
              : AppConstants.STATUS_UNPAID, // Current user is marked as paid
          AppConstants.COL_PAID_TIME: isCurrentUser ? currentTime : null,
        });
      }

      // 1.1. Also save to Firebase user_data collection
      try {
        await FirebaseFirestore.instance
            .collection('user_data')
            .doc(currentUserMobile)
            .collection('type_1')
            .doc(splitId)
            .set({
              'amount': totalAmount,
              'split_time': currentTime,
              'splitted_on': splitOnRecords,
            });
        print('Firebase user_data updated successfully');
      } catch (firebaseError) {
        print('Warning: Firebase user_data update failed: $firebaseError');
        // Continue with local save even if Firebase fails
      }

      // Update to_get
      if (update_to_get > 0) {
        final userProfile = await GetLocalData.getUserProfile();
        update_to_get += userProfile['to_get'];
        await db.update(
          'user',
          {'to_get': update_to_get},
          where: 'mobile_number = ?',
          whereArgs: [currentUserMobile],
        );

        // 2.2. Also update Firebase user profile
        try {
          await FirebaseFirestore.instance
              .collection('user_details')
              .doc(currentUserMobile)
              .update({'to_get': update_to_get});
          print('Firebase user profile updated successfully');
        } catch (firebaseError) {
          print('Warning: Firebase user profile update failed: $firebaseError');
        }
      }

      // 3. If current user is not in selected friends, add them with their share as paid
      final currentUserInList = selectedFriends.any(
        (friend) => friend.id == currentUserMobile,
      );
      if (!currentUserInList) {
        // Calculate current user's share (total amount minus what others owe)
        double othersTotal = 0.0;
        for (var friend in selectedFriends) {
          final amount =
              double.tryParse(amountControllers[friend.id]?.text ?? '0') ?? 0.0;
          othersTotal += amount;
        }
        final currentUserShare = totalAmount - othersTotal;

        if (currentUserShare > 0) {
          await db.insert(
            AppConstants.TABLE_SPLIT_ON,
            {
              AppConstants.COL_USER_DATA_ID: splitId,
              AppConstants.COL_MOBILE_NO: currentUserMobile,
              AppConstants.COL_AMOUNT: currentUserShare,
              AppConstants.COL_STATUS:
                  AppConstants.STATUS_PAID, // Current user is marked as paid
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      print('Split data saved successfully with ID: $splitId');
      return 'SUCCESS';
    } catch (e) {
      return 'ERROR';
    }
  }
}
