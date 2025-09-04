import 'package:flutter/material.dart';
import 'dart:convert';
import 'logic/get_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OwedToMeExpensesPage extends StatefulWidget {
  final String userName;
  final int totalAmount;
  final int requestCount;
  final String profilePicture;
  final List<Map<String, dynamic>> requests;

  const OwedToMeExpensesPage({
    Key? key,
    required this.userName,
    required this.totalAmount,
    required this.requestCount,
    required this.profilePicture,
    required this.requests,
  }) : super(key: key);

  @override
  State<OwedToMeExpensesPage> createState() => _OwedToMeExpensesPageState();
  }

class _OwedToMeExpensesPageState extends State<OwedToMeExpensesPage> {
  String? currentUserName;
  String? currentUserProfilePic;
  ImageProvider? _cachedProfileImage;
  ImageProvider? _cachedCurrentUserImage;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserDetails();
    _cacheProfileImages();
  }

  Future<void> _loadCurrentUserDetails() async {
    try {
      String currentUserMobileNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? "";
      
      final userDetails = await GetData.getUserDetails(currentUserMobileNumber);
      setState(() {
        currentUserName = userDetails['full_name'] ?? 'Unknown';
        currentUserProfilePic = userDetails['profile_picture'] ?? 'assets/image 5.png';
      });
      _cacheCurrentUserImage();
    } catch (e) {
      print('Error loading current user details: $e');
      setState(() {
        currentUserName = 'Unknown';
        currentUserProfilePic = 'assets/image 5.png';
      });
    }
  }

  void _cacheProfileImages() {
    _cachedProfileImage = _createImageProvider(widget.profilePicture);
  }

  void _cacheCurrentUserImage() {
    if (currentUserProfilePic != null) {
      _cachedCurrentUserImage = _createImageProvider(currentUserProfilePic!);
      setState(() {}); // Trigger rebuild to show the cached image
    }
  }

  // Helper function to create ImageProvider for profile pictures
  ImageProvider? _createImageProvider(String? profilePicture) {
    if (profilePicture == null || profilePicture.isEmpty) {
      return null;
    }
    
    // Check if it's a base64 image
    if (profilePicture.startsWith('data:image/')) {
      try {
        // Extract base64 data from the data URL
        final base64Data = profilePicture.split(',')[1];
        final bytes = base64Decode(base64Data);
        return MemoryImage(bytes);
      } catch (e) {
        print('Error decoding base64 image: $e');
        return null;
      }
    }
    
    // Check if it's a network URL
    if (profilePicture.startsWith('http://') || profilePicture.startsWith('https://')) {
      return NetworkImage(profilePicture);
    }
    
    // If it's a local asset path
    if (profilePicture.startsWith('assets/')) {
      return AssetImage(profilePicture);
    }
    
    return null;
  }

  // Convert the requests data to the format expected by the UI
  List<Map<String, dynamic>> getExpenseRequests() {
    return widget.requests.map((request) {
      // Parse the split_time to get a formatted date
      String date = "Unknown";
      try {
        if (request['split_time'] != null) {
          final DateTime dateTime = DateTime.parse(request['split_time']);
          date = "${dateTime.day} ${_getMonthName(dateTime.month)}";
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
      
      return {
        "date": date,
        "amount": request['amount'] ?? 0.0,
        "description": request['requested_by'] ?? "Unknown",
        "type": request['type'] ?? "unknown",
        "user_data_id": request['user_data_id'] ?? "",
      };
    }).toList();
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final expenseRequests = getExpenseRequests();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Owed to me",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        
      ),
      body: Column(
        children: [
          // User info section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _cachedProfileImage,
                  backgroundColor: Colors.lightBlue,
                  child: _cachedProfileImage == null
                      ? Text(
                          widget.userName.split(' ').map((e) => e[0]).join(''),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                
                // User name and owes text
                Text(
                  "${widget.userName} owes you",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Total amount
                Text(
                  "₹${widget.totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Divider
                const Divider(height: 1),
                const SizedBox(height: 20),
                
                // Filter buttons
                
              ],
            ),
          ),
          
          // Expense requests list
          Expanded(
            child: expenseRequests.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: expenseRequests.length,
                    itemBuilder: (context, index) {
                      final request = expenseRequests[index];
                      return _buildExpenseRequestItem(request);
                    },
                  ),
          ),
        ],
      ),
    );
  }


  Widget _buildExpenseRequestItem(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Profile picture
          Builder(
            builder: (context) {
              ImageProvider? avatarImageProvider;
              String avatarName;

              if (request["type"] == "type_0") {
                // Use current user's profile picture and name
                avatarImageProvider = _cachedProfileImage;
                avatarName = widget.userName;
              } else {
                // Use the request's profile picture and name if available
                avatarImageProvider = _cachedCurrentUserImage;
                avatarName = currentUserName ?? "";
              }

              return CircleAvatar(
                radius: 20,
                backgroundImage: avatarImageProvider,
                backgroundColor: Colors.lightBlue,
                child: avatarImageProvider == null
                    ? Text(
                        avatarName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join(''),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              );
            },
          ),
          const SizedBox(width: 12),
          
          // Request details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First line: Split Request + Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      request["type"] == "type_1" ? "Split request" : "Payment request",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      request["date"],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                                 // Second line: Requested by + Amount
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Expanded(
                       child: Text(
                         "Requested by ${request["description"]}",
                         style: TextStyle(
                           fontSize: 14,
                           color: Colors.grey[600],
                         ),
                         overflow: TextOverflow.ellipsis,
                         maxLines: 1,
                       ),
                     ),
                     const SizedBox(width: 8),
                     Text(
                       "₹${request["amount"].toStringAsFixed(2)}",
                       style: TextStyle(
                         fontSize: 16,
                         fontWeight: FontWeight.bold,
                         color: request["type"] == "type_1" ? Colors.green : Colors.red,
                       ),
                     ),
                   ],
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/null.jpg',
            height: 150,
            width: 150,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            'No expense requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No pending expense requests from this user',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}