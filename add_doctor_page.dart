import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart'; 

class AddDoctorPage extends StatefulWidget {
  const AddDoctorPage({super.key});

  @override
  State<AddDoctorPage> createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specialityController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _qualificationsController = TextEditingController(text: "MBBS");
  final TextEditingController _feeController = TextEditingController(text: "1500");
  final TextEditingController _scheduleController = TextEditingController(text: "Mon-Sat (9 AM - 2 PM)");
  final TextEditingController _limitController = TextEditingController(text: "30");


  Future<void> _registerDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final supabase = Supabase.instance.client;

    try {

      final res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(), 
        data: {
          'full_name': _nameController.text.trim(),
          'ph': _phoneController.text.trim(),
          'speciality': _specialityController.text.trim(),
          'experience': _experienceController.text.trim(),
          'bio': _bioController.text.trim(),
          'qualifications': _qualificationsController.text.trim(),
          'consultation_fee': _feeController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          'daily_limit': _limitController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          'schedule': _scheduleController.text.trim(),
          'role': 'doctor', 
        },
      );

      if (res.user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Doctor registration initiated successfully!")),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        title: const Text("Add New Doctor", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader("Auth Credentials"),
              _buildTextField(
                "Email", 
                _emailController, 
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Email is required";
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
              ),
              _buildTextField(
                "Initial Password", 
                _passwordController, 
                isMandatory: true,
                validator: (value) {
                  if (value == null || value.length < 6) return "Password must be at least 6 characters";
                  return null;
                },
              ),
              _sectionHeader("Profile Information"),
              _buildTextField("Full Name", _nameController),
              _buildTextField("Speciality", _specialityController),
              _buildTextField("Qualifications", _qualificationsController),
              _buildTextField(
                "Experience (Years)", 
                _experienceController, 
                keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              _buildTextField(
                "Phone ", 
                _phoneController, 
                keyboardType: TextInputType.phone,
                formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              ),
              
              _buildTextField("Bio", _bioController, maxLines: 3, isMandatory: false),

              _sectionHeader("Clinic Settings"),
              Row(
                children: [
                  Expanded(child: _buildTextField(
                    "Fee (Rs.)", 
                    _feeController, 
                    keyboardType: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(
                    "Daily Limit", 
                    _limitController, 
                    keyboardType: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                  )),
                ],
              ),
              _buildTextField("Schedule", _scheduleController),
              
              const SizedBox(height: 30),
              Center(
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00796B),
                          minimumSize: const Size(200, 50),
                        ),
                        onPressed: _registerDoctor,
                        child: const Text("Register Doctor", style: TextStyle(color: Colors.white)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    {TextInputType? keyboardType, 
    int maxLines = 1, 
    bool isMandatory = true,
    String? Function(String?)? validator,
    List<TextInputFormatter>? formatters} 
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: formatters,

        validator: validator ?? (isMandatory 
            ? (value) => value == null || value.isEmpty ? '$label is required' : null 
            : null),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}