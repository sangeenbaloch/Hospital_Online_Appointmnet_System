import 'package:flutter/material.dart';

class EditDoctorPage extends StatefulWidget {
  final Map<String, String> doctorData; // ✅ Receive doctor data

  const EditDoctorPage({super.key, required this.doctorData});

  @override
  State<EditDoctorPage> createState() => _EditDoctorPageState();
}

class _EditDoctorPageState extends State<EditDoctorPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _specialityController;
  late TextEditingController _emailController;
  late TextEditingController _roomController;
  late TextEditingController _dutyDaysController;
  late TextEditingController _maxAppointmentsController;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.doctorData['name'] ?? "");
    _specialityController =
        TextEditingController(text: widget.doctorData['specialization'] ?? "");
    _emailController =
        TextEditingController(text: widget.doctorData['email'] ?? "");

    // Default values for extra fields
    _roomController = TextEditingController(text: "Room 12");
    _dutyDaysController = TextEditingController(text: "Mon - Thu");
    _maxAppointmentsController = TextEditingController(text: "10");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        title: const Text(
          "Edit Doctor",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Doctor Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField("Full Name", _nameController),
              _buildTextField("Speciality", _specialityController),
              _buildTextField("Email", _emailController,
                  keyboardType: TextInputType.emailAddress),
              _buildTextField("Room No.", _roomController),
              _buildTextField("Duty Days", _dutyDaysController),
              _buildTextField("Max Appointments per Day",
                  _maxAppointmentsController,
                  keyboardType: TextInputType.number),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Update Doctor",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Doctor information updated successfully"),
                          backgroundColor: Color(0xFF00796B),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF00796B), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF004D40), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
