import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApproveLeavePage extends StatefulWidget {
  const ApproveLeavePage({super.key});

  @override
  State<ApproveLeavePage> createState() => _ApproveLeavePageState();
}

class _ApproveLeavePageState extends State<ApproveLeavePage> {
  final supabase = Supabase.instance.client;

  void _notifyPatients(List<dynamic> appointments, String endDate) {
    for (var appointment in appointments) {
      final patientId = appointment['patient_id'];
      debugPrint("Notification sent to Patient $patientId: Appointment cancelled until $endDate.");
    }
  }

  Future<void> _updateLeaveStatus(Map<String, dynamic> leave, String newStatus) async {
    final String leaveId = leave['id'].toString();
    final String doctorId = leave['doctor_id'].toString();
    final String startDate = leave['start_date'];
    final String endDate = leave['end_date'];

    try {
      // 1. Update the Leave Request status
      await supabase
          .from('leave_requests')
          .update({'status': newStatus})
          .eq('id', leaveId);

      // 2. If approved, handle appointment cancellations
      if (newStatus == 'Approved') {
        final appointmentsToCancel = await supabase
            .from('appointments')
            .select('id, patient_id')
            .eq('doctor_id', doctorId)
            .lte('appointment_date', endDate)
            .gte('appointment_date', startDate)
            .neq('status', 'Cancelled');

        if (appointmentsToCancel.isNotEmpty) {
          final List<String> idsToUpdate = 
              appointmentsToCancel.map((a) => a['id'].toString()).toList();

          await supabase
              .from('appointments')
              .update({
                'status': 'Cancelled',
                'admin_note': 'Doctor on leave until $endDate. Please rebook after this date.'
              })
              .inFilter('id', idsToUpdate);
          
          _notifyPatients(appointmentsToCancel, endDate);
        }
      }

      if (mounted) {
        setState(() {}); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Leave $newStatus successfully.")),
        );
      }
    } catch (e) {
      debugPrint("Error updating leave status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        title: const Text("Manage Leave Requests", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      // ✅ UPDATED: Using FutureBuilder with .select('*, doctors(full_name)') to get names
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase
            .from('leave_requests')
            .select('*, doctors(full_name)')
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00796B)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No leave requests found.", style: TextStyle(color: Colors.grey)));
          }

          final requests = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final leave = requests[index];
              final status = leave['status'];
              // Access the joined doctor name
              final doctorName = leave['doctors'] != null ? leave['doctors']['full_name'] : "Unknown Doctor";

              return Card(
                color: Colors.white,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: const Color(0xFF00796B).withOpacity(0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ✅ Fixed: Now displaying the Doctor's Name
                          Text(
                            "Dr. $doctorName", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF202D3A))
                          ),
                          _buildStatusBadge(status),
                        ],
                      ),
                      const Divider(height: 24),
                      
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Color(0xFF00796B)),
                          const SizedBox(width: 8),
                          Text(
                            "${leave['start_date']}  ➔  ${leave['end_date']}", 
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notes, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Reason: ${leave['reason'] ?? 'Not specified'}",
                              style: const TextStyle(color: Colors.black87, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      
                      if (status == 'Pending') ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                // ✅ Fixed: Passing the entire 'leave' map
                                onPressed: () => _updateLeaveStatus(leave, 'Approved'),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text("Approve"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                // ✅ Fixed: Passing the entire 'leave' map
                                onPressed: () => _updateLeaveStatus(leave, 'Rejected'),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text("Reject"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved': return Colors.green;
      case 'Rejected': return Colors.red;
      default: return Colors.orange;
    }
  }
}