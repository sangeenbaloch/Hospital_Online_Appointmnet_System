import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();


  final TextEditingController _nameController =
  TextEditingController(text: "Admin User");
  final TextEditingController _emailController =
  TextEditingController(text: "admin@hospital.com");
  final TextEditingController _passwordController =
  TextEditingController(text: "password123");


  final TextEditingController _hospitalNameController =
  TextEditingController(text: "CityCare Hospital");
  final TextEditingController _hospitalAddressController =
  TextEditingController(text: "Main Road, Karachi, Pakistan");
  final TextEditingController _hospitalContactController =
  TextEditingController(text: "+92 300 1234567");

  File? _hospitalLogo;

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _hospitalLogo = File(pickedFile.path);
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile and Hospital Info Updated Successfully"),
          backgroundColor: Color(0xFF00796B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Profile & Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Profile",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00796B),
                ),
              ),
              const SizedBox(height: 10),

              _buildTextField(
                  controller: _nameController,
                  label: "Name",
                  icon: Icons.person),
              const SizedBox(height: 10),
              _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email),
              const SizedBox(height: 10),
              _buildTextField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock,
                  obscureText: true),

              const SizedBox(height: 25),

              const Text(
                "Hospital Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00796B),
                ),
              ),
              const SizedBox(height: 10),

              _buildTextField(
                controller: _hospitalNameController,
                label: "Hospital Name",
                icon: Icons.local_hospital,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _hospitalAddressController,
                label: "Address",
                icon: Icons.location_on,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _hospitalContactController,
                label: "Contact No.",
                icon: Icons.phone,
              ),

              const SizedBox(height: 20),
              const Text(
                "Hospital Logo",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage:
                    _hospitalLogo != null ? FileImage(_hospitalLogo!) : null,
                    child: _hospitalLogo == null
                        ? const Icon(Icons.local_hospital,
                        size: 40, color: Color(0xFF00796B))
                        : null,
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _pickLogo,
                    icon: const Icon(Icons.upload),
                    label: const Text("Upload Logo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00796B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save),
                  label: const Text("Save Changes"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF00796B)),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00796B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
        ),
      ),
      validator: (value) =>
      value == null || value.isEmpty ? "Please enter $label" : null,
    );
  }
}
