import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';
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
            // print({
            //   {
            //     'mobile_no': split['mobile_no'],
            //     'amount': split['amount'],
            //     'status': split['status'],
            //     'paid_time': split['paid_time'],
            //   }
            // });
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
      final List<Map<String, dynamic>> results = await db.query(
        AppConstants.TABLE_USER,
        where: '${AppConstants.COL_MOBILE_NUMBER} = ?',
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
      if (hour == 0) {
        timeStr = '12.${minute.toString().padLeft(2, '0')} am';
      } else if (hour == 12) {
        timeStr = '12.${minute.toString().padLeft(2, '0')} pm';
      } else if (hour > 12) {
        timeStr = '${hour - 12}.${minute.toString().padLeft(2, '0')} pm';
      } else {
        timeStr = '$hour.${minute.toString().padLeft(2, '0')} am';
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
        AppConstants.TABLE_FRIENDS_DATA,
        where: '${AppConstants.COL_MOBILE_NUMBER} = ?',
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

  /// Get a list of all friends from the local database
  static Future<List<Map<String, dynamic>>> getFriendsList() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(AppConstants.TABLE_FRIENDS_DATA);
      return results;
    } catch (e) {
      print('Error getting friends list: $e');
      return [];
    }
  }

  /// Get total expenses
  static Future<Map<String, dynamic>> getTotalExpense() async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> owedToMe = await db.rawQuery('''
        SELECT s.*, u.${AppConstants.COL_SPLIT_TIME}, totals.total_amount
        FROM ${AppConstants.TABLE_SPLIT_ON} s
        JOIN ${AppConstants.TABLE_USER_DATA} u
          ON s.${AppConstants.COL_USER_DATA_ID} = u.${AppConstants.COL_ID}
        JOIN (
          SELECT ${AppConstants.COL_MOBILE_NO},
          SUM(${AppConstants.COL_AMOUNT}) as total_amount
          FROM ${AppConstants.TABLE_SPLIT_ON}
          WHERE ${AppConstants.COL_STATUS} = '${AppConstants.STATUS_UNPAID}'
          GROUP BY ${AppConstants.COL_MOBILE_NO}
        ) 
        totals 
          ON s.${AppConstants.COL_MOBILE_NO} = totals.${AppConstants.COL_MOBILE_NO}
        WHERE s.${AppConstants.COL_STATUS} = '${AppConstants.STATUS_UNPAID}'
        ORDER BY s.${AppConstants.COL_MOBILE_NO} ASC,
        u.${AppConstants.COL_SPLIT_TIME} ASC
      ''');

      if (owedToMe.isNotEmpty) {
        for (var result in owedToMe) {
          print("split_on_data\n");
          print({ 
                    'id': result['id'],
                    'user_data_id': result['user_data_id'],
                    'mobile_no': result['mobile_no'],
                    'amount': result['amount'],
                    'status': result['status'],
                    'paid_time': result['paid_time'],
                    'total_amount': result['total_amount'],
                    'split_time': result['split_time'],
          });
        }
      }

      final List<Map<String, dynamic>> owedByMe = await db.rawQuery('''
        SELECT u.*, totals.total_amount 
        FROM ${AppConstants.TABLE_USER_DATA} u
        JOIN (
          SELECT ${AppConstants.COL_SPLIT_BY},
          SUM(${AppConstants.COL_AMOUNT}) as total_amount
          FROM ${AppConstants.TABLE_USER_DATA}
          WHERE ${AppConstants.COL_STATUS} = '${AppConstants.STATUS_UNPAID}'
          GROUP BY ${AppConstants.COL_SPLIT_BY}
        ) 
        totals ON u.${AppConstants.COL_SPLIT_BY} = totals.${AppConstants.COL_SPLIT_BY}
        WHERE u.${AppConstants.COL_STATUS} = '${AppConstants.STATUS_UNPAID}'
        ORDER BY u.${AppConstants.COL_SPLIT_BY} ASC,
        u.${AppConstants.COL_SPLIT_TIME} ASC
      ''');

      if (owedByMe.isNotEmpty) {
        for (var result in owedByMe) {
          print("user_data\n");
          print({ 
                    'id': result['id'],
                    'type': result['type'],
                    'amount': result['amount'],
                    'split_by': result['split_by'],
                    'split_time': result['split_time'],
                    'status': result['status'],
                    'paid_time': result['paid_time'],
                    'total_amount': result['total_amount'],
          });
        }
      }

      Map<String, Map<String, dynamic>> totalAdjustedExpenses = {};
      String key = '';
      Map<String, dynamic> request = {};
      
      // type=0 for OwedByMe and type=1 for OwedToMe
      void putRequest(int type, int index){
        if(type == 1){
          key = owedToMe[index][AppConstants.COL_MOBILE_NO].toString();
          if (totalAdjustedExpenses.containsKey(key)) {
            totalAdjustedExpenses[key]!['total_amount'] += (owedToMe[index][AppConstants.COL_AMOUNT] as num? ?? 0.0);
            totalAdjustedExpenses[key]!['total_request'] += 1;
            request = {
              'type': 'type_1',
              'user_data_id': owedToMe[index][AppConstants.COL_USER_DATA_ID],
              'amount': owedToMe[index][AppConstants.COL_AMOUNT],
              'split_time': owedToMe[index][AppConstants.COL_SPLIT_TIME],
              'requested_by': 'Me',
            };
            totalAdjustedExpenses[key]!['request'].add(request);
          }
        }
        else if(type == 0){
          key = owedByMe[index][AppConstants.COL_SPLIT_BY].toString();
          if (totalAdjustedExpenses.containsKey(key)) {
            totalAdjustedExpenses[key]!['total_amount'] -= (owedByMe[index][AppConstants.COL_AMOUNT] as num? ?? 0.0);
            totalAdjustedExpenses[key]!['total_request'] += 1;
            request = {
              'type': 'type_0',
              'user_data_id': owedByMe[index][AppConstants.COL_ID],
              'amount': owedByMe[index][AppConstants.COL_AMOUNT],
              'split_time': owedByMe[index][AppConstants.COL_SPLIT_TIME],
              'requested_by': totalAdjustedExpenses[key]!['full_name'],
            };
            totalAdjustedExpenses[key]!['request'].add(request);
          }
        }
      }
      
      Future<void> initKey (int type, int index) async{
        if(type == 1){
          key = owedToMe[index][AppConstants.COL_MOBILE_NO].toString();
        }
        else if(type == 0){
          key = owedByMe[index][AppConstants.COL_SPLIT_BY].toString();
        }
        final friendData = await getFriendByMobile(key);
        List<Map<String, dynamic>> request = [];
        // collect other data for this mobile number
        totalAdjustedExpenses[key] = {
          'full_name': friendData?['full_name'] ?? 'Unknown',
          'profile_picture': friendData?['profile_picture'] ?? 'assets/image 5.png',
          'total_amount': 0.0,
          'total_request': 0,
          'request': request,
        };
      }

      // Merge the two lists to create the final data
      // Using 2 pointer method
      int i = 0; // index for owedToMe
      int j = 0; // index for owedByMe
      while (i < owedToMe.length && j < owedByMe.length) {
        // Both request for same friend
        if(owedToMe[i][AppConstants.COL_MOBILE_NO].toString() == owedByMe[j][AppConstants.COL_SPLIT_BY].toString()) {          
          // Put the request for older time first
          if(isTimeBefore(owedToMe[i][AppConstants.COL_SPLIT_TIME], owedByMe[j][AppConstants.COL_SPLIT_TIME])) {
            key = owedToMe[i][AppConstants.COL_MOBILE_NO].toString();
            // Check if friend had a record in totalAdjustedExpenses
            if(!totalAdjustedExpenses.containsKey(key)) {
              await initKey(1, i);
            }
            putRequest(1, i);   
            i++;
          }
          else {
            key = owedByMe[j][AppConstants.COL_SPLIT_BY].toString();
            // Check if friend had a record in totalAdjustedExpenses
            if(!totalAdjustedExpenses.containsKey(key)) {
              await initKey(0, j);
            }
            putRequest(0, j);
            j++;
          }
        // Both request for different friend
        } else if (owedToMe[i][AppConstants.COL_MOBILE_NO].toString().compareTo(owedByMe[j][AppConstants.COL_SPLIT_BY].toString()) < 0) {
          key = owedToMe[i][AppConstants.COL_MOBILE_NO].toString();
          // Check if friend had a record in totalAdjustedExpenses
          // Put the request for ith
          if(totalAdjustedExpenses.containsKey(key)){
            putRequest(1, i);
          // Don't have record, create a new record and put ith request
          }else {
            await initKey(1, i);
            putRequest(1, i);
          }
          i++;
        // Both request for different friend
        }else{
          key = owedByMe[j][AppConstants.COL_SPLIT_BY].toString();
          // Check if friend had a record in totalAdjustedExpenses
          // Put the request for jth
          if(totalAdjustedExpenses.containsKey(key)){
            putRequest(0, j);
          // Don't have record, create a new record and put jth request
          }else {
            await initKey(0, j);
            putRequest(0, j);
          }
          j++;
        }
      }
      // put remaining data
      while (i < owedToMe.length){
        key = owedToMe[i][AppConstants.COL_MOBILE_NO].toString();
        // Check if friend had a record in totalAdjustedExpenses
        // Put the request for ith
        if(totalAdjustedExpenses.containsKey(key)){
          putRequest(1, i);
        // Don't have record, create a new record and put ith request
        }else {
          await initKey(1, i);
          putRequest(1, i);
        }
        i++;
      }
      while (j < owedByMe.length){
        key = owedByMe[j][AppConstants.COL_SPLIT_BY].toString();
        // Check if friend had a record in totalAdjustedExpenses
        // Put the request for jth
        if(totalAdjustedExpenses.containsKey(key)){
          putRequest(0, j);
        // Don't have record, create a new record and put jth request
        }else {
          await initKey(0, j);
          putRequest(0, j);
        }
        j++;
      }

      return totalAdjustedExpenses;
    } catch (e) {
      print('Error Total Adjusted data: $e');
      return {};
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

  static bool isTimeBefore(String time1, String time2) {
    final DateTime dateTime1 = DateTime.parse(time1);
    final DateTime dateTime2 = DateTime.parse(time2);
    return dateTime1.isBefore(dateTime2);
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
