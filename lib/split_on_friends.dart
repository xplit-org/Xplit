import 'package:flutter/material.dart';
import 'select_friends.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'logic/get_data.dart';
import 'logic/create_local_db.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math';
import 'constants/app_constants.dart';

class SplitOnFriendsPage extends StatefulWidget {
  final double amount;
  final List<Friend> selectedFriends;
  final VoidCallback? onDataSaved; // Callback to notify parent when data is saved

  const SplitOnFriendsPage({
    super.key,
    required this.amount,
    required this.selectedFriends,
    this.onDataSaved,
  });

  @override
  State<SplitOnFriendsPage> createState() => _SplitOnFriendsPageState();
}

class _SplitOnFriendsPageState extends State<SplitOnFriendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Friend> selectedFriends = [];
  Map<String, TextEditingController> amountControllers = {};
  bool _isRedistributing = false; // Flag to prevent infinite loops

    // Helper function to create ImageProvider for profile pictures
  ImageProvider? _getProfileImageProvider(String? profilePicture) {    
    if (profilePicture == null || profilePicture.isEmpty) {
      print('Profile picture is null or empty');
      return null;
    }
    
    // Check if it's a base64 image
    if (profilePicture.startsWith('data:image/')) {
      try {
        // Extract base64 data from the data URL
        final base64Data = profilePicture.split(',')[1];
        final bytes = base64Decode(base64Data);
        print('Successfully created MemoryImage from base64');
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    selectedFriends = List.from(widget.selectedFriends);

    // Initialize amount controllers with equal values (default for first tab)
    _updateAmountsForCurrentTab();

    // Add listener to tab controller to update amounts when tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _updateAmountsForCurrentTab();
      }
    });
  }

  // Update amounts based on current active tab
  void _updateAmountsForCurrentTab() {
    if (selectedFriends.isEmpty) return;

    switch (_tabController.index) {
      case 0: // Split Evenly
        _updateAmountsForEvenSplit();
        break;
      case 1: // Split by Amounts
        _updateAmountsForAmountSplit();
        break;
      case 2: // Split by Shares
        _updateAmountsForShareSplit();
        break;
    }
  }

  // Update amounts for even split
  void _updateAmountsForEvenSplit() {
    final equalAmount = widget.amount / selectedFriends.length;
    
    for (var friend in selectedFriends) {
      final displayAmount = equalAmount == equalAmount.roundToDouble()
          ? equalAmount.toInt().toString()
          : equalAmount.toStringAsFixed(2);

      // Create controller if it doesn't exist
      if (!amountControllers.containsKey(friend.id)) {
        amountControllers[friend.id] = TextEditingController();
        
        // Add listener for automatic redistribution (only for amount split tab)
        amountControllers[friend.id]!.addListener(() {
          if (!_isRedistributing && _tabController.index == 1) {
            _redistributeAmounts(friend.id);
          }
        });
      }
      
      // Update the amount
      amountControllers[friend.id]!.text = displayAmount;
    }
  }

  // Update amounts for amount split (with redistribution logic)
  void _updateAmountsForAmountSplit() {
    final equalAmount = widget.amount / selectedFriends.length;
    
    for (var friend in selectedFriends) {
      final displayAmount = equalAmount == equalAmount.roundToDouble()
          ? equalAmount.toInt().toString()
          : equalAmount.toStringAsFixed(2);

      // Create controller if it doesn't exist
      if (!amountControllers.containsKey(friend.id)) {
        amountControllers[friend.id] = TextEditingController();
        
        // Add listener for automatic redistribution
        amountControllers[friend.id]!.addListener(() {
          if (!_isRedistributing) {
            _redistributeAmounts(friend.id);
          }
        });
      }
      
      // Update the amount
      amountControllers[friend.id]!.text = displayAmount;
    }
  }

  // Update amounts for share split
  void _updateAmountsForShareSplit() {
    // Calculate total shares
    int totalShares = 0;
    for (var friend in selectedFriends) {
      // Initialize share value if not already set
      if (friend.share == null) {
        friend.share = 1;
      }
      totalShares += friend.share!;
    }

    for (var friend in selectedFriends) {
      // Calculate amount based on shares
      final shareAmount = totalShares > 0
          ? (widget.amount * (friend.share! / totalShares))
          : 0.0;

      final displayAmount = shareAmount == shareAmount.roundToDouble()
          ? shareAmount.toInt().toString()
          : shareAmount.toStringAsFixed(2);

      // Create controller if it doesn't exist
      if (!amountControllers.containsKey(friend.id)) {
        amountControllers[friend.id] = TextEditingController();
      }
      
      // Update the amount
      amountControllers[friend.id]!.text = displayAmount;
    }
  }

  void _redistributeAmounts(String changedFriendId) {
    if (_isRedistributing) return; // Prevent recursive calls

    _isRedistributing = true;

    print('amountControllers: $amountControllers');

    // Get the amount entered for the changed friend
    final changedController = amountControllers[changedFriendId];
    if (changedController == null) {
      _isRedistributing = false;
      return;
    }

    final changedAmount = double.tryParse(changedController.text) ?? 0.0;

    // Calculate remaining amount
    final remainingAmount = widget.amount - changedAmount;

    // Get other friends (excluding the changed one)
    final otherFriends = selectedFriends.where((friend) => friend.id != changedFriendId).toList();

    if (otherFriends.isNotEmpty) {
      // Distribute remaining amount equally among other friends
    final equalAmount = remainingAmount / otherFriends.length;

    for (var friend in otherFriends) {
      final controller = amountControllers[friend.id];
      if (controller != null) {
        // Show whole number if it's a whole number, otherwise show 2 decimal places
        final displayAmount = equalAmount == equalAmount.roundToDouble()
            ? equalAmount.toInt().toString()
            : equalAmount.toStringAsFixed(2);

        controller.text = displayAmount;
        }
      }
    }

    _isRedistributing = false;
  }

  // Generate a unique ID for the split with database check
  Future<String> _generateUniqueSplitId() async {
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

  // Save split data to local database
  Future<void> _saveSplitToDatabase() async {
    try {
      final db = await LocalDB.database;
      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserMobile = currentUser?.phoneNumber;
      
      if (currentUserMobile == null) {
        throw Exception('User not logged in');
      }

      // Generate unique ID for this split
      final splitId = await _generateUniqueSplitId();
      final currentTime = DateTime.now().toIso8601String();

      // 1. Insert main split record into user_data table
      await db.insert(
        AppConstants.TABLE_USER_DATA,
        {
          AppConstants.COL_ID: splitId,
          AppConstants.COL_TYPE: AppConstants.TYPE_1, // Split by me
          AppConstants.COL_AMOUNT: widget.amount,
          AppConstants.COL_SPLIT_BY: null,
          AppConstants.COL_SPLIT_TIME: currentTime,
          AppConstants.COL_STATUS: null,
          AppConstants.COL_PAID_TIME: null,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      double update_to_get = 0;
      List<Map<String, dynamic>> splitOnRecords = [];

      // 2. Insert individual split records into split_on table
      for (var friend in selectedFriends) {
        final amount = double.tryParse(amountControllers[friend.id]?.text ?? '0') ?? 0.0;
        
        // Check if this friend is the current user
        final isCurrentUser = friend.id == currentUserMobile;
        if(!isCurrentUser){
          update_to_get += amount;
        }

        await db.insert(
          AppConstants.TABLE_SPLIT_ON,
          {
            AppConstants.COL_USER_DATA_ID: splitId,
            AppConstants.COL_MOBILE_NO: friend.id,
            AppConstants.COL_AMOUNT: amount,
            AppConstants.COL_STATUS: isCurrentUser ? AppConstants.STATUS_PAID : AppConstants.STATUS_UNPAID, // Current user is marked as paid
            AppConstants.COL_PAID_TIME: isCurrentUser ? currentTime : null,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        splitOnRecords.add({
          AppConstants.COL_MOBILE_NO: friend.id,
          AppConstants.COL_AMOUNT: amount,
          AppConstants.COL_STATUS: isCurrentUser ? AppConstants.STATUS_PAID : AppConstants.STATUS_UNPAID, // Current user is marked as paid
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
              'amount': widget.amount,
              'split_time': currentTime,
                'splitted_on': splitOnRecords,
        });
        print('Firebase user_data updated successfully');
      } catch (firebaseError) {
        print('Warning: Firebase user_data update failed: $firebaseError');
        // Continue with local save even if Firebase fails
      }

      // Update to_get
      if(update_to_get > 0){
        final userProfile = await GetData.getUserProfile(currentUserMobile);
        update_to_get += userProfile['to_get'];
        await db.update(
          'user',
          {
            'to_get': update_to_get,
          },
          where: 'mobile_number = ?',
          whereArgs: [currentUserMobile],
        );

        // 2.2. Also update Firebase user profile
        try {
          await FirebaseFirestore.instance
              .collection('user_details')
              .doc(currentUserMobile)
              .update({
                'to_get': update_to_get,
          });
          print('Firebase user profile updated successfully');
        } catch (firebaseError) {
          print('Warning: Firebase user profile update failed: $firebaseError');
        }
      }

      // 3. If current user is not in selected friends, add them with their share as paid
      final currentUserInList = selectedFriends.any((friend) => friend.id == currentUserMobile);
      if (!currentUserInList) {
        // Calculate current user's share (total amount minus what others owe)
        double othersTotal = 0.0;
        for (var friend in selectedFriends) {
          final amount = double.tryParse(amountControllers[friend.id]?.text ?? '0') ?? 0.0;
          othersTotal += amount;
        }
        final currentUserShare = widget.amount - othersTotal;
        
        if (currentUserShare > 0) {
          await db.insert(
            AppConstants.TABLE_SPLIT_ON,
            {
              AppConstants.COL_USER_DATA_ID: splitId,
              AppConstants.COL_MOBILE_NO: currentUserMobile,
              AppConstants.COL_AMOUNT: currentUserShare,
              AppConstants.COL_STATUS: AppConstants.STATUS_PAID, // Current user is marked as paid
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      print('Split data saved successfully with ID: $splitId');
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConstants.SUCCESS_SPLIT_SAVED),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Call the callback to notify parent that data was saved
      widget.onDataSaved?.call();
      
      // Navigate back to home page
      Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      print('Error saving split data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppConstants.ERROR_SAVING_DATA}: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose all controllers
    for (var controller in amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onSplitPressed() async {
    if (selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConstants.ERROR_NO_FRIENDS_SELECTED),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate that all amounts are properly set
    double totalAmount = 0.0;
    for (var friend in selectedFriends) {
      final amount = double.tryParse(amountControllers[friend.id]?.text ?? '0') ?? 0.0;
      totalAmount += amount;
    }

    // Check if total matches the original amount (with small tolerance for floating point)
    if ((totalAmount - widget.amount).abs() > 0.01) {
          ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppConstants.ERROR_AMOUNT_MISMATCH} (₹${totalAmount.toStringAsFixed(2)}) must equal ₹${widget.amount.toStringAsFixed(2)}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saving split...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );

    // Save to database
    await _saveSplitToDatabase();
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
          'Split ₹ ${widget.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: AppConstants.TAB_SPLIT_EVENLY),
            Tab(text: AppConstants.TAB_SPLIT_BY_AMOUNTS),
            Tab(text: AppConstants.TAB_SPLIT_BY_SHARES),
          ],
        ),
      ),
      body: Column(
        children: [
          // Selected friends count
          Container(
            padding: const EdgeInsets.all(16),
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
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSplitEvenlyTab(),
                _buildSplitByAmountsTab(),
                _buildSplitBySharesTab(),
              ],
            ),
          ),

          // Split button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: selectedFriends.isNotEmpty ? _onSplitPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedFriends.isNotEmpty
                      ? Colors.blue
                      : Colors.grey[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Split Amount',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitEvenlyTab() {
    return ListView.builder(
      itemCount: selectedFriends.length,
      itemBuilder: (context, index) {
        final friend = selectedFriends[index];
        final splitAmount = selectedFriends.isNotEmpty
            ? widget.amount / selectedFriends.length
            : 0.0;

        return ListTile(
          leading: Stack(
            children: [
              Builder(
                builder: (context) {
                  final imageProvider = _getProfileImageProvider(
                    friend.profilePicture,
                  );
                  return CircleAvatar(
                    radius: 25,
                    backgroundImage: imageProvider,
                    child: imageProvider == null
                        ? const Icon(Icons.person)
                        : null,
                  );
                },
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          title: Text(
            friend.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Text(
            '₹${splitAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSplitByAmountsTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: selectedFriends.length,
            itemBuilder: (context, index) {
              final friend = selectedFriends[index];
              return ListTile(
                leading: Stack(
                  children: [
                    Builder(
                      builder: (context) {
                        final imageProvider = _getProfileImageProvider(friend.profilePicture);
                        return CircleAvatar(
                          radius: 25,
                          backgroundImage: imageProvider,
                          child: imageProvider == null ? const Icon(Icons.person) : null,
                        );
                      },
                    ),
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
                title: Text(
                  friend.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Container(
                  width: 120,
                  alignment: Alignment.centerRight,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: TextField(
                          controller: amountControllers[friend.id],
                          enabled: true,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: '0.00',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            hintStyle: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                            prefixText: '  ₹ ',
                            prefixStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 20,
                        child: Container(
                          width: 80,
                          height: 2,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSplitBySharesTab() {
    // Calculate total shares
    int totalShares = 0;
    for (var friend in selectedFriends) {
      totalShares += friend.share ?? 1;
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: selectedFriends.length,
            itemBuilder: (context, index) {
              final friend = selectedFriends[index];
              // Initialize share value if not already set
              if (friend.share == null) {
                friend.share = 1;
              }

              return ListTile(
                leading: Stack(
                  children: [
                    Builder(
                      builder: (context) {
                        final imageProvider = _getProfileImageProvider(friend.profilePicture);
                        return CircleAvatar(
                          radius: 25,
                          backgroundImage: imageProvider,
                          child: imageProvider == null ? const Icon(Icons.person) : null,
                        );
                      },
                    ),
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
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${amountControllers[friend.id]?.text ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Minus button
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: friend.share! > 1
                            ? Colors.red
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove, size: 12),
                        color: friend.share! > 1
                            ? Colors.white
                            : Colors.grey[600],
                        onPressed: friend.share! > 1
                            ? () {
                                setState(() {
                                  friend.share = friend.share! - 1;
                                  _updateAmountsForCurrentTab();
                                });
                              }
                            : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                      ),
                    ),

                    // Share value display
                    Container(
                      width: 25,
                      alignment: Alignment.center,
                      child: Text(
                        '${friend.share}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    // Plus button
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, size: 12),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            friend.share = friend.share! + 1;
                            _updateAmountsForCurrentTab();
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
