import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'book_appointment.dart';
import 'package:fypproject/screens/patient/dashboard/navigation_bar.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  
  Future<List<Map<String, dynamic>>> _fetchDoctorsWithStatus() async {
    final supabase = Supabase.instance.client;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final doctorsData = await supabase
          .from('doctors')
          .select('*')
          .order('full_name', ascending: true);

      final leavesData = await supabase
          .from('leave_requests')
          .select('doctor_id, end_date')
          .eq('status', 'Approved')
          .lte('start_date', today) 
          .gte('end_date', today);

      final List<dynamic> doctors = doctorsData as List;
      final List<dynamic> leaves = leavesData as List;

      final Map<String, String> leaveMap = {
        for (var l in leaves) l['doctor_id'].toString(): l['end_date'].toString()
      };

      return doctors.map((doc) {
        final String docId = doc['id'].toString();
        return Map<String, dynamic>.from({
          ...doc,
          'isOnLeave': leaveMap.containsKey(docId),
          'leaveUntil': leaveMap[docId],
        });
      }).toList().cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint("Error fetching doctors: $e");
      return []; 
    }
  }

  // ✅ This function displays the dynamic schedule from doctor_schedules table
  void _showDoctorSchedule(BuildContext context, String doctorId, String doctorName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return FutureBuilder(
          future: Supabase.instance.client
              .from('doctor_schedules')
              .select()
              .eq('doctor_id', doctorId)
              .order('day_of_week'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
            }
            final list = snapshot.data as List? ?? [];
            
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("$doctorName's Schedule", 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
                  const Divider(),
                  if (list.isEmpty) 
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Text("No specific schedule set for this doctor yet.", style: TextStyle(color: Colors.grey)),
                    ),
                  ...list.map((s) => ListTile(
                    leading: const Icon(Icons.calendar_month, color: Color(0xFF00796B)),
                    title: Text(s['day_of_week'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text("${s['start_time']} - ${s['end_time']}", 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    subtitle: s['room_no'] != null ? Text("Room: ${s['room_no']}") : null,
                  )),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        title: const Text("Find a Doctor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDoctorsWithStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final doctors = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              final bool onLeave = doctor['isOnLeave'] ?? false;
              final String docName = doctor['full_name'].toString().startsWith('Dr.') 
                  ? doctor['full_name'] 
                  : "Dr. ${doctor['full_name']}";

              return Card(
                color: Colors.white,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: const Color(0xFF00796B).withOpacity(0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(radius: 30, backgroundColor: Color(0xFFE0F2F1), child: Icon(Icons.person, color: Color(0xFF00796B))),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(docName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(doctor['speciality'] ?? "Specialist", style: const TextStyle(color: Color(0xFF00796B))),
                                if (onLeave) 
                                   Text("⚠️ On Leave until ${doctor['leaveUntil']}", style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      // ✅ TWO BUTTONS: One for Schedule, One for Booking
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _showDoctorSchedule(context, doctor['id'].toString(), docName),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF00796B)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("View Schedule", style: TextStyle(color: Color(0xFF00796B))),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onLeave ? null : () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => BookAppointmentPage(doctor: doctor)));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00796B),
                                disabledBackgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(onLeave ? "Unavailable" : "Book Now", style: const TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}