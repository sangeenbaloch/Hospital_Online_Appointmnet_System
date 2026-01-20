import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Terms of Service", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00796B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Terms of Service",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // 1. Use of the App
            Text(
              "1. Use of the App",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "You agree to use the app only for its intended purpose: booking and managing healthcare appointments. "
                  "You must provide accurate and complete information when creating an account or booking appointments.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            // 2. Account Security
            Text(
              "2. Account Security",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "You are responsible for maintaining the confidentiality of your account login information. "
                  "Any activity performed under your account is your responsibility.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            // 3. Appointments
            Text(
              "3. Appointments",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Appointment availability depends on the healthcare provider’s schedule. "
                  "It is your responsibility to arrive on time for appointments and follow cancellation or rescheduling policies.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            // 4. User Conduct
            Text(
              "4. User Conduct",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "You must not use the app to harass, threaten, or violate the rights of others. "
                  "Any misuse of the app may result in suspension or termination of your account.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            // 5. Data and Privacy
            Text(
              "5. Data and Privacy",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "We collect and process your personal data according to our Privacy Policy. "
                  "By using the app, you consent to the collection and use of your data as described.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            // 6. Limitation of Liability
            Text(
              "6. Limitation of Liability",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "We are not liable for any direct or indirect damages arising from your use of the app. "
                  "The app is provided 'as is' without warranties of any kind.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            // 7. Third-Party Services
            Text(
              "7. Third-Party Services",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "The app may contain links to third-party services. We are not responsible for their content or privacy policies.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            // 8. Changes to Terms
            Text(
              "8. Changes to Terms",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "We may update these Terms of Service from time to time. Continued use of the app constitutes acceptance of any changes.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            // 9. Governing Law
            Text(
              "9. Governing Law",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "These terms are governed by the laws of the country in which our company is registered.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            Text(
              "By using this app, you acknowledge that you have read, understood, and agree to these Terms of Service. "
                  "If you do not agree, please do not use the app.",
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
