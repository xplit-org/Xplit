import 'package:expenser/services/firebase_sync_service.dart';
import 'package:flutter/material.dart';
import 'select_friends.dart';
import 'package:expenser/core/get_firebase_data.dart';
import 'package:expenser/core/app_constants.dart';
import 'package:expenser/core/utils.dart';

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
  final String currentUserMobile = GetFirebaseData().getCurrentUserMobile();

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
    try {
      final result = await FirebaseSyncService.saveSplitToDatabase(
        totalAmount: widget.amount,
        selectedFriends: selectedFriends,
        amountControllers: amountControllers,
      );

      if (result == 'SUCCESS') {
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
      } else {
        throw Exception('Failed to save split data');
      }
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
                  AppConstants.SPLIT_AMOUNT_TITLE, 
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
                  final imageProvider = Utils.getProfileImageProvider(
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
                        final imageProvider = Utils.getProfileImageProvider(friend.profilePicture);
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
                        final imageProvider = Utils.getProfileImageProvider(friend.profilePicture);
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
