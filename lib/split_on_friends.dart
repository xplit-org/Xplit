import 'package:flutter/material.dart';
import 'select_friends.dart';

class SplitOnFriendsPage extends StatefulWidget {
  final double amount;
  final List<Friend> selectedFriends;
  
  const SplitOnFriendsPage({
    super.key, 
    required this.amount,
    required this.selectedFriends,
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
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    selectedFriends = List.from(widget.selectedFriends);
    
    // Initialize amount controllers with equal values
    final equalAmount = widget.amount / selectedFriends.length;
    for (var friend in selectedFriends) {
      // Show whole number if it's a whole number, otherwise show 2 decimal places
      final displayAmount = equalAmount == equalAmount.roundToDouble() 
          ? equalAmount.toInt().toString()
          : equalAmount.toStringAsFixed(2);
      
      amountControllers[friend.id] = TextEditingController(
        text: displayAmount,
      );
      
      // Add listener to each controller for automatic redistribution
      amountControllers[friend.id]!.addListener(() {
        if (!_isRedistributing) {
          _redistributeAmounts(friend.id);
        }
      });
    }
  }

  void _redistributeAmounts(String changedFriendId) {
    if (_isRedistributing) return; // Prevent recursive calls
    
    _isRedistributing = true;
    
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
    final otherFriends = selectedFriends.where((f) => f.id != changedFriendId).toList();
    
    if (otherFriends.isEmpty) {
      _isRedistributing = false;
      return;
    }
    
    // Calculate equal amount for remaining friends
    final equalAmount = remainingAmount / otherFriends.length;
    
    // Update other friends' amounts
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

  void _onSplitPressed() {
    if (selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one friend'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String splitType = '';
    switch (_tabController.index) {
      case 0:
        splitType = 'Evenly';
        break;
      case 1:
        splitType = 'By Amounts';
        break;
      case 2:
        splitType = 'By Shares';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Splitting ₹${widget.amount.toStringAsFixed(2)} $splitType among ${selectedFriends.length} friends'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
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
            Tab(text: 'Split Evenly'),
            Tab(text: 'Split by Amounts'),
            Tab(text: 'Split by Shares'),
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
                  backgroundColor: selectedFriends.isNotEmpty ? Colors.blue : Colors.grey[300],
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
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: '0.00',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
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
              
              // Calculate amount based on shares
              final shareAmount = totalShares > 0 
                  ? (widget.amount * (friend.share! / totalShares))
                  : 0.0;
              
              return ListTile(
                leading: Stack(
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
                      '₹${shareAmount.toStringAsFixed(2)}',
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
                        color: friend.share! > 1 ? Colors.red : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove, size: 12),
                        color: friend.share! > 1 ? Colors.white : Colors.grey[600],
                        onPressed: friend.share! > 1
                            ? () {
                                setState(() {
                                  friend.share = friend.share! - 1;
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