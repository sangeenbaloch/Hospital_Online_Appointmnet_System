import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestLeavePage extends StatefulWidget {
  const RequestLeavePage({super.key});

  @override
  State<RequestLeavePage> createState() => _RequestLeavePageState();
}

class _RequestLeavePageState extends State<RequestLeavePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false; // ✅ Track loading state

  // ✅ UPDATED: Submit Leave to Supabase with Auth ID
  Future<void> _submitLeaveRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      _showSnackBar('Please select both start and end dates.', Colors.redAccent);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser; // Get current doctor's ID

      if (user != null) {
        await supabase.from('leave_requests').insert({
          'doctor_id': user.id, // ✅ Links request to the logged-in doctor
          'reason': '$_selectedLeaveType: ${_reasonController.text.trim()}',
          'start_date': _startDate!.toIso8601String().split('T')[0],
          'end_date': _endDate!.toIso8601String().split('T')[0],
          'status': 'Pending', 
        });

        if (mounted) {
          _showSnackBar('Leave request submitted successfully!', const Color(0xFF00897B));
          Navigator.pop(context); 
        }
      }
    } catch (e) {
      _showSnackBar('Error submitting request: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00897B),
              onPrimary: Colors.white,
              onSurface: Color(0xFF202D3A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC2ECE4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        centerTitle: true,
        title: const Text('Leave Request',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(2, 3))],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Leave Application Form',
                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF202D3A))),
                const SizedBox(height: 16),
                const Text('Leave Type', style: TextStyle(fontFamily: 'PT Sans', color: Color(0xFF333333), fontSize: 15)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration(''),
                  items: const [
                    DropdownMenuItem(value: 'Sick Leave', child: Text('Sick Leave')),
                    DropdownMenuItem(value: 'Casual Leave', child: Text('Casual Leave')),
                    DropdownMenuItem(value: 'Emergency Leave', child: Text('Emergency Leave')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (val) => setState(() => _selectedLeaveType = val),
                  validator: (val) => val == null ? 'Please select leave type' : null,
                ),
                const SizedBox(height: 20),
                const Text('Start Date', style: TextStyle(fontFamily: 'PT Sans', color: Color(0xFF333333), fontSize: 15)),
                const SizedBox(height: 6),
                _datePickerField(context, true),
                const SizedBox(height: 16),
                const Text('End Date', style: TextStyle(fontFamily: 'PT Sans', color: Color(0xFF333333), fontSize: 15)),
                const SizedBox(height: 6),
                _datePickerField(context, false),
                const SizedBox(height: 20),
                const Text('Reason for Leave', style: TextStyle(fontFamily: 'PT Sans', color: Color(0xFF333333), fontSize: 15)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: _inputDecoration('Enter your reason here...'),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter reason for leave' : null,
                ),
                const SizedBox(height: 28),
                Center(
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Color(0xFF00897B))
                    : ElevatedButton.icon(
                        onPressed: _submitLeaveRequest, // ✅ Calls Supabase logic
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00897B),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text('Submit Request', style: TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00897B))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00897B))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00897B), width: 1.5)),
    );
  }

  Widget _datePickerField(BuildContext context, bool isStart) {
    return GestureDetector(
      onTap: () => _pickDate(context, isStart),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFF00897B), width: 1), borderRadius: BorderRadius.circular(10)),
        child: Text(
          (isStart ? (_startDate != null ? _formatDate(_startDate!) : 'Select start date')
                   : (_endDate != null ? _formatDate(_endDate!) : 'Select end date')),
          style: const TextStyle(fontFamily: 'PT Sans', color: Color(0xFF333333), fontSize: 14),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}