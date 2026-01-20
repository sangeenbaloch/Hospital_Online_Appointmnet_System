import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'reset_password.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({required this.email, Key? key}) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final pinController = TextEditingController();
  bool _isVerifying = false;

  Future<void> _verifyOtp() async {
    if (pinController.text.length < 6) return;
    
    setState(() => _isVerifying = true);
    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: pinController.text.trim(),
        type: OtpType.recovery,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: widget.email)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid code. Please check your email again.')),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 4) return '****$domain';
    return '${name.substring(0, name.length - 4)}****$domain';
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF00897B);
    const Color buttonTeal = Color(0xFF00897B); 
    final defaultPinTheme = PinTheme(
      width: 45,
      height: 55,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.shade100, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: primaryTeal,
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
                      "OTP Varification",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    
                    Image.asset(
                      "assets/images/otp_illustration.png", 
                      height: 160,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.mark_email_read_outlined, size: 100, color: Colors.grey),
                    ),
                    
                    const SizedBox(height: 30),
                    const Text(
                      "Varification",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Enter the 6-digit code we sent to your\nemail ${_maskEmail(widget.email)}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 35),

                    Pinput(
                      length: 6,
                      controller: pinController,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: buttonTeal, width: 2),
                        ),
                      ),
                      onCompleted: (pin) => _verifyOtp(),
                    ),
                    
                    const SizedBox(height: 40),

                    SizedBox(
                      width: 150,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isVerifying ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isVerifying 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Verify", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
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