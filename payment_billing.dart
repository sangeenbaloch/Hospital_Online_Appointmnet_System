import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentBilling extends StatefulWidget {
  const PaymentBilling({super.key});

  @override
  State<PaymentBilling> createState() => _PaymentBillingState();
}

class _PaymentBillingState extends State<PaymentBilling> {
  final supabase = Supabase.instance.client;
  String searchQuery = "";
  Future<List<Map<String, dynamic>>> _fetchPayments() async {
    final response = await supabase
        .from('appointments')
        .select('''
          id,
          appointment_date,
          consultation_fee,
          status,
          patients (full_name),
          doctors (full_name)
        ''')
        .neq('status', 'Cancelled') 
        .order('appointment_date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F6), 
        appBar: AppBar(
          backgroundColor: const Color(0xFF00796B),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text("Payment / Billing",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.list), text: "All Payments"),
              Tab(icon: Icon(Icons.person), text: "By Doctor"),
            ],
          ),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchPayments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF00796B)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No payment records found."));
            }

            final allRecords = snapshot.data!;

            return TabBarView(
              children: [
                _buildAllPayments(allRecords),
                _buildByDoctorTab(allRecords),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAllPayments(List<Map<String, dynamic>> records) {
    final filtered = records.where((r) {
      final pName = r['patients']['full_name'].toString().toLowerCase();
      final dName = r['doctors']['full_name'].toString().toLowerCase();
      return pName.contains(searchQuery.toLowerCase()) || dName.contains(searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        _buildSearchField(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) => _buildPaymentCard(filtered[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildByDoctorTab(List<Map<String, dynamic>> records) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var r in records) {
      String dName = r['doctors']['full_name'];
      grouped.putIfAbsent(dName, () => []).add(r);
    }

    final doctorNames = grouped.keys.toList();

    return Column(
      children: [
        _buildSearchField(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctorNames.length,
            itemBuilder: (context, index) {
              final dName = doctorNames[index];
              final dPayments = grouped[dName]!;
              final total = dPayments.fold(0.0, (sum, item) => sum + (item['consultation_fee'] ?? 0));

              return Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: const Color(0xFF00796B).withOpacity(0.1)),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(dName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${dPayments.length} Total • Rs. ${total.toInt()}"),
                  children: dPayments.map((p) => ListTile(
                    title: Text(p['patients']['full_name']),
                    subtitle: Text(p['appointment_date']),
                    trailing: Text("Rs. ${p['consultation_fee']}"),
                  )).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v),
        decoration: InputDecoration(
          hintText: "Search patient or doctor...",
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00796B)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> record) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: const Color(0xFF00796B).withOpacity(0.1)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE0F2F1),
          child: Icon(Icons.payments, color: Color(0xFF00796B)),
        ),
        title: Text("${record['patients']['full_name']} ➔ ${record['doctors']['full_name']}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(record['appointment_date']),
        trailing: Text("Rs. ${record['consultation_fee']}",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
      ),
    );
  }
}