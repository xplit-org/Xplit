import 'package:flutter/material.dart';

class OwedByMeExpensesPage extends StatefulWidget {
  final String userName;
  final int totalAmount;
  final int requestCount;

  const OwedByMeExpensesPage({
    Key? key,
    required this.userName,
    required this.totalAmount,
    required this.requestCount,
  }) : super(key: key);

  @override
  State<OwedByMeExpensesPage> createState() => _OwedByMeExpensesPageState();
}

class _OwedByMeExpensesPageState extends State<OwedByMeExpensesPage> {
  String selectedFilter = 'Unpaid';

  // Sample data for individual expense requests
  List<Map<String, dynamic>> getExpenseRequests() {
    // This would typically come from a database or API
    // For now, using sample data based on the user
    if (widget.userName == "Aatif Aftab") {
      return [
        {
          "date": "28 May",
          "amount": 160.0,
          "description": "Lunch",
        },
        {
          "date": "28 May", 
          "amount": 500.0,
          "description": "Dinner",
        },
        {
          "date": "15 May",
          "amount": 15.0,
          "description": "Coffee",
        },
        {
          "date": "14 May",
          "amount": 35.0,
          "description": "Snacks",
        },
        
      ];
    } else if (widget.userName == "Mukhtar Khan") {
      return [
        {
          "date": "27 May",
          "amount": 60.0,
          "description": "Movie tickets",
        },
        {
          "date": "26 May",
          "amount": 40.0,
          "description": "Transport",
        },
      ];
    } else if (widget.userName == "Zaid Ahmad") {
      return [
        {
          "date": "25 May",
          "amount": 20.0,
          "description": "Breakfast",
        },
        {
          "date": "24 May",
          "amount": 15.0,
          "description": "Lunch",
        },
        {
          "date": "23 May",
          "amount": 25.0,
          "description": "Dinner",
        },
        {
          "date": "22 May",
          "amount": 20.0,
          "description": "Coffee",
        },
        {
          "date": "21 May",
          "amount": 10.0,
          "description": "Snacks",
        },
      ];
    } else {
      // Default data for other users
      return [
        {
          "date": "Today",
          "amount": widget.totalAmount.toDouble(),
          "description": "Expense",
        },
      ];
    }
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
          "Owed by me",
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
                  backgroundColor: Colors.lightBlue,
                  child: Text(
                    widget.userName.split(' ').map((e) => e[0]).join(''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // User name and owes text
                Text(
                  "You owe ${widget.userName} ",
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
                    color: Colors.red,
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
          
          // Pay Button at bottom
          Container(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
            
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
                onPressed: () {
                  // Handle payment
                },
                child: Text(
                  "Pay ₹${widget.totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
          CircleAvatar(
            radius: 20,
            backgroundImage: const AssetImage("assets/profilepic.png"),
          ),
          const SizedBox(width: 12),
          
          // Request details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Split request",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      request["date"],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Requested by you",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Amount
          Text(
            "₹${request["amount"].toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
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