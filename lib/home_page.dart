import 'package:flutter/material.dart';
import 'widgets/unpaid_widget.dart';
import 'widgets/paid_widget.dart';
import 'widgets/splitByMeWidget.dart';
import 'expenses.dart';
import 'user_dashboard.dart';

class DummyData {

// Paid split requests (received by current user)
  static final List<Map<String, dynamic>> allData = [
    // Paid Requests
    {
      "type": 0,
      "name": "Mukhtar",
      "profilePic": "assets/profilepic.png",
      "time": "6:35 pm",
      "amount": 200.0,
      "status": "Paid",
      "paidTime": "10:20 pm",
      "description": "Dinner"
    },
    {
      "type": 0,
      "name": "Sara Khan",
      "profilePic": "assets/profilepic.png",
      "time": "4:15 pm",
      "amount": 120.0,
      "status": "Paid",
      "paidTime": "7:30 pm",
      "description": "Movie tickets"
    },

    // My Splits
    {
      "type": 1,
      "name": "Mohammad Suhail",
      "profilePic": "assets/profilepic.png",
      "time": "12:05 pm",
      "amount": 160.0,
      "paidCount": 2,
      "totalCount": 8,
      "remainingAmount": 80.0,
      "description": "Team lunch",
    },
    {
      "type": 1,
      "name": "Mohammad Suhail",
      "profilePic": "assets/profilepic.png",
      "time": "8:00 am",
      "amount": 90.0,
      "paidCount": 3,
      "totalCount": 3,
      "remainingAmount": 60.0,
      "description": "Breakfast",
    },

    // Unpaid Requests
    {
      "type": 0,
      "name": "Aatif Aftab",
      "profilePic": "assets/profilepic.png",
      "time": "8:05 am",
      "amount": 210.0,
      "status": "Unpaid",
      "description": "Lunch at restaurant"
    },
    {
      "type": 0,
      "name": "Zaid Ahmad",
      "profilePic": "assets/profilepic.png",
      "time": "9:30 am",
      "amount": 16.0,
      "status": "Unpaid",
      "description": "Coffee break"
    },
    {
      "type": 0,
      "name": "Faizan Khan",
      "profilePic": "assets/profilepic.png",
      "time": "11:15 am",
      "amount": 45.0,
      "status": "Unpaid",
      "description": "Snacks"
    },
    {
      "type": 0,
      "name": "Ahmed Ali",
      "profilePic": "assets/profilepic.png",
      "time": "2:20 pm",
      "amount": 75.0,
      "status": "Unpaid",
      "description": "Transport fare"
    },
  ];

}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   // title: const Text(
      //   //   'Expenses',
      //   //   style: TextStyle(
      //   //     color: Colors.black87,
      //   //     fontWeight: FontWeight.bold,
      //   //   ),
      //   // ),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.list, color: Colors.green[600]),
      //       onPressed: () {},
      //     ),
      //   ],
      // ),


      
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UserDashboard()));
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage("assets/profilepic.png"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Mohammad Suhail",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.add_circle, color: Colors.green[600], size: 16),
                          const SizedBox(width: 4),
                          const Text(
                            "Owed to Me",
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "₹ 200.00",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.remove_circle, color: Colors.red[600], size: 16),
                          const SizedBox(width: 4),
                          const Text(
                            "Owed by Me",
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "₹ 300.00",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: Image.asset(
                    "assets/billLogo.png",
                    height: 40,
                    width: 40,
                  ),
                ),
              ],
            ),
          ),

          // Date separator
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Divider(color: Colors.grey[300]),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //         child: Text(
          //           "1 July, 2025",
          //           style: TextStyle(
          //             color: Colors.grey[600],
          //             fontSize: 14,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ),
          //       Expanded(
          //         child: Divider(color: Colors.grey[300]),
          //       ),
          //     ],
          //   ),
          // ),

          // Widgets list
          SizedBox(height: 5),
          Expanded(
            child: DummyData.allData.isEmpty 
                ? _buildEmptyState()
                : ListView(
                    children: [
                      // Generate widgets from dummy data
                      ...DummyData.allData.map((data) {
                        if (data["type"] == 1) {
                          return SplitByMeWidget(data: data);
                        } else if (data["type"] == 0) {
                          if(data["status"] == "Paid") {
                            return PaidWidget(data: data);
                          } else {
                            return UnpaidWidget(data: data);
                          }
                        } 

                        return UnpaidWidget(data: data);
                      }),
                    ],
                  ),
          ),

          // Bottom button
          Container(
            padding: const EdgeInsets.fromLTRB(12, 6 , 12, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF29B6F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpensesPage()));
                  // Handle split expense button press
                },
                child: const Text(
                  "Split an expense",
                  style: TextStyle(
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
            'No split expenses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first split expense to get started',
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
