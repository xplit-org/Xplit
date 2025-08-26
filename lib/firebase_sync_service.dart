import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'logic/create_local_db.dart';
import 'logic/get_data.dart';

class FirebaseSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's mobile number
  static String? getCurrentUserMobile() {
    return _auth.currentUser?.phoneNumber;
  }

  /// Check if a mobile number exists in Firebase user_data collection
  static Future<bool> checkUserExistsInFirebase(String mobileNumber) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('user_details')
          .doc(mobileNumber)
          .get();

      if (doc.exists) {
        print('✅ User exists in Firebase: $mobileNumber');
        return true;
      } else {
        print('❌ User does not exist in Firebase: $mobileNumber');
        return false;
      }
    } catch (e) {
      print('❌ Error checking user existence in Firebase: $e');
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
      final userDetails = await GetData.getUserDetails(sender_mobile);
      
      // Add to Firebase friend_requests collection
      await _firestore.collection('user_data')
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

      await _firestore.collection('user_data')
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
      final currentUserMobile = getCurrentUserMobile();
      if (currentUserMobile == null) {
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
      print('❌ Error getting pending friend requests: $e');
      return [];
    }
  }

  /// Listen for incoming friend requests in real-time
  static Stream<QuerySnapshot> listenForIncomingRequests() {
    final currentUserMobile = getCurrentUserMobile();
    if (currentUserMobile == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('user_data')
        .doc(currentUserMobile)
        .collection('friend_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  /// Sync incoming friend requests from Firebase to local database
  static Future<void> syncIncomingFriendRequests() async {
    try {
      final currentUserMobile = getCurrentUserMobile();
      if (currentUserMobile == null) return;

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
        
        // Check if already exists in local database
        final List<Map<String, dynamic>> existingRequests = await db.query(
          'friend_requests',
          where: 'sender_mobile = ? AND receiver_mobile = ? AND status = ?',
          whereArgs: [data['sender_mobile'], data['receiver_mobile'], 'pending'],
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
              .update({
            'local_synced': true,
          });
      }
    } catch (e) {
      print('Error syncing incoming friend requests: $e');
    }
  }

  /// Start listening for new friend requests and sync them automatically
  static Stream<void> startFriendRequestListener() {
    final currentUserMobile = getCurrentUserMobile();
    if (currentUserMobile == null) {
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
            await syncIncomingFriendRequests();
          }
        });
  }
} 