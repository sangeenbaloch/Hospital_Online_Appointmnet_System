import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../doctor_management/doctor_schedule_form'; 

class WeeklySchedulePage extends StatefulWidget {
  const WeeklySchedulePage({super.key});

  @override
  State<WeeklySchedulePage> createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _fetchScheduleData() async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final doctorsRes = await supabase.from('doctors').select('id, full_name, speciality');
    final schedulesRes = await supabase.from('doctor_schedules').select();
    final leavesRes = await supabase
        .from('leave_requests')
        .select('doctor_id')
        .eq('status', 'Approved')
        .lte('start_date', today)
        .gte('end_date', today);

    final onLeaveIds = (leavesRes as List).map((l) => l['doctor_id'].toString()).toSet();

    
    return (doctorsRes as List).map((doc) {
      final docSchedules = (schedulesRes as List)
          .where((s) => s['doctor_id'] == doc['id'])
          .toList();

      return <String, dynamic>{
        ...doc as Map<String, dynamic>,
        'isOnLeaveToday': onLeaveIds.contains(doc['id'].toString()),
        'schedules': docSchedules,
      };
    }).toList().cast<Map<String, dynamic>>(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        title: const Text("Weekly Rosters", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchScheduleData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final doctors = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];
              return _buildDoctorScheduleCard(doc);
            },
          );
        },
      ),
    );
  }

  Widget _buildDoctorScheduleCard(Map<String, dynamic> doc) {
  final List schedules = doc['schedules'] ?? [];

  return Card(
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: BorderSide(color: const Color(0xFF00796B).withOpacity(0.1)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dr. ${doc['full_name']}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    doc['speciality'] ?? "Medical Specialist",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              // ✅ Refreshes the roster automatically when returning from the form
              IconButton(
                icon: const Icon(Icons.edit_calendar, color: Color(0xFF00796B)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorScheduleForm(
                      doctorId: doc['id'].toString(), 
                      doctorName: doc['full_name'],
                    ),
                  ),
                ).then((_) {
                  // ✅ Triggers a re-fetch of the stream/future data
                  setState(() {}); 
                }),
              ),
            ],
          ),
          const Divider(),
          
          // Leave status takes priority over the schedule display
          if (doc['isOnLeaveToday'] == true)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "⚠️ OFF TODAY (Approved Leave)",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            )
          else if (schedules.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "No timings set. Click the edit icon to add.",
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            )
          else
            ...schedules.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s['day_of_week'], 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF202D3A)),
                  ),
                  // ✅ Displays formatted HH:MM:SS from your doctor_schedules table
                  Text(
                    "${s['start_time']} - ${s['end_time']}",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            )),
        ],
      ),
    ),
  );
}
}