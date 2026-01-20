/*import 'package:flutter/material.dart';
import 'dart:math';
import 'OtpVarification.dart'; // ✅ Correct import

class OtpHelper {
  // ✅ Generate a random 6-digit OTP
  static String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // ✅ Email validation
  static bool isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  // ✅ Show OTP dialog (styled like the screenshot)
  static void showOtpDialog(BuildContext context, String otp, String email) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // ✅ Rounded corners
        ),
        title: const Center(
          child: Text(
            "OTP Sent",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        content: Text(
          "Your OTP is $otp. Use this code to reset your password.",
          textAlign: TextAlign.center, // ✅ Centered text
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 100, // ✅ Button width
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF167D74), // ✅ Green button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);

                  // Navigate to OTP Verification Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtpVerificationScreen(
                        otp: otp,
                        email: email,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/