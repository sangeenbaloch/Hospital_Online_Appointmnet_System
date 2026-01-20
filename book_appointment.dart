import 'package:flutter/material.dart';
import 'package:fypproject/screens/patient/payment/payment_method.dart';
import 'package:fypproject/screens/patient/dashboard/navigation_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class BookAppointmentPage extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const BookAppointmentPage({super.key, required this.doctor});

  @override
  State<BookAppointmentPage> createState() => _DoctorBookingPageState();
}

class _DoctorBookingPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  
  DateTime? _selectedDate;
  bool _isFull = false;
  bool _isOnLeave = false;
  bool _isLoading = false;
  int _dynamicLimit = 30; 
  int _nextToken = 1; 

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? "";
      final data = await Supabase.instance.client
          .from('patients')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();
      if (data != null && mounted) {
        setState(() => _nameController.text = data['full_name'] ?? "");
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    
    DateTime firstDate = now;
    if (now.hour >= 9) {
      firstDate = now.add(const Duration(days: 1));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00796B)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isLoading = true;
      });
      await _checkDoctorAvailability(picked);
    }
  }

  Future<void> _checkDoctorAvailability(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final supabase = Supabase.instance.client;

    try {

      final docData = await supabase.from('doctors').select('daily_limit').eq('id', widget.doctor['id']).single();
      _dynamicLimit = docData['daily_limit'] ?? 30;

      final apptResponse = await supabase
          .from('appointments')
          .select('token_number')
          .eq('doctor_id', widget.doctor['id'])
          .eq('appointment_date', formattedDate)
          .order('token_number', ascending: false)
          .limit(1);

      final list = apptResponse as List;

      setState(() {
        _isFull = list.length >= _dynamicLimit; 
        

        if (list.isEmpty) {
          _nextToken = 1;
        } else {
          _nextToken = (list.first['token_number'] as int) + 1;
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        title: Text("Book Dr. ${widget.doctor['full_name']}"),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDoctorHeader(),
              const SizedBox(height: 20),
              
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.calendar_month, color: Color(0xFF00796B)),
                  title: Text(_selectedDate == null 
                    ? "Select Date" 
                    : DateFormat('EEEE, d MMM yyyy').format(_selectedDate!)),
                  subtitle: Text(_selectedDate == null 
                      ? "TMC Rule: Max 1 week in advance" 
                      : "Assigned Token: #$_nextToken"), // ✅ Display token preview
                  trailing: const Icon(Icons.edit, size: 20),
                  onTap: () => _selectDate(context),
                ),
              ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),

              if (_isOnLeave) 
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Text("❌ Dr. ${widget.doctor['full_name']} is on leave for this period.", 
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),

              if (_isFull && !_isOnLeave) 
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Text("⚠️ Daily limit reached ($_dynamicLimit patients). Choose another day.", 
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),

              const SizedBox(height: 20),
              const Text("Patient Information", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(controller: _nameController, decoration: _inputDecoration("Full Name")),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration("Phone Number"),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return "Required";
                  if (value.length != 11) return "Must be exactly 11 digits";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _reasonController, decoration: _inputDecoration("Reason for Visit"), maxLines: 2),
              
              const SizedBox(height: 30),
              _buildRulesInfo(),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedDate == null || _isFull || _isOnLeave || _isLoading) 
                    ? null 
                    : () => _proceedToPayment(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Proceed to Payment", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildDoctorHeader() {
    return Row(
      children: [
        const CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Color(0xFF00796B))),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dr. ${widget.doctor['full_name']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.doctor['speciality'] ?? "Specialist", style: const TextStyle(color: Color(0xFF00796B))),
          ],
        ),
      ],
    );
  }

  Widget _buildRulesInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        children: [
          _ruleRow(Icons.timer_off, "No bookings allowed after 9:00 AM for the same day."),
          const SizedBox(height: 8),
          _ruleRow(Icons.people, "Dynamic patient limit per doctor applied."),
          const SizedBox(height: 8),
          _ruleRow(Icons.event_busy, "Blocked for the entire duration of a doctor's leave."),
          const SizedBox(height: 8),
          _ruleRow(Icons.confirmation_number, "Sequential tokens issued per doctor/day."), // ✅ Updated text
        ],
      ),
    );
  }

  Widget _ruleRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.orange.shade800),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87))),
      ],
    );
  }


  // ✅ UPDATED: Logic to prevent duplicate appointments using patient_id
  Future<void> _proceedToPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final supabase = Supabase.instance.client;
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final userId = supabase.auth.currentUser?.id;

      try {
        // 1. First, we need the patient_id for the person being booked.
        // We look it up based on the current logged-in user.
        final patientLookup = await supabase
            .from('patients')
            .select('id')
            .eq('id', userId!) // Matching the authenticated user to their patient record
            .maybeSingle();

        if (patientLookup == null) {
          _showErrorDialog("Error", "Patient profile not found. Please complete your profile first.");
          return;
        }

        final String patientId = patientLookup['id'].toString();

        // 2. CHECK FOR DUPLICATE: Same Patient ID + Same Doctor + Same Date
        final existingApt = await supabase
            .from('appointments')
            .select()
            .eq('patient_id', patientId) 
            .eq('doctor_id', widget.doctor['id'])
            .eq('appointment_date', formattedDate)
            .maybeSingle();

        if (existingApt != null) {
          // Duplicate found!
          if (mounted) {
            _showErrorDialog(
              "Already Booked",
              "You already have an appointment with Dr. ${widget.doctor['full_name']} on this date. You cannot book twice for the same day."
            );
          }
          return;
        }

        // 3. No duplicate? Proceed to Payment
        final bookingInfo = {
          'doctor_id': widget.doctor['id'],
          'doctorName': widget.doctor['full_name'],
          'patient_id': patientId, // Pass the ID instead of just a name
          'patientName': _nameController.text.trim(),
          'phone': _phoneController.text,
          'reason': _reasonController.text,
          'date': formattedDate,
          'token_number': _nextToken,
        };

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PaymentMethodPage(bookingInfo: bookingInfo)),
          );
        }
      } catch (e) {
        debugPrint("Duplicate Check Error: $e");
        if (mounted) {
          _showErrorDialog("Connection Error", "Could not verify appointment status. Please try again.");
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // ✅ Helper Dialog for Errors
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}