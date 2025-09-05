import 'package:flutter/material.dart';
import 'package:expenser/screens/total_expenses/owed_to_me_expenses.dart';
import 'dart:convert';
import 'package:expenser/core/app_constants.dart';

class OwedToMeWidget extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  const OwedToMeWidget({Key? key, required this.data}) : super(key: key);

  @override
  State<OwedToMeWidget> createState() => _OwedToMeWidgetState();
}

class _OwedToMeWidgetState extends State<OwedToMeWidget> {
  Map<int, ImageProvider?> _cachedImages = {};

  @override
  void initState() {
    super.initState();
    _cacheAllImages();
  }

  void _cacheAllImages() {
    for (int i = 0; i < widget.data.length; i++) {
      _cachedImages[i] = _createImageProvider(widget.data[i]["profile_picture"]);
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

  @override
  Widget build(BuildContext context) {
    // Check if there are any expenses
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OwedToMeExpensesPage(
                  userName: widget.data[index]["full_name"] ?? "Unknown",
                  totalAmount: (widget.data[index]["total_amount"] ?? 0).toInt(),
                  requestCount: widget.data[index]["total_request"] ?? 0,
                  profilePicture: widget.data[index]["profile_picture"] ?? AppConstants.ASSET_DEFAULT_PROFILE_PIC,
                  requests: widget.data[index]["request"],
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
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: _cachedImages[index],
                    backgroundColor: Colors.lightBlue,
                    child: _cachedImages[index] == null
                        ? Text(
                            (widget.data[index]["full_name"] ?? "Unknown").split(' ').map((e) => e.isNotEmpty ? e[0] : '').join(''),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // User Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data[index]["full_name"] ?? "Unknown",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.data[index]["total_request"] ?? 0} request${(widget.data[index]["total_request"] ?? 0) == 1 ? '' : 's'} pending',
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
                        '₹${widget.data[index]["total_amount"] ?? 0}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppConstants.ASSET_NULL_IMAGE,
            height: 200,
            width: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            'No expenses owed to you',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'When someone owes you money, it will appear here',
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
