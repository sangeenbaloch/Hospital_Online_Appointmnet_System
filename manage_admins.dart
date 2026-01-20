import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageAdminsPage extends StatefulWidget {
  const ManageAdminsPage({super.key});

  @override
  State<ManageAdminsPage> createState() => _ManageAdminsPageState();
}

class _ManageAdminsPageState extends State<ManageAdminsPage> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _admins = [];

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }


  Future<void> _fetchAdmins() async {
    try {
      final data = await supabase.from('admin_profiles').select('*');
      setState(() {
        _admins = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }


  Future<void> _updatePermissions(String id, Map<String, bool> permissions) async {
    try {
      await supabase.from('admin_profiles').update(permissions).eq('id', id);
      _fetchAdmins(); // Refresh
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }


  Future<void> _removeAdmin(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Admin'),
        content: Text('Are you sure you want to remove $name? This will revoke all access.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.from('admin_profiles').delete().eq('id', id);
      _fetchAdmins();
    }
  }

  void _showPermissionsDialog(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (_) {
        bool doctors = admin['can_manage_doctors'];
        bool patients = admin['can_manage_patients'];
        bool payments = admin['can_manage_payments'];

        return StatefulBuilder(builder: (context, setLocalState) {
          return AlertDialog(
            title: Text('Permissions: ${admin['full_name']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Manage Doctors'),
                  value: doctors,
                  onChanged: (v) => setLocalState(() => doctors = v),
                ),
                SwitchListTile(
                  title: const Text('Manage Patients'),
                  value: patients,
                  onChanged: (v) => setLocalState(() => patients = v),
                ),
                SwitchListTile(
                  title: const Text('Manage Payments'),
                  value: payments,
                  onChanged: (v) => setLocalState(() => payments = v),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  _updatePermissions(admin['id'], {
                    'can_manage_doctors': doctors,
                    'can_manage_patients': patients,
                    'can_manage_payments': payments,
                  });
                  Navigator.pop(context);
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        title: const Text('Admin Management', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchAdmins,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _admins.length,
                itemBuilder: (context, index) {
                  final admin = _admins[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: admin['role'] == 'Super Admin' ? Colors.red.shade700 : Colors.teal.shade700,
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white),
                      ),
                      title: Text(admin['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${admin['role']} • ${admin['email']}"),
                      trailing: PopupMenuButton<String>(
                        onSelected: (val) {
                          if (val == 'perm') _showPermissionsDialog(admin);
                          if (val == 'del') _removeAdmin(admin['id'], admin['full_name']);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'perm', child: Text('Edit Permissions')),
                          const PopupMenuItem(value: 'del', child: Text('Remove Admin')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}