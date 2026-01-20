import 'package:flutter/material.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  bool appointmentAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Notification Preferences",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00796B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Appointment Notifications"),
            subtitle: const Text("Receive alerts for upcoming appointments"),
            value: appointmentAlerts,
            activeColor: const Color(0xFF00796B),
            onChanged: (v) => setState(() => appointmentAlerts = v),
          ),
        ],
      ),
    );
  }
}
