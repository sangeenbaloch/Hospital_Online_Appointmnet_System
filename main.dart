import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/splash_page.dart';
import 'screens/auth/login.dart'; 
import 'screens/auth/change_password.dart'; 
import 'screens/doctor/dashboard/doctor_dashboard.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lyiirezaihzhnyclqbyo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5aWlyZXphaWh6aG55Y2xxYnlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1OTQwNTYsImV4cCI6MjA3NzE3MDA1Nn0.niBvASp3WQSFIC7ntLYRjnuk4TQ2XAzCBAlWpcu0Kik',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital Online Appointment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF167D74),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
      
      routes: {
        '/login': (context) => const LoginPage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/doctor-home': (context) => const DoctorDashboard(),
      },
    );
  }
}