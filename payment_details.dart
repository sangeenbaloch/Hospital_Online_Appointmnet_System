import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fypproject/screens/patient/appointments/token.dart';

class PaymentDetailPage extends StatefulWidget {
  final Map<String, dynamic> bookingInfo;
  final String paymentMethod;

  const PaymentDetailPage({
    super.key,
    required this.bookingInfo,
    required this.paymentMethod,
  });

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController accountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  bool isProcessing = false;


  Future<void> processAndSaveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isProcessing = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) throw Exception("User session expired.");

      // ✅ 1. FINAL DUPLICATE CHECK: Same Patient ID + Same Doctor + Same Date
      // This handles the case where the user might have stayed on the payment page for a long time
      // or double-clicked the confirm button.
      final existingApt = await supabase
          .from('appointments')
          .select('id')
          .eq('patient_id', user.id)
          .eq('doctor_id', widget.bookingInfo['doctor_id'])
          .eq('appointment_date', widget.bookingInfo['date'])
          .maybeSingle();

      if (existingApt != null) {
        throw Exception("Duplicate Booking: You already have a confirmed appointment for this date.");
      }

      // 2. CALL THE DATABASE FUNCTION for token sequentiality
      final int newTokenNumber = await supabase.rpc('get_next_token', params: {
        'doc_id': widget.bookingInfo['doctor_id'],
        'apt_date': widget.bookingInfo['date'],
      });

      // 3. Insert Appointment into Supabase
      await supabase.from('appointments').insert({
        'patient_id': user.id,
        'doctor_id': widget.bookingInfo['doctor_id'],
        'appointment_date': widget.bookingInfo['date'],
        'appointment_time': "09:00 AM - 02:00 PM",
        'status': 'Booked', 
        'reason': widget.bookingInfo['reason'] ?? "Consultation",
        'token_number': newTokenNumber,
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PatientTokenDialog(
            doctorName: widget.bookingInfo['doctorName'],
            patientName: widget.bookingInfo['patientName'],
            appointmentDate: widget.bookingInfo['date'],
            consultationTime: "09:00 AM - 02:00 PM",
            tokenNumber: newTokenNumber,
          ),
        );
      }
    } catch (e) {
      // ✅ Clear error message for the user
      String errorMessage = e.toString().contains("Exception: ") 
          ? e.toString().split("Exception: ")[1] 
          : "Booking Failed: $e";
          
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        title: const Text("Payment Details", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00796B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 20),
              _buildPaymentFields(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: isProcessing ? null : processAndSaveAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    fixedSize: const Size(250, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Confirm Payment & Book", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB2DFDB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Booking Summary", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
          const Divider(),
          Text("Doctor: Dr. ${widget.bookingInfo['doctorName']}"),
          Text("Patient: ${widget.bookingInfo['patientName']}"),
          Text("Date: ${widget.bookingInfo['date']}"),
          // ✅ Shows the assigned sequential token in summary
          Text("Assigned Token: #${widget.bookingInfo['token_number']}", 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    {TextInputType? keyboardType, 
    List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF00796B)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Required";
          if (label.contains("Mobile") && value.length != 11) return "Must be exactly 11 digits";
          if (label.contains("CVV") && value.length != 3) return "Must be 3 digits";
          if (label.contains("Card Number") && value.length != 16) return "Must be 16 digits";
          return null;
        },
      ),
    );
  }

  Widget _buildPaymentFields() {
    final method = widget.paymentMethod.toLowerCase();
    
    if (method.contains("card")) {
      return Column(children: [
        _buildTextField(nameController, "Card Holder Name"),
        _buildTextField(
          cardNumberController, 
          "Card Number", 
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                expiryController, 
                "Expiry (MM/YY)", 
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')), 
                  LengthLimitingTextInputFormatter(5),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                cvvController, 
                "CVV", 
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, 
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
            ),
          ],
        ),
      ]);
    } else {
      return Column(children: [
        _buildTextField(
          accountController, 
          "Mobile Account Number (e.g. 0300...)", 
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, 
            LengthLimitingTextInputFormatter(11),
          ],
        ),
        _buildTextField(nameController, "Account Holder Name"),
      ]);
    }
  }
}