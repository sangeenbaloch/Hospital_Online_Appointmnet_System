import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support'), backgroundColor: const Color(0xFF00897B)),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'If you face any issue while using the Darman app, please contact the system administrator or visit the hospital help desk.\n\n'
          'Email: support@tmc.edu.pk\nPhone: +92 333 1234567\n\n'
          'We are always here to assist doctors, patients, and hospital staff.',
          style: TextStyle(fontFamily: 'PT Sans', fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
