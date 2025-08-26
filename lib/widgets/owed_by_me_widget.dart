import 'package:flutter/material.dart';
import '../owed_by_me_expenses.dart';
import 'dart:convert';

class OwedByMeWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const OwedByMeWidget({Key? key, required this.data}) : super(key: key);
    ImageProvider? _getProfileImageProvider(String? profilePicture) {
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

  @override
  Widget build(BuildContext context) {
    // Check if there are any expenses
    if (data.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: data.length,
      itemBuilder: (context, index) {
          return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OwedByMeExpensesPage(
                  userName: data[index]["full_name"] ?? "Unknown",
                  totalAmount: data[index]["total_amount"] ?? 0,
                  requestCount: data[index]["total_request"] ?? 0,
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            elevation: 2,
            shadowColor: Colors.transparent,
            color: Colors.transparent, // Background color of the card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Profile Avatar
                Builder(
                  builder: (context) {
                    final imageProvider = _getProfileImageProvider(data[index]["profile_picture"]);
                    return CircleAvatar(
                    radius: 20,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(Icons.person)
                          : null,
                    );
                  },
                  ),
                const SizedBox(width: 16),
                
                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data[index]["full_name"] ?? "Unknown",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data[index]["total_request"] ?? 0} request${(data[index]["total_request"] ?? 0) == 1 ? '' : 's'} pending',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${data[index]["total_amount"] ?? 0}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/null.jpg',
            height: 200,
            width: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            'No expenses owed by you',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'When you owe money to someone, it will appear here',
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