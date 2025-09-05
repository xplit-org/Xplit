import 'package:flutter/material.dart';
import 'package:expenser/widgets/owed_by_me_widget.dart';
import 'package:expenser/widgets/owed_to_me_widget.dart';
import 'package:expenser/core/get_local_data.dart';
import 'package:expenser/core/app_constants.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  Future<Map<String, dynamic>> _futureTotalAdjustedExpenses = Future.value({});
  Map<String, dynamic> totalAmount = {
    'owed_to_me': 0,
    'owed_by_me': 0,
  };

  @override
  void initState() {
    super.initState();
    // Load the totalAdjustedExpenses data when the page is initialized
    _futureTotalAdjustedExpenses = GetLocalData.getTotalExpense();

  }

  // Helper to pass data to widgets
  Widget _buildTabViews(Map<String, dynamic> totalAdjustedExpenses) {
    // Split the data for owed to me and owed by me
    //   - If total_amount > 0, it's "Owed to me"
    //   - If total_amount < 0, it's "Owed by me"
    final owedToMeList = totalAdjustedExpenses.entries
        .where((e) => (e.value['total_amount'] ?? 0) > 0)
        .map((e) => e.value as Map<String, dynamic>)
        .toList();
    final owedByMeList = totalAdjustedExpenses.entries
        .where((e) => (e.value['total_amount'] ?? 0) < 0)
        .map((e) => e.value as Map<String, dynamic>)
        .toList();

    return Expanded(
      child: TabBarView(
        children: [
          OwedToMeWidget(data: owedToMeList),
          OwedByMeWidget(data: owedByMeList),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(AppConstants.EXPENSES_TITLE),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black,
              indicatorColor: Color(0xFF29B6F6),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  child: Column(
                    children: [
                      Text(AppConstants.EXPENSES_OWED_TO_ME),
                      Text(
                        "₹ ${totalAmount['owed_to_me']}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    children: [
                      Text(AppConstants.EXPENSES_OWED_BY_ME),
                      Text(
                        "₹ ${totalAmount['owed_by_me']}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: _futureTotalAdjustedExpenses,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Expanded(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                } else if (snapshot.hasData) {
                  // Calculate totals and update state
                  final data = snapshot.data!;
                  final owedToMeList = data.entries
                      .where((e) => (e.value['total_amount'] ?? 0) > 0)
                      .map((e) => e.value as Map<String, dynamic>)
                      .toList();
                  final owedByMeList = data.entries
                      .where((e) => (e.value['total_amount'] ?? 0) < 0)
                      .map((e) => e.value as Map<String, dynamic>)
                      .toList();
                  
                  totalAmount['owed_to_me'] = owedToMeList.fold(0.0, (sum, item) => sum + (item['total_amount'] ?? 0)).toInt();
                  totalAmount['owed_by_me'] = owedByMeList.fold(0.0, (sum, item) => sum + (item['total_amount'] ?? 0)).toInt();
                  
                  // Force rebuild to update TabBar
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() {});
                  });
                  
                  return _buildTabViews(data);
                } else {
                  return const Expanded(
                    child: Center(child: Text('No data available')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
