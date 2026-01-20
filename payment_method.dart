import 'package:flutter/material.dart';
import 'payment_details.dart';

class PaymentMethodPage extends StatefulWidget {
  final Map<String, dynamic> bookingInfo;

  const PaymentMethodPage({super.key, required this.bookingInfo});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String? selectedMethod;

  final List<String> paymentMethods = [
    "EasyPaisa",
    "JazzCash",
    "Credit / Debit Card",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        title: const Text("Select Payment Method", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00796B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose your payment method:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
            ),
            const SizedBox(height: 20),
            // ✅ Iterating through methods and passing bookingInfo (with token) to details page
            ...paymentMethods.map((method) => Card(
              color: selectedMethod == method ? const Color(0xFF00897B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: selectedMethod == method ? const Color(0xFF00897B) : Colors.grey.shade300),
              ),
              elevation: 3,
              child: RadioListTile<String>(
                value: method,
                groupValue: selectedMethod,
                activeColor: Colors.white,
                title: Text(
                  method,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: selectedMethod == method ? Colors.white : Colors.black,
                  ),
                ),
                onChanged: (value) {
                  setState(() => selectedMethod = value);
                  if (value != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentDetailPage(
                          bookingInfo: widget.bookingInfo, 
                          paymentMethod: value,
                        ),
                      ),
                    );
                  }
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}