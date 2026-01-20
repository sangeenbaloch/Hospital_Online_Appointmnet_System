import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RescheduleDialog extends StatefulWidget {
  final String appointmentId; 
  final String doctorId;      
  final String doctorName;
  final String patientName;
  final String currentDate;

  const RescheduleDialog({
    super.key,
    required this.appointmentId, 
    required this.doctorId,      
    required this.doctorName,
    required this.patientName,
    required this.currentDate,
  });

  @override
  State<RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<RescheduleDialog> {
  DateTime? newDate;
  bool _isLoading = false;

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    
    DateTime firstSelectable = now;
    if (now.hour >= 9) {
      firstSelectable = now.add(const Duration(days: 1));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstSelectable,
      firstDate: firstSelectable,
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
      setState(() => newDate = picked);
    }
  }

  Future<void> _confirmReschedule() async {
    if (newDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a new date")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final formattedDate = DateFormat('yyyy-MM-dd').format(newDate!);

      final countResponse = await supabase
          .from('appointments')
          .select('id')
          .eq('doctor_id', widget.doctorId)
          .eq('appointment_date', formattedDate)
          .neq('status', 'Cancelled');

      final int newToken = (countResponse as List).length + 1;

      await supabase.from('appointments').update({
        'appointment_date': formattedDate,
        'token_number': newToken,
        'appointment_time': "Sequential Token",
        'status': 'Booked', // Ensure it stays in 'Booked' status
      }).eq('id', widget.appointmentId);

      if (mounted) {
        Navigator.pop(context, true); // ✅ Returns 'true' to trigger Dashboard refresh
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Success! New Token: #$newToken for $formattedDate"),
            backgroundColor: const Color(0xFF00796B),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFE0F2F1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        "Reschedule Appointment",
        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00796B)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Doctor: ${widget.doctorName.startsWith('Dr.') ? '' : 'Dr. '}${widget.doctorName}"),
          const SizedBox(height: 5),
          Text("Current Date: ${widget.currentDate}"),
          const Divider(height: 30),
          const Text("Choose New Date:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month, color: Color(0xFF00796B)),
              label: Text(
                newDate == null ? "Select Date" : DateFormat('yyyy-MM-dd').format(newDate!),
                style: const TextStyle(color: Colors.black87),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00796B)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Note: A new token will be assigned for the selected date.",
            style: TextStyle(fontSize: 11, color: Colors.orange, fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _confirmReschedule,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00796B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Confirm", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}