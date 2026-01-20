import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PatientsListPage extends StatefulWidget {
  // ✅ Added doctorId parameter to accept ID from the Dashboard
  final String? doctorId; 
  const PatientsListPage({super.key, this.doctorId});

  @override
  State<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage> {
  String searchQuery = '';
  final supabase = Supabase.instance.client;

  // ✅ UPDATED: Fetches only the patients assigned to THIS doctor for Today
  Future<List<Map<String, dynamic>>> _fetchDoctorPatients() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // We query the 'appointments' table and JOIN the 'patients' table to get details
    final response = await supabase
        .from('appointments')
        .select('''
          token_number,
          appointment_time,
          status,
          patients (
            full_name,
            age,
            gender
          )
        ''')
        .eq('doctor_id', widget.doctorId ?? '') // ✅ Filters by specific doctor
        .eq('appointment_date', today)          // ✅ Filters by today's date
        .neq('status', 'Cancelled')             // ✅ Excludes cancelled ones
        .order('token_number', ascending: true); // ✅ Sorts by sequential token
        
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Today's Patient List",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search by patient name...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00796B)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00796B))),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchDoctorPatients(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No patients scheduled for today.", 
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                    );
                  }

                  // ✅ Filtering logic for search (handles nested patient object)
                  final filtered = snapshot.data!.where((item) {
                    final patientData = item['patients'] as Map<String, dynamic>?;
                    final name = patientData?['full_name']?.toString().toLowerCase() ?? '';
                    return name.contains(searchQuery.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final appointment = filtered[index];
                      final patient = appointment['patients'] as Map<String, dynamic>;

                      return Card(
                        color: Colors.white,
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFB2DFDB))),
                        child: ListTile(
                          // ✅ Shows Sequential Token clearly
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF00796B),
                            child: Text(
                              appointment['token_number'].toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(patient['full_name'], 
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Age: ${patient['age']} | Gender: ${patient['gender']}"),
                              Text("Time: ${appointment['appointment_time']}", 
                                  style: const TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.w500)),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              appointment['status'],
                              style: const TextStyle(fontSize: 12, color: Color(0xFF00796B), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}