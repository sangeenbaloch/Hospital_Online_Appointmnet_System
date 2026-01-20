import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ManageAppointmentsPage extends StatefulWidget {
  const ManageAppointmentsPage({super.key});

  @override
  State<ManageAppointmentsPage> createState() => _ManageAppointmentsPageState();
}

class _ManageAppointmentsPageState extends State<ManageAppointmentsPage> {
  final supabase = Supabase.instance.client;
  final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<Map<String, String>> _getRelatedNames(String pId, String dId) async {
    final patientData = await supabase.from('patients').select('full_name').eq('id', pId).single();
    final doctorData = await supabase.from('doctors').select('full_name').eq('id', dId).single();
    
    return {
      'patient': patientData['full_name'] ?? "Unknown Patient",
      'doctor': doctorData['full_name'] ?? "Unknown Doctor",
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        title: const Text(
          "Today's Clinic Queue",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('appointments')
            .stream(primaryKey: ['id'])
            .eq('appointment_date', today)
            .order('token_number', ascending: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00796B)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No patients in queue for today.", 
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          final appointments = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final apt = appointments[index];
              final token = apt['token_number'] ?? '0';

              return FutureBuilder<Map<String, String>>(
                future: _getRelatedNames(apt['patient_id'], apt['doctor_id']),
                builder: (context, nameSnapshot) {
                  final names = nameSnapshot.data ?? {'patient': 'Loading...', 'doctor': 'Loading...'};

                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: const Color(0xFF00796B).withOpacity(0.1)),
                    ),
                    child: ExpansionTile(
                      shape: const RoundedRectangleBorder(side: BorderSide.none),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF00796B).withOpacity(0.1),
                        child: Text("#$token", 
                          style: const TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
                      ),
                      title: Text(names['patient']!, 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF202D3A))),
                      subtitle: Text("Consultation: Dr. ${names['doctor']}", 
                        style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              _infoRow(Icons.access_time, "Queue Timing", "09:00 AM - 02:00 PM"),
                              _infoRow(Icons.notes, "Reason", apt['reason'] ?? "Standard Checkup"),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () { /* Future: Send Notification */ },
                                  icon: const Icon(Icons.phone_callback_outlined, size: 18),
                                  label: const Text("Call Patient"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00796B), 
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF00796B)),
          const SizedBox(width: 8),
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }
}