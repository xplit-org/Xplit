import 'package:expenser/core/utils.dart';
import 'package:expenser/models/create_local_db.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenser/core/get_local_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsRequestPage extends StatefulWidget {
  final List<Map<String, dynamic>> pendingRequests;
  const FriendsRequestPage({super.key, required this.pendingRequests});

  @override
  State<FriendsRequestPage> createState() => _FriendsRequestPageState();

  // Static method to get pending friend requests count
  static List<Map<String, dynamic>> getPendingRequests() {
    final pendingRequests = _FriendsRequestPageState._friendRequests
        .where((req) => req['status'] == 'pending')
        .toList();
    print('Pending requests count: ${pendingRequests.length}');
    return pendingRequests;
  }
}

class _FriendsRequestPageState extends State<FriendsRequestPage> {
  static List<Map<String, dynamic>> _friendRequests = [];
  @override
  void initState() {
    super.initState();
    // Initialize from passed-in data
    _friendRequests = List<Map<String, dynamic>>.from(widget.pendingRequests);
  }

  String _getTimeAgo(String timestampStr) {
    final timestamp = DateTime.tryParse(timestampStr) ?? DateTime.now();
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _acceptRequest(int requestId) async {
    final db = await LocalDB.database;
    await db.update(
      'friend_requests',
      {'status': 'accepted'},
      where: 'id = ?',
      whereArgs: [requestId],
    );

    // Insert the accepted friend into the friends_data table using data from friend_requests
    // Fetch the friend request row
    final List<Map<String, dynamic>> requestRows = await db.query(
      'friend_requests',
      where: 'id = ?',
      whereArgs: [requestId],
      limit: 1,
    );
    if (requestRows.isNotEmpty) {
      final request = requestRows.first;
      // Insert into friends_data
      await db.insert(
        'friends_data',
        {
          'mobile_number': request['sender_mobile'],
          'full_name': request['full_name'],
          'profile_picture': request['profile_picture'],
          'upi_id': request['upi_id'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // Update the status in Firestore and add to friends collection
      try {
        // Assuming you have access to FirebaseFirestore and current user's mobile number
        final firestore = FirebaseFirestore.instance;
        final currentUserMobile = FirebaseAuth.instance.currentUser?.phoneNumber;
        final currentUser = await GetLocalData.getUserProfile();
        // Get the accepted request details
        final senderMobile = requestRows.first['sender_mobile'];
        // Update the status in the friend_requests subcollection for the current user
        await firestore
            .collection('user_data')
            .doc(senderMobile)
            .collection('friends_data')
            .doc(currentUserMobile)
            .set({
              'full_name': currentUser['full_name'],
              'profile_picture': currentUser['profile_picture'],
              'upi_id': currentUser['upi_id'],
        });

        await firestore
            .collection('user_data')
            .doc(currentUserMobile)
            .collection('friends_data')
            .doc(senderMobile)
            .set({
              'full_name': request['full_name'],
              'profile_picture': request['profile_picture'],
              'upi_id': request['upi_id'],
        });
      } catch (e) {
        print('Error updating Firestore friend status: $e');
      }
    }

    setState(() {
      _friendRequests.removeWhere((req) => req['id'] == requestId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Friend request accepted!'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _declineRequest(int requestId) async {
    final db = await LocalDB.database;
    await db.update(
      'friend_requests',
      {'status': 'rejected'},
      where: 'id = ?',
      whereArgs: [requestId],
    );

    setState(() {
      _friendRequests.removeWhere((req) => req['id'] == requestId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Friend request declined'),
        backgroundColor: Colors.orange[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingRequests =
        _friendRequests.where((req) => req['status'] == 'pending').toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Friend Requests',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: pendingRequests.isEmpty
          ? _buildEmptyState()
          : _buildRequestsList(pendingRequests),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No Friend Requests',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You don\'t have any pending friend requests',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(List<Map<String, dynamic>> requests) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Builder(
                  builder: (context) {
                    final imageProvider = Utils.getProfileImageProvider(request["profile_picture"]);
                    return CircleAvatar(
                      radius: 25,
                      backgroundImage: imageProvider,
                      child: imageProvider == null ? const Icon(Icons.person) : null,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['full_name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request['sender_mobile'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getTimeAgo(request['created_at'] ?? ''),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            onPressed: () =>
                                _declineRequest(request['id'] as int),
                            icon: Icon(
                              Icons.close,
                              color: Colors.red[600],
                              size: 16,
                            ),
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            onPressed: () =>
                                _acceptRequest(request['id'] as int),
                            icon: Icon(
                              Icons.check,
                              color: Colors.green[600],
                              size: 16,
                            ),
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
