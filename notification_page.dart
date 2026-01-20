import 'package:flutter/material.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> alerts = [
      {
        'type': 'Security Alert',
        'message':
            '⚠ Unauthorized login attempt detected from IP 192.168.1.105',
        'time': '20 Oct 2025, 10:15 AM'
      },
      {
        'type': 'Warning',
        'message':
            'Multiple failed login attempts for Admin02 — account lock risk',
        'time': '19 Oct 2025, 09:40 PM'
      },
      {
        'type': 'Notification',
        'message': 'Admin credentials updated successfully.',
        'time': '19 Oct 2025, 07:30 PM'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Security Alerts & Notifications",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00796B),
                ),
              ),
              const SizedBox(height: 10),
              ...alerts.map((alert) {
                Color bgColor;
                IconData icon;

                if (alert['type'] == 'Security Alert') {
                  bgColor = Colors.redAccent.withOpacity(0.15);
                  icon = Icons.warning_amber_rounded;
                } else if (alert['type'] == 'Warning') {
                  bgColor = Colors.orangeAccent.withOpacity(0.15);
                  icon = Icons.lock_outline;
                } else {
                  bgColor = Colors.greenAccent.withOpacity(0.15);
                  icon = Icons.notifications_active;
                }

                return Card(
                  color: bgColor,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side:
                        const BorderSide(color: Color(0xFF00796B), width: 1.0),
                  ),
                  child: ListTile(
                    leading: Icon(icon, color: Colors.black),
                    title: Text(
                      alert['type']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    subtitle: Text(alert['message']!),
                    trailing: Text(
                      alert['time']!,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
