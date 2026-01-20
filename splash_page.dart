import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../doctor/dashboard/doctor_dashboard.dart';
import '../patient/dashboard/patient_dashboard.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 3));
    
    final prefs = await SharedPreferences.getInstance();

    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final String? role = prefs.getString('role');

    if (!mounted) return;

    if (isLoggedIn && role != null) {
      if (role == 'patient') {
        _goTo(const PatientScreen());
      } else if (role == 'doctor') {
        _goTo(const DoctorDashboard());
      } else {
        _goTo(const LoginPage());
      }
    } else {
      _goTo(const LoginPage());
    }
  }

  void _goTo(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC7EDE6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/darman logo.png", width: 278, height: 105),
            const SizedBox(height: 20),
            const Text(
              "Hospital Online Appointment System",
              style: TextStyle(fontSize: 20, color: Color(0xFF666666)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            const Text(
              "Book Appointments, Find Specialists Doctors, and Manage Your Health Journey All In One Place.",
              style: TextStyle(fontSize: 20,  color: Color(0xFF666666)),
              textAlign: TextAlign.center,
            ),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF167D74)),
            ),
          ],
        ),
      ),
    );
  }
}