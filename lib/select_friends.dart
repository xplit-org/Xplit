import 'package:flutter/material.dart';
import 'split_on_friends.dart';

class SelectFriendsPage extends StatefulWidget {
  final double amount;
  
  const SelectFriendsPage({super.key, required this.amount});

  @override
  State<SelectFriendsPage> createState() => _SelectFriendsPageState();
}

class _SelectFriendsPageState extends State<SelectFriendsPage> {
  List<Friend> selectedFriends = [];
  
  // Dummy friends data
  final List<Friend> allFriends = [
    Friend(id: '1', name: 'John Doe', phone: '+91 9876543210', isSelected: false),
    Friend(id: '2', name: 'Jane Smith', phone: '+91 9876543211', isSelected: false),
    Friend(id: '3', name: 'Mike Johnson', phone: '+91 9876543212', isSelected: false),
    Friend(id: '4', name: 'Sarah Wilson', phone: '+91 9876543213', isSelected: false),
    Friend(id: '5', name: 'David Brown', phone: '+91 9876543214', isSelected: false),
    Friend(id: '6', name: 'Emily Davis', phone: '+91 9876543215', isSelected: false),
    Friend(id: '7', name: 'Alex Turner', phone: '+91 9876543216', isSelected: false),
    Friend(id: '8', name: 'Lisa Anderson', phone: '+91 9876543217', isSelected: false),
  ];

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
            child: ListView.builder(
              itemCount: allFriends.length,
              itemBuilder: (context, index) {
                final friend = allFriends[index];
                return ListTile(
                  leading: GestureDetector(
                    onTap: () => _toggleFriendSelection(friend),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            friend.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
  bool isSelected;
  int? share;

  Friend({
    required this.id,
    required this.name,
    required this.phone,
    this.isSelected = false,
    this.share,
  });
}

class DummyData {
  static List<Map<String, String>> preSelectedFriends = [
    {'id': '1', 'name': 'John Doe', 'phone': '+91 9876543210'},
    {'id': '3', 'name': 'Mike Johnson', 'phone': '+91 9876543212'},
    {'id': '5', 'name': 'David Brown', 'phone': '+91 9876543214'},
  ];
}

