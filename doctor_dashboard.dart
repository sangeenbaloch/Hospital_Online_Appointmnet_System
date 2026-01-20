import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../leave/request_leave.dart';
import '../profile/profile_page.dart';
import '../settings/setting.dart';
import '../dashboard/patients_list.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/login.dart'; 

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  String _selectedTime = '30 mins before';
  bool _isReminderOn = true;
  
  String doctorName = "Loading...";
  String speciality = "";
  int appointmentsCount = 0;
  bool isLoading = true;
  bool isOnLeaveToday = false; 

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  Future<void> _fetchDoctorData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final doctorProfile = await supabase
          .from('doctors')
          .select('full_name, speciality')
          .eq('id', user.id)
          .maybeSingle();

      final countResponse = await supabase
          .from('appointments')
          .select('*')
          .eq('doctor_id', user.id)
          .eq('appointment_date', today)
          .neq('status', 'Cancelled')
          .count(CountOption.exact);

      final leaveResponse = await supabase
          .from('leave_requests')
          .select('id')
          .eq('doctor_id', user.id)
          .eq('status', 'Approved')
          .lte('start_date', today) 
          .gte('end_date', today)   
          .maybeSingle();

      if (mounted) {
        setState(() {
          doctorName = doctorProfile?['full_name'] ?? "Doctor";
          speciality = doctorProfile?['speciality'] ?? "Specialist";
          appointmentsCount = countResponse.count; 
          isOnLeaveToday = leaveResponse != null;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching doctor dashboard data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isOnLeaveToday ? Colors.red.shade50 : const Color(0xFFC2ECE4), // ✅ Red tint if on leave
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Turbat Medical Center',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00897B)))
        : RefreshIndicator(
            onRefresh: _fetchDoctorData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeBanner(),
                  const SizedBox(height: 20),
                  

                  if (isOnLeaveToday) _buildLeaveStatusAlert(),

                  GestureDetector(
                    onTap: () {
                      final user = Supabase.instance.client.auth.currentUser;
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => PatientsListPage(doctorId: user?.id))
                      );
                    },
                    child: _infoCard(
                      title: 'My Patients',
                      value: appointmentsCount.toString(),
                      subtitle: 'Click to view assigned patients',
                      icon: Icons.people_alt_rounded,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  const Text('Weekly Schedule', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF202D3A))),
                  const SizedBox(height: 10),
                  
                  _scheduleRow('Mon - Thu', '9:00 AM – 4:00 PM', isOnLeaveToday ? 'OFF' : 'OPD-1'),
                  _scheduleRow('Fri', '9:00 AM - 12:30 PM', isOnLeaveToday ? 'OFF' : 'OPD-2'),
                  
                  const SizedBox(height: 20),
                  _buildLeaveRequestCard(context),
                  const SizedBox(height: 16),
                  _buildReminderCard(),
                ],
              ),
            ),
          ),
    );
  }


  Widget _buildLeaveStatusAlert() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "You are currently on approved leave. Today's status is marked as OFF.",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, Dr. $doctorName 👋',
                  style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF333333), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(speciality,
                  style: const TextStyle(fontFamily: 'PT Sans', color: Color(0xFF00897B), fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.local_hospital, size: 48, color: Color(0xFF00897B)),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF00897B)),
            child: Center(child: Icon(Icons.medical_services, size: 80, color: Colors.white)),
          ),
          _drawerItem(Icons.dashboard_rounded, 'Dashboard', onTap: () => Navigator.pop(context)),
          _drawerItem(Icons.people, 'My Patients', onTap: () {
            final user = Supabase.instance.client.auth.currentUser;
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => PatientsListPage(doctorId: user?.id)));
          }),
          _drawerItem(Icons.person, 'Profile', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorProfilePage()))),
          _drawerItem(Icons.settings, 'Settings', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()))),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _infoCard({required String title, required String value, required String subtitle, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(2, 4))]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFF00897B), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold)),
                Text('$value Total', style: const TextStyle(fontFamily: 'PT Sans', fontSize: 15, color: Color(0xFF757575))),
                Text(subtitle, style: const TextStyle(fontFamily: 'PT Sans', fontSize: 12, color: Color(0xFF757575))),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
  
  Widget _scheduleRow(String day, String time, String room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF202D3A))),
          Text(time, style: const TextStyle(color: Color(0xFF333333))),
          Text(room, style: TextStyle(
            color: room == 'OFF' ? Colors.red : const Color(0xFF757575),
            fontWeight: room == 'OFF' ? FontWeight.bold : FontWeight.normal
          )),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(2, 3))]
      ),
      child: Column(
        children: [
          const Text('Submit a leave request for any upcoming day.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'PT Sans', fontSize: 14)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestLeavePage())),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            icon: const Icon(Icons.edit_calendar, color: Colors.white, size: 18),
            label: const Text('Request Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(2, 3))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⏰ Duty Reminder', style: TextStyle(fontFamily: 'PT Sans', fontSize: 15)),
              DropdownButton<String>(
                value: _selectedTime,
                items: ['30 mins before', '1 hour before', '2 hours before']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedTime = val!),
                underline: const SizedBox(),
              ),
            ],
          ),
          Switch(
            value: _isReminderOn, 
            onChanged: (val) => setState(() => _isReminderOn = val), 
            activeColor: const Color(0xFF00897B)
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00897B)),
      title: Text(title, style: const TextStyle(fontFamily: 'PT Sans', fontSize: 16)),
      onTap: onTap,
    );
  }
}