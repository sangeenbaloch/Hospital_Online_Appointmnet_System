import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagePatientsPage extends StatefulWidget {
  const ManagePatientsPage({super.key});

  @override
  State<ManagePatientsPage> createState() => _ManagePatientsPageState();
}

class _ManagePatientsPageState extends State<ManagePatientsPage> {
  final supabase = Supabase.instance.client;
  String searchQuery = "";

  void _showAppointmentHistory(BuildContext context, String patientId, String name) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("$name - Medical History", 
          style: const TextStyle(color: Color(0xFF004D40), fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder(
            future: supabase
                .from('appointments')
                .select('*, doctors(full_name)')
                .eq('patient_id', patientId)
                .order('appointment_date', ascending: false),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
              }
              
              final history = snapshot.data as List? ?? [];
              if (history.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("No previous appointments found.", textAlign: TextAlign.center),
                );
              }
              
              return ListView.separated(
                shrinkWrap: true,
                itemCount: history.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, i) {
                  final apt = history[i];
                  final docName = apt['doctors'] != null ? apt['doctors']['full_name'] : "Unknown Doctor";
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("Dr. $docName", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date: ${apt['appointment_date']} | Token: #${apt['token_number'] ?? 'N/A'}"),
                        Text("Status: ${apt['status']}", 
                          style: TextStyle(
                            color: apt['status'] == 'Completed' ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                          )
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), 
            child: const Text("Close", style: TextStyle(color: Color(0xFF00796B))))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6), 
      appBar: AppBar(
        title: const Text("Manage Patients", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00796B),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by patient name...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00796B)),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFF00796B).withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00796B)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => searchQuery = v),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('patients').stream(primaryKey: ['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00796B)));
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No patients registered yet."));
                }

                final patients = snapshot.data!
                    .where((p) => p['full_name'].toString().toLowerCase().contains(searchQuery.toLowerCase()))
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final p = patients[index];
                    return Card(
                      elevation: 0, 
                      color: Colors.white, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: const Color(0xFF00796B).withOpacity(0.1)),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF00796B).withOpacity(0.1),
                          child: const Icon(Icons.person, color: Color(0xFF00796B)),
                        ),
                        title: Text(
                          p['full_name'] ?? "Unnamed Patient", 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF202D3A))
                        ),
                        subtitle: p['phone'] != null 
                          ? Text("📞 ${p['phone']}", style: const TextStyle(fontSize: 13)) 
                          : null,
                        trailing: ElevatedButton(
                          onPressed: () => _showAppointmentHistory(context, p['id'], p['full_name']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00796B).withOpacity(0.1),
                            foregroundColor: const Color(0xFF00796B),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("History", style: TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }
}