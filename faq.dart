import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        "q": "How can I book a doctor?",
        "a": "Go to the Doctors page, browse the list, and tap 'Book Appointment' to schedule a visit."
      },
      {
        "q": "Is my data safe?",
        "a": "Yes, all your data is securely stored, encrypted, and protected according to privacy standards."
      },
      {
        "q": "Will I get reminders for my appointment?",
        "a": "Yes, you’ll receive a reminder notification before your appointment to help you stay on schedule."
      },
      {
        "q": "Can I view my appointment history?",
        "a": "Yes, you can view all past and upcoming appointments in the 'My Appointments' section."
      },
      {
        "q": "What should I do if I forget my password?",
        "a": "Tap on 'Forgot Password' on the login screen and follow the steps to reset it securely."
      },
      {
        "q": "Can I update my personal information?",
        "a": "Yes, you can go to the 'Edit Profile' section to update your name, phone number, or email address."
      },
      {
        "q": "How can I contact support?",
        "a": "You can use the 'Feedback' or 'Contact Us' section in the app to reach our support team."
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("FAQs", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00796B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, i) => Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ExpansionTile(
            title: Text(
              faqs[i]['q']!,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00796B)),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  faqs[i]['a']!,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
