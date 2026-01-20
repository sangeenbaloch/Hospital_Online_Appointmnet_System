import 'package:flutter/material.dart';
import 'package:fypproject/screens/auth/login.dart';
import 'package:fypproject/screens/patient/dashboard/navigation_bar.dart';
import 'package:fypproject/screens/patient/profile/edit_profile.dart';
import 'package:fypproject/screens/auth/change_password.dart';
import 'notification_preference.dart';
import 'package:fypproject/screens/patient/info/faq.dart';
import 'package:fypproject/screens/patient/info/feedback.dart';
import 'package:fypproject/screens/patient/info/privacy_policy.dart';
import 'package:fypproject/screens/patient/info/terms.dart';

class PatientSettingsPage extends StatelessWidget {
  const PatientSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1), // ✅ Light teal background
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00796B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("Profile Settings"),
          _buildSettingTile(
            icon: Icons.person,
            title: "Edit Profile",
            subtitle: "Update your name and contact info",
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()));
            },
          ),

          const SizedBox(height: 20),
          _buildSectionTitle("Account & Security"),
          _buildSettingTile(
            icon: Icons.lock,
            title: "Change Password",
            subtitle: "Update your account password",
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
            },
          ),

          const SizedBox(height: 20),
          _buildSectionTitle("Notifications"),
          _buildSettingTile(
            icon: Icons.notifications,
            title: "Notification Preferences",
            subtitle: "Control appointment and payment alerts",
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationPreferencesPage()));
            },
          ),

          const SizedBox(height: 20),
          _buildSectionTitle("Help & Support"),
          _buildSettingTile(
            icon: Icons.help_outline,
            title: "FAQs",
            subtitle: "Find answers to common questions",
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const FAQPage()));
            },
          ),
          _buildSettingTile(
            icon: Icons.feedback_outlined,
            title: "Send Feedback",
            subtitle: "Tell us how we can improve",
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const FeedbackPage()));
            },
          ),

          const SizedBox(height: 20),
          _buildSectionTitle("Legal"),
          _buildSettingTile(
            icon: Icons.article_outlined,
            title: "Privacy Policy",
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()));
            },
          ),
          _buildSettingTile(
            icon: Icons.gavel_outlined,
            title: "Terms of Service",
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const TermsPage()));
            },
          ),

          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Logout",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF004D40),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
        onTap: onTap,
      ),
    );
  }
}
