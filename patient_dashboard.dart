import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fypproject/screens/auth/login.dart';
import 'package:fypproject/screens/patient/appointments/Rchedual_appointment.dart'; 
import 'package:fypproject/screens/patient/appointments/listofdoctors.dart';
import 'navigation_bar.dart'; 

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final response = await supabase
          .from('patients')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          userName = response['full_name']?.toString();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching dashboard: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      final supabase = Supabase.instance.client;
      final prefs = await SharedPreferences.getInstance();

      await supabase.auth.signOut();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('role');

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error logging out: $e")),
        );
      }
    }
  }

  void _rescheduleAppointment(Map<String, dynamic> apt) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RescheduleDialog(
        appointmentId: apt['id'].toString(),
        doctorId: apt['doctor_id'].toString(),
        doctorName: "Dr. ${apt['doctor_name'] ?? 'Specialist'}",
        patientName: userName ?? 'Patient',
        currentDate: apt['appointment_date'],
      ),
    ).then((wasUpdated) {
      if (wasUpdated == true && mounted) {
        _fetchDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _logout,
        ),
        title: const Text(
          "Turbat Medical Center",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00796B)))
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              color: const Color(0xFF00796B),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingHeader(),
                    const SizedBox(height: 25),
                    
                    const Text("Upcoming Appointments", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
                    const SizedBox(height: 12),
                    
                    _buildUpcomingSection(), 
                    
                    const SizedBox(height: 25),
                    const Text("Recent Visits", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
                    const SizedBox(height: 12),
                    _buildRecentVisitSection(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildGreetingHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF26A69A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "HELLO, ${userName?.toUpperCase() ?? 'PATIENT'}!",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text("Your health is our priority.", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const Icon(Icons.medical_services, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection() {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('appointments')
          .stream(primaryKey: ['id'])
          .eq('patient_id', currentUser?.id ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState("No upcoming appointments.");
        }

        final upcomingApts = snapshot.data!.where((apt) {
          return apt['appointment_date'].compareTo(today) >= 0;
        }).toList();

        if (upcomingApts.isEmpty) {
          return _buildEmptyState("No upcoming appointments.");
        }

        upcomingApts.sort((a, b) => a['appointment_date'].compareTo(b['appointment_date']));

        return Column(
          children: upcomingApts.map((apt) => _buildAppointmentCardUI(apt)).toList(),
        );
      },
    );
  }

  Widget _buildRecentVisitSection() {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('appointments')
          .stream(primaryKey: ['id'])
          .eq('patient_id', currentUser?.id ?? ''),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final pastApts = snapshot.data!.where((apt) {
          return apt['appointment_date'].compareTo(today) < 0;
        }).toList();

        if (pastApts.isEmpty) {
          return _buildNoRecentVisitPlaceholder();
        }

        pastApts.sort((a, b) => b['appointment_date'].compareTo(a['appointment_date']));
        
        final lastApt = pastApts.first;

        return FutureBuilder<Map<String, dynamic>>(
          future: supabase.from('doctors').select().eq('id', lastApt['doctor_id']).single(),
          builder: (context, docSnap) {
            if (!docSnap.hasData) return const SizedBox();
            final doc = docSnap.data!;
            return _buildRecentVisitUI(doc, lastApt['appointment_date']);
          },
        );
      },
    );
  }

  Widget _buildAppointmentCardUI(Map<String, dynamic> apt) {
    final bool isCancelled = apt['status'] == 'Cancelled';

    return FutureBuilder<Map<String, dynamic>>(
      future: Supabase.instance.client.from('doctors').select().eq('id', apt['doctor_id']).single(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox();
        final doc = snap.data!;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(14),
            border: isCancelled ? Border.all(color: Colors.red.shade200) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isCancelled ? Colors.red.shade50 : const Color(0xFFE0F2F1), 
                    child: Icon(Icons.person, color: isCancelled ? Colors.red : const Color(0xFF00796B))
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text("Dr. ${doc['full_name']}", style: const TextStyle(fontWeight: FontWeight.bold))),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCancelled ? Colors.red : const Color(0xFF00796B), 
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      isCancelled ? "Cancelled" : "Token #${apt['token_number']}", 
                      style: const TextStyle(color: Colors.white, fontSize: 12)
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("📅 ${apt['appointment_date']}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const Text("🕒 9 AM - 2 PM", style: TextStyle(fontSize: 12, color: Color(0xFF00796B))),
                ],
              ),

              if (isCancelled && apt['admin_note'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange, size: 16),
                            SizedBox(width: 5),
                            Text("IMPORTANT MESSAGE:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          apt['admin_note'], 
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorListScreen())),
                          child: const Text(
                            "Tap to Book New Appointment", 
                            style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.underline)
                          ),
                        )
                      ],
                    ),
                  ),
                ),

              if (!isCancelled)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _rescheduleAppointment(apt),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B)),
                      child: const Text("Change Date", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentVisitUI(Map<String, dynamic> doctor, String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Color(0xFFB2DFDB), child: Icon(Icons.person, color: Color(0xFF00796B))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dr. ${doctor['full_name']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${doctor['speciality']}", style: const TextStyle(color: Color(0xFF00796B), fontSize: 12)),
                Text("Last Visit: $date", style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorListScreen())),
            child: const Text("Book"),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Center(child: Text(msg, style: const TextStyle(color: Colors.grey))),
    );
  }

  Widget _buildNoRecentVisitPlaceholder() {
    return _buildEmptyState("Your past medical visits will appear here.");
  }
}