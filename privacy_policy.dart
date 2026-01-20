import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Privacy Policy", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00796B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Your privacy is very important to us. We are committed to protecting the personal information you provide while using our app. "
                  "This Privacy Policy explains what information we collect, how we use it, and your rights regarding your data.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            // 1. How We Use Your Information
            Text(
              "1. How We Use Your Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "We use your information to provide and improve our services, send appointment reminders and notifications, respond to your inquiries and feedback, "
                  "and analyze usage trends to improve the app’s performance.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            // 2. Data Storage and Security
            Text(
              "2. Data Storage and Security",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "All personal data is encrypted and stored securely. We implement technical and organizational measures to protect your information "
                  "from unauthorized access, alteration, disclosure, or destruction.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            // 3. Sharing of Information
            Text(
              "3. Sharing of Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "We do not sell, trade, or rent your personal information to third parties. "
                  "We may share data with trusted service providers who help operate the app, but only for the purposes described in this policy.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            // 4. Your Rights
            Text(
              "4. Your Rights",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "You can request access to, correction, or deletion of your personal information. "
                  "You can also opt-out of notifications or marketing communications at any time.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            // 5. Third-Party Services
            Text(
              "5. Third-Party Services",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Our app may include links to third-party services. We are not responsible for the privacy practices of these third parties.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            // 6. Updates to This Policy
            Text(
              "6. Updates to This Policy",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "We may update this Privacy Policy from time to time. We encourage you to review it periodically to stay informed about how we protect your information.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),

            Text(
              "By using our app, you consent to the terms of this Privacy Policy. "
                  "If you have any questions or concerns about how your data is handled, please contact our support team.",
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
