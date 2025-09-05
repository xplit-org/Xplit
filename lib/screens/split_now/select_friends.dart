import 'package:flutter/material.dart';
import 'split_on_friends.dart';
import 'package:expenser/core/get_local_data.dart';
import 'package:expenser/core/app_constants.dart';
import 'package:expenser/core/utils.dart';
import 'package:expenser/core/get_firebase_data.dart';

class SelectFriendsPage extends StatefulWidget {
  final double amount;
  final VoidCallback? onDataSaved; // Callback to notify parent when data is saved
  
  const SelectFriendsPage({super.key, required this.amount, this.onDataSaved});

  @override
  State<SelectFriendsPage> createState() => _SelectFriendsPageState();
}

class _SelectFriendsPageState extends State<SelectFriendsPage> {
  List<Friend> selectedFriends = [];
  List<Friend> allFriends = [];
  bool _isLoading = true;
  final String currentUserMobile = GetFirebaseData().getCurrentUserMobile();
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Load friends data
      final List<Map<String, dynamic>> friendsData = await GetLocalData.getFriendsList();
      
      // Convert database data to Friend objects
      final List<Friend> friends = friendsData.map((friendData) {
        return Friend(
          id: friendData['mobile_number'] ?? '',
          name: friendData['full_name'] ?? 'Unknown',
          phone: friendData['mobile_number'] ?? '',
          profilePicture: friendData['profile_picture'] ?? '',
          isSelected: false,
        );
      }).toList();
      
      // Add current user to the list if not already present
      if (currentUserMobile != "") {
        final currentUserProfile = await GetLocalData.getUserProfile();
        if (currentUserProfile.isNotEmpty) {
          final currentUserFriend = Friend(
            id: currentUserProfile['mobile_number'] ?? '',
            name: currentUserProfile['full_name'] ?? 'You',
            phone: currentUserProfile['mobile_number'] ?? '',
            profilePicture: currentUserProfile['profile_picture'] ?? '',
            isSelected: false,
          );
          
          // Check if current user is already in the list
          final existingUserIndex = friends.indexWhere((friend) => friend.id == currentUserMobile);
          if (existingUserIndex == -1) {
            friends.add(currentUserFriend);
          }
        }
      }
      
      setState(() {
        allFriends = friends;
        _isLoading = false;
      });
      
      print('Loaded ${friends.length} friends');
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleFriendSelection(Friend friend) {
    setState(() {
      friend.isSelected = !friend.isSelected;
      if (friend.isSelected) {
        selectedFriends.add(friend);
      } else {
        selectedFriends.remove(friend);
      }
    });
  }

  void _onNextPressed() {
    if (selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one friend'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SplitOnFriendsPage(
          amount: widget.amount,
          selectedFriends: selectedFriends,
          onDataSaved: widget.onDataSaved,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Friends',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Selected friends count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '${selectedFriends.length} friends selected',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),

                if (selectedFriends.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        for (var friend in allFriends) {
                          friend.isSelected = false;
                        }
                        selectedFriends.clear();
                      });
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),

          // Friends list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : allFriends.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No friends found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add friends to split expenses with them',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: allFriends.length,
                        itemBuilder: (context, index) {
                          final friend = allFriends[index];
                          return ListTile(
                            leading: GestureDetector(
                              onTap: () => _toggleFriendSelection(friend),
                              child: Stack(
                                children: [
                                  Builder(
                                    builder: (context) {
                                      final imageProvider = Utils.getProfileImageProvider(friend.profilePicture);
                                      return CircleAvatar(
                                        radius: 25,
                                        backgroundImage: imageProvider,
                                        child: imageProvider == null ? const Icon(Icons.person) : null,
                                      );
                                    },
                                  ),
                                  if (friend.isSelected)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            title: Text(
                              friend.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(friend.phone),
                            onTap: () => _toggleFriendSelection(friend),
                          );
                        },
                      ),
          ),

          // Next button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: selectedFriends.isNotEmpty ? _onNextPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedFriends.isNotEmpty ? Colors.blue : Colors.grey[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Friend {
  final String id;
  final String name;
  final String phone;
  final String profilePicture;
  bool isSelected;
  int? share;

  Friend({
    required this.id,
    required this.name,
    required this.phone,
    required this.profilePicture,
    this.isSelected = false,
    this.share,
  });
}
