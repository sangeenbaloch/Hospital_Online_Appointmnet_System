import 'package:flutter/material.dart';
import 'add_doctor_page.dart';
import 'package:fypproject/screens/admin/doctor_management/weekly_schedule.dart';

class ManageDoctorsPage extends StatelessWidget {
  const ManageDoctorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Manage Doctors",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Management Options",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D40),
            ),
          ),
          const SizedBox(height: 16),

          _buildActionTile(
            context,
            icon: Icons.person_add_rounded,
            title: "Add Doctor",
            subtitle: "Register a new doctor and set profiles",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddDoctorPage()),
              );
            },
          ),

          const SizedBox(height: 12),

          _buildActionTile(
            context,
            icon: Icons.calendar_month_rounded,
            title: "Weekly Schedule",
            subtitle: "View and manage doctor duty rosters",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  WeeklySchedulePage()),
              );
            },
          ),
          
          // ✅ REMOVED: Password Approval block
        ],
      ),
    );
  }

  // ✅ IMPROVED: Action Card matches the TMC project theme
  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white, // White background for the box
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        // Subtle teal border to match Admin Dashboard action cards
        side: BorderSide(color: const Color(0xFF00796B).withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF00796B).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF00796B)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF202D3A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}