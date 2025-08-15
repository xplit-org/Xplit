import 'package:flutter/material.dart';
import 'widgets/owed_by_me_widget.dart';
import 'widgets/owed_to_me_widget.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back),
         onPressed: () {
          Navigator.pop(context);
        }),
        title: const Text("Expenses"),
       
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Color(0xFF29B6F6),
              unselectedLabelColor: Colors.black,
              indicatorColor: Color(0xFF29B6F6),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: "Owed to me"),
                Tab(text: "Owed by me"),
              ],
            ),
            Expanded(
              child: const TabBarView(
                children: [
                  OwedToMeWidget(),
                  OwedByMeWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
      
    );
  }
}