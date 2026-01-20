import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../doctor/dashboard/doctor_dashboard.dart';
import '../admin/dashboard/admin_dashboard.dart';
import '../patient/dashboard/patient_dashboard.dart';
import 'signup_patient.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  final Color primaryTeal = const Color(0xFF00897B);

  Future<void> loginUser() async {
  setState(() => isLoading = true);
  final supabase = Supabase.instance.client;

  try {
    final AuthResponse res = await supabase.auth.signInWithPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    final user = res.user;
    if (user == null) throw "Authentication failed.";

    final patientData = await supabase.from('patients').select().eq('id', user.id).maybeSingle();
    if (patientData != null) {
      await _saveSession('patient', true);
      _navigateToDashboard('patient');
      return;
    }

    final doctorData = await supabase.from('doctors').select().eq('id', user.id).maybeSingle();
    if (doctorData != null) {
      final bool needsChange = user.userMetadata?['needs_password_change'] ?? false;

      if (needsChange) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/change-password');
        }
      } else {
        await _saveSession('doctor', true);
        _navigateToDashboard('doctor');
      }
      return;
    }

    final adminData = await supabase.from('admin_profiles').select().eq('id', user.id).maybeSingle();
    if (adminData != null) {
      await _saveSession('admin_profiles', false); 
      _navigateToDashboard('admin_profiles');
      return;
    }

    throw "User record not found in any authorized role.";

  } on AuthException catch (e) {
    _showSnackBar(e.message);
  } catch (e) {
    _showSnackBar("Login Error: $e");
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}

  Future<void> _saveSession(String role, bool isPersistent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isPersistent); 
    await prefs.setString('role', role);
  }

  void _navigateToDashboard(String role) {
    if (!mounted) return;
    
    Widget page;
    switch (role) {
      case 'patient':
        page = const PatientScreen();
        break;
      case 'doctor':
        page = const DoctorDashboard();
        break;
      case 'admin_profiles':
        page = const AdminDashboard();
        break;
      default:
        page = const LoginPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryTeal,
      body: Stack(
        children: [
          Positioned(
            top: 100, left: 0, right: 0,
            child: Column(
              children: const [
                Text("Welcome back", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text("Enter your email and password to\naccess your account", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.62,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildTextField(emailController, "Enter your email"),
                    const SizedBox(height: 20),
                    _buildTextField(passwordController, "Enter your password", isPassword: true),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                        child: const Text("Forgot password?", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 180, height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : loginUser,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen(prefilledEmail: emailController.text.trim()))),
                          child: const Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      decoration: InputDecoration(
        hintText: hint,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.teal.shade100)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primaryTeal)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
      ),
    );
  }
}