import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'select_friends.dart';

class SplitAmountPage extends StatefulWidget {
  const SplitAmountPage({super.key});

  @override
  State<SplitAmountPage> createState() => _SplitAmountPageState();
}

class _SplitAmountPageState extends State<SplitAmountPage> {
  final TextEditingController _amountController = TextEditingController();
  bool _isValidAmount = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_validateAmount);
  }

  void _validateAmount() {
    setState(() {
      final text = _amountController.text.trim();
      final value = double.tryParse(text);
      _isValidAmount = value != null && value > 0;
    });
  }

  void _onNextPressed() {
    if (!_isValidAmount) return;
    final amount = double.parse(_amountController.text.trim());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectFriendsPage(amount: amount),
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
        title: const Text(
          "Split Amount",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

                         // Centered ₹ + amount
             Center(
               child: IntrinsicWidth(
                 child: TextField(
                   controller: _amountController,
                   keyboardType: const TextInputType.numberWithOptions(
                     decimal: true,
                   ),
                   inputFormatters: [
                     FilteringTextInputFormatter.allow(
                       RegExp(r'^\d*\.?\d{0,2}'),
                     ),
                   ],
                   textAlign: TextAlign.center,
                   style: const TextStyle(
                     fontSize: 42,
                     fontWeight: FontWeight.bold,
                     color: Colors.black87,
                   ),
                                                                                                                                                               decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(fontSize: 42, color: Colors.grey),
                        prefixText: '₹ ',
                        prefixStyle: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                 ),
               ),
             ),

            const Spacer(),

            // Next button
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isValidAmount ? _onNextPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isValidAmount
                        ? Colors.blue
                        : Colors.grey[300],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
