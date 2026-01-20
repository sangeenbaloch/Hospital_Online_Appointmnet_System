import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../doctor/dashboard/doctor_dashboard.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    final pass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (pass.isEmpty || confirmPass.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }
    if (pass.length < 6) {
      _showSnackBar("Password must be at least 6 characters");
      return;
    }
    if (pass != confirmPass) {
      _showSnackBar("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          password: pass,
          data: {'needs_password_change': false}, 
        ),
      );

      if (mounted) {
        _showSnackBar("Password updated successfully!");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DoctorDashboard()),
          (route) => false,
        );
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Set Secure Password", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00796B),
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "This is your first login. Please set a secure password to protect your account.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: _inputDecoration("New Password"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: _inputDecoration("Confirm New Password"),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator(color: Color(0xFF00796B))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00796B),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _updatePassword,
                    child: const Text("Update & Access Dashboard", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF00796B)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF80CBC4), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
      ),
    );
  }
}