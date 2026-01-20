import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'OtpVarification.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
      _showSnackBar("Please enter a valid email", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      if (mounted) {
        _showSuccessDialog(email);
      }
    } catch (e) {
      _showSnackBar("Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Center(
          child: Text("OTP Sent", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        content: Text(
          "A 6-digit verification code has been sent to $email.",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtpVerificationScreen(email: email),
                    ),
                  );
                },
                child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF00897B);

    return Scaffold(
      backgroundColor: primaryTeal,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle_outline, color: Color(0xFFB2DFDB), size: 80),
                const SizedBox(height: 10),
                const Text(
                  "Darmàn",
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const Text(
                      "Forgot Password?",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 25),

                    Image.asset(
                      "assets/images/email.png", 
                      height: 160,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.mail_outline, size: 100, color: Colors.grey),
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Verify Email",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Enter your email we will send you a\ncode to reset your password",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text("Email", style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFB2DFDB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: primaryTeal, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    SizedBox(
                      width: 150,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isLoading ? null : _sendOtp,
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Send", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Didn’t receive OTP? Resend",
                      style: TextStyle(fontSize: 13, color: Colors.black45),
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
}