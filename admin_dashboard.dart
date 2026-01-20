import 'package:flutter/material.dart';
import 'package:fypproject/screens/admin/admin_management/manage_admins.dart';
import 'package:fypproject/screens/admin/appointments/manage_appointments.dart';
import 'package:fypproject/screens/admin/billing/payment_billing.dart';
import 'package:fypproject/screens/admin/doctor_management/approve_leave.dart';
import 'package:fypproject/screens/admin/doctor_management/manage_doctors.dart';
import 'package:fypproject/screens/admin/patient_management/manage_patients.dart';
import 'package:fypproject/screens/auth/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalDoctors = 0;
  int totalPatients = 0;
  int appointmentsToday = 0;
  double totalRevenue = 0.0; 
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
  if (!mounted) return;
  setState(() => isLoadingStats = true);
  
  try {
    final supabase = Supabase.instance.client;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final doctorsRes = await supabase
        .from('doctors')
        .select('*')
        .count(CountOption.exact);

    final patientsRes = await supabase
        .from('patients')
        .select('*')
        .count(CountOption.exact);

    final todayAppsRes = await supabase
        .from('appointments')
        .select('*')
        .eq('appointment_date', today)
        .count(CountOption.exact);

    final revenueData = await supabase
        .from('appointments')
        .select('id')
        .neq('status', 'Cancelled');

    if (mounted) {
      setState(() {
        totalDoctors = doctorsRes.count;
        totalPatients = patientsRes.count;
        appointmentsToday = todayAppsRes.count;
        
        final int totalBookedCount = (revenueData as List).length;
        totalRevenue = totalBookedCount * 1500.0; 
        
        isLoadingStats = false;
      });
    }
  } catch (e) {
    debugPrint("Error fetching stats: $e");
    if (mounted) setState(() => isLoadingStats = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        title: const Text("TMC Admin Panel", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _fetchStats, icon: const Icon(Icons.refresh))
        ],
      ),
      drawer: _buildAdminDrawer(),
      body: RefreshIndicator(
        onRefresh: _fetchStats,
        color: const Color(0xFF00796B),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text("Hospital Overview", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildStatTile("Doctors", totalDoctors.toString(), Icons.medical_services, Colors.blue),
                _buildStatTile("Patients", totalPatients.toString(), Icons.people, Colors.orange),
                _buildStatTile("Today's Apps", appointmentsToday.toString(), Icons.event_available, Colors.green),
                _buildStatTile("Total Revenue", "Rs ${totalRevenue.toInt()}", Icons.payments, Colors.purple),
              ],
            ),

            const SizedBox(height: 25),
            const Text("Quick Management", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
            const SizedBox(height: 12),

            _buildActionCard("Manage Doctors", "Staff registration & profiles", Icons.person_add, const Color(0xFF00796B), const ManageDoctorsPage()),
            _buildActionCard("Manage Patients", "Records and history", Icons.assignment_ind, const Color(0xFF00796B), const ManagePatientsPage()),
            _buildActionCard("Approve Leave", "Review doctor requests", Icons.fact_check, const Color(0xFF00796B), const ApproveLeavePage()),
            _buildActionCard("View Appointments", "View all active tokens", Icons.analytics, const Color(0xFF00796B), const ManageAppointmentsPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          isLoadingStats 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00796B)))
            : Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String sub, IconData icon, Color themeColor, Widget page) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), 
        side: BorderSide(color: themeColor.withOpacity(0.1))
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: themeColor.withOpacity(0.1), 
          child: Icon(icon, color: themeColor)
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF202D3A))),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: themeColor),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      ),
    );
  }

  Widget _buildAdminDrawer() {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF00796B)),
            accountName: Text("Hospital Admin", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text("admin@turbatmedical.com"),
            currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.admin_panel_settings, color: Color(0xFF00796B), size: 40)),
          ),
          ListTile(leading: const Icon(Icons.dashboard_outlined), title: const Text("Dashboard Overview"), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.history), title: const Text("Billing History"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentBilling()))),
          ListTile(leading: const Icon(Icons.admin_panel_settings_outlined), title: const Text("Manage Sub-Admins"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageAdminsPage()))),
          const Divider(),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red), 
            title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), 
            onTap: () async {
               await Supabase.instance.client.auth.signOut();
               if (!mounted) return;
               Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
            }
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}