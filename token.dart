import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../dashboard/patient_dashboard.dart'; 

class PatientTokenDialog extends StatelessWidget {
  final String doctorName;
  final String patientName;
  final String appointmentDate;
  final String consultationTime; 
  final int tokenNumber; 

  const PatientTokenDialog({
    super.key,
    required this.doctorName,
    required this.patientName,
    required this.appointmentDate,
    required this.consultationTime,
    required this.tokenNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, color: Color(0xFF00796B), size: 60),
            const SizedBox(height: 10),
            const Text(
              "Appointment Confirmed!",
              style: TextStyle(
                  color: Color(0xFF00796B),
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),
            const Text("YOUR TOKEN NUMBER",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            
            // ✅ Displays the dynamic sequential token
            Text(
              "#$tokenNumber",
              style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00796B)),
            ),
            
            const SizedBox(height: 20),
            _buildDetailRow("Doctor", "Dr. $doctorName"),
            _buildDetailRow("Patient", patientName),
            _buildDetailRow("Date", appointmentDate),
            _buildDetailRow("Time", consultationTime),
            const SizedBox(height: 30),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _generatePdf(context),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text("Download"),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00796B)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00796B),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    // ✅ FIXED: Navigates back to Dashboard and clears stack
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const PatientScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text("Close", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ✅ PDF Generation Logic (Internal)
  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 2)),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text("TURBAT MEDICAL CENTER",
                    style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text("APPOINTMENT TOKEN", style: pw.TextStyle(fontSize: 18)),
                pw.Text("#$tokenNumber",
                    style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text("Doctor: Dr. $doctorName"),
                pw.Text("Patient: $patientName"),
                pw.Text("Date: $appointmentDate"),
                pw.Text("Time: $consultationTime"),
                pw.SizedBox(height: 40),
                pw.Text("Please arrive 15 minutes before your time.",
                    style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
              ],
            ),
          ),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}