import 'package:sqflite/sqflite.dart';
import 'create_local_db.dart';

class GetData {
  static Future<Database> get database async {
    return await LocalDB.database;
  }

  /// Get all user_data sorted by date (nearest to today first)
  static Future<List<Map<String, dynamic>>> getAllUserData(
    String mobileNumber,
  ) async {
    try {
      final db = await database;

      // Query all user_data for the current user, sorted by date (nearest first)
      final List<Map<String, dynamic>> results = await db.rawQuery('''
          SELECT 
            *
            FROM user_data
            ORDER BY datetime(split_time) ASC
      ''');

      List<Map<String, dynamic>> allData = [];

      for (var result in results) {
        // Determine the type and format the data accordingly
        String type = result['type'] ?? '';
        String status = result['status'] ?? '';

        if (type == 'type_0') {
          // This is a request (paid or unpaid)
          String name = '';
          String profilePic = '';

          // Get friend details using split_by mobile number
          if (result['split_by'] != null) {
            final friendData = await getFriendByMobile(result['split_by']);
            if (friendData != null) {
              name = friendData['full_name'] ?? 'Unknown';
              profilePic =
                  friendData['profile_picture'] ?? 'assets/image 5.png';
            } else {
              name = 'Unknown';
              profilePic = 'assets/image 5.png';
            }
          } else {
            name = 'Unknown';
            profilePic = 'assets/image 5.png';
          }

          allData.add({
            'type': 0,
            'name': name,
            'profilePic': profilePic,
            'time': formatTimestamp(result['split_time']),
            'amount': result['amount'],
            'status': status == 'paid' ? 'Paid' : 'Unpaid',
            'paidTime': result['paid_time'] != null
                ? formatTimestamp(result['paid_time'])
                : null,
          });
        } else if (type == 'type_1') {
          // This is a split created by user
          // Get split details to calculate paid/unpaid counts
          final splitDetails = await getSplitDetails(result['id'] ?? '');

          int paidCount = 0;
          int totalCount = splitDetails.length;
          double remainingAmount = 0.0;

          for (var split in splitDetails) {
            if (split['status'] == 'paid') {
              paidCount++;
            } else {
              remainingAmount += (split['amount'] ?? 0.0);
            }
          }

          // Get current user details
          final userDetails = await getUserDetails(mobileNumber);

          allData.add({
            'type': 1,
            'name': userDetails['full_name'] ?? 'Unknown',
            'profilePic':
                userDetails['profile_picture'] ?? 'assets/image 5.png',
            'time': formatTimestamp(result['split_time']),
            'amount': result['amount'] ?? 0.0,
            'paidCount': paidCount,
            'totalCount': totalCount,
            'remainingAmount': remainingAmount,
          });
        }
      }

      return allData;
    } catch (e) {
      print('Error getting all user data: $e');
      return [];
    }
  }

  /// Get user details by mobile number
  static Future<Map<String, dynamic>> getUserDetails(
    String mobileNumber,
  ) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> results = await db.query(
        'user',
        where: 'mobile_number = ?',
        whereArgs: [mobileNumber],
      );

      if (results.isNotEmpty) {
        return results.first;
      }
      return {};
    } catch (e) {
      print('Error getting user details: $e');
      return {};
    }
  }

  /// Get split details for a specific user_data entry
  static Future<List<Map<String, dynamic>>> getSplitDetails(
    String userDataId,
  ) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> results = await db.query(
        'split_on',
        where: 'user_data_id = ?',
        whereArgs: [userDataId],
      );

      return results;
    } catch (e) {
      print('Error getting split details: $e');
      return [];
    }
  }

  /// Get user profile data
  static Future<Map<String, dynamic>> getUserProfile(
    String mobileNumber,
  ) async {
    try {
      final db = await database;
      print("Mobile Number: $mobileNumber");
      final List<Map<String, dynamic>> results = await db.query(
        'user',
        where: 'mobile_number = ?',
        whereArgs: [mobileNumber],
      );

      if (results.isNotEmpty) {
        return results.first;
      }
      return {};
    } catch (e) {
      print('Error getting user profile: $e');
      return {};
    }
  }

  /// Format time for display
  static String formatTime(String isoTime) {
    try {
      final DateTime dateTime = DateTime.parse(isoTime);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  /// Format timestamp to human readable format (e.g., "10.34 pm 10/03/25")
  static String formatTimestamp(String isoTime) {
    try {
      final DateTime dateTime = DateTime.parse(isoTime);

      // Format time (12-hour format with minutes)
      String timeStr = '';
      int hour = dateTime.hour;
      int minute = dateTime.minute;
      String period = hour >= 12 ? 'pm' : 'am';

      if (hour == 0) {
        timeStr = '12.${minute.toString().padLeft(2, '0')} am';
      } else if (hour == 12) {
        timeStr = '12.${minute.toString().padLeft(2, '0')} pm';
      } else if (hour > 12) {
        timeStr = '${hour - 12}.${minute.toString().padLeft(2, '0')} pm';
      } else {
        timeStr = '${hour}.${minute.toString().padLeft(2, '0')} am';
      }

      // Format date (DD/MM/YY)
      String dateStr =
          '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year.toString().substring(2)}';

      return '$timeStr $dateStr';
    } catch (e) {
      return 'Invalid time';
    }
  }

  /// Format amount for display
  static String formatAmount(double amount) {
    return '₹ ${amount.toStringAsFixed(2)}';
  }

  /// Get a specific friend by mobile number
  static Future<Map<String, dynamic>?> getFriendByMobile(
    String mobileNumber,
  ) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> results = await db.query(
        'friends_data',
        where: 'mobile_number = ?',
        whereArgs: [mobileNumber],
      );

      if (results.isNotEmpty) {
        return results.first;
      }
      return null;
    } catch (e) {
      print('Error getting friend data: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getFriendsList() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query('friends_data');
      return results;
    } catch (e) {
      print('Error getting friends list: $e');
      return [];
    }
  }

  static Future<List<String>> getRequestedMobile(String mobileNumber) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        'friend_requests',
        where: 'sender_mobile = ?', // you are the sender
        whereArgs: [mobileNumber],
      );

      // Extract only the numbers you sent requests to
      final List<String> requestedMobiles = results
          .map((row) => row['receiver_mobile'].toString())
          .toList();

      print('Mobiles you sent requests to: $requestedMobiles');
      return requestedMobiles;
    } catch (e) {
      print('Error getting sent requests: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getPendingRequest(
    String mobileNumber,
  ) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> results = await db.query(
        'friend_requests',
        where: 'receiver_mobile = ? AND local_synced = ?',
        whereArgs: [mobileNumber, false],
      );

      if (results.isNotEmpty) {
        return results.first;
      }
      return {};
    } catch (e) {
      print('Error getting pending request: $e');
      return {};
    }
  }

  /// Get all pending friend requests for the current user (from local DB)
  static Future<List<Map<String, dynamic>>> getPendingFriendRequests() async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> results = await db.query(
        'friend_requests',
        where: 'status = ?',
        whereArgs: ['pending'],
        orderBy: 'datetime(created_at) DESC',
      );

      return results;
    } catch (e) {
      print('Error getting pending friend requests: $e');
      return [];
    }
  }
}
