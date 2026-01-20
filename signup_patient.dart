import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../patient/dashboard/patient_dashboard.dart';

class SignUpScreen extends StatefulWidget {
  final String prefilledEmail;
  const SignUpScreen({super.key, required this.prefilledEmail});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _gender;
  bool _isLoading = false;

  final Color primaryTeal = const Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.prefilledEmail;
  }

  Future<void> registerPatient() async {
    final supabase = Supabase.instance.client;
    final name = _nameCtrl.text.trim();
    final age = int.tryParse(_ageCtrl.text.trim());
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final gender = _gender;

    if (name.isEmpty || age == null || email.isEmpty || password.isEmpty || gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'age': age,
          'gender': gender,
        },
      );

      if (res.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', 'patient');
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => const PatientScreen()),
          (route) => false,
        );
      }
    } on AuthApiException catch (authError) {
      String errorMessage = authError.message;
      if (authError.message.contains("already registered")) {
        errorMessage = "Email already exists. Please login instead.";
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryTeal,
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 15,
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text("Back to Login", style: TextStyle(color: Colors.white)),
            ),
          ),
          Positioned(
            top: 110,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                Text("Sign-up to get started", style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.72,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(_nameCtrl, "Full name"),
                    const SizedBox(height: 15),
                    _buildTextField(_ageCtrl, "Age", keyboardType: TextInputType.number),
                    const SizedBox(height: 15),
                    _buildGenderDropdown(),
                    const SizedBox(height: 15),
                    _buildTextField(_emailCtrl, "Email address"),
                    const SizedBox(height: 15),
                    _buildTextField(_passwordCtrl, "Password", isPassword: true),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : registerPatient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text("Login", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.teal.shade100)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primaryTeal)),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.teal.shade100)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _gender,
          hint: const Text("Gender", style: TextStyle(color: Colors.grey)),
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: "Male", child: Text("Male")),
            DropdownMenuItem(value: "Female", child: Text("Female")),
            DropdownMenuItem(value: "Other", child: Text("Other")),
          ],
          onChanged: (val) => setState(() => _gender = val),
        ),
      ),
    );
  }
}