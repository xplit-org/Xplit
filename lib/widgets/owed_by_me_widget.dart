import 'package:flutter/material.dart';
import '../owed_by_me_expenses.dart';


class Data {
  static final List<Map<String, dynamic>> allData = [
    {
      "name": "Aatif Aftab",
      "requests" : 1,
      "amount" : 710,
    },
    {
      "name": "Mukhtar Khan",
      "requests" : 2,
      "amount" : 100,
    },
    {
      "name": "Zaid Ahmad",
      "requests" : 5,
      "amount" : 90,
    },
    {
      "name": "Faraz Khan",
      "requests" : 2,
      "amount" : 10,
    },

    {
      "name": "Haris Mirza",
      "requests" : 1,
      "amount" : 9,
    },
  ];
}

class OwedByMeWidget extends StatelessWidget {
  const OwedByMeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if there are any expenses
    if (Data.allData.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: Data.allData.length,
      itemBuilder: (context, index) {
          return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OwedByMeExpensesPage(
                  userName: Data.allData[index]["name"],
                  totalAmount: Data.allData[index]["amount"],
                  requestCount: Data.allData[index]["requests"],
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
                    radius: 20,
                    backgroundImage: const AssetImage("assets/profilepic.png"),
                  ),
                const SizedBox(width: 16),
                
                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Data.allData[index]["name"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${Data.allData[index]["requests"]} request${Data.allData[index]["requests"] == 1 ? '' : 's'} pending',
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
                      '₹${Data.allData[index]["amount"]}',
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