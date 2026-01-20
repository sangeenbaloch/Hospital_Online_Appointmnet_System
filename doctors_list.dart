import 'package:flutter/material.dart';
import 'edit_doctor_page.dart';

class DoctorsListPage extends StatefulWidget {
  const DoctorsListPage({super.key});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage> {
  final List<Map<String, String>> doctors = [
    {
      'name': 'Dr. Fatima Khan',
      'specialization': 'Cardiologist',
      'experience': '8 years',
      'email': 'fatima.khan@hospital.com',
    },
    {
      'name': 'Dr. Ahmed Raza',
      'specialization': 'Neurologist',
      'experience': '10 years',
      'email': 'ahmed.raza@hospital.com',
    },
    {
      'name': 'Dr. Zainab Ali',
      'specialization': 'Pediatrician',
      'experience': '6 years',
      'email': 'zainab.ali@hospital.com',
    },
    {
      'name': 'Dr. Usman Baloch',
      'specialization': 'Dermatologist',
      'experience': '5 years',
      'email': 'usman.baloch@hospital.com',
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = doctors.where((doctor) {
      final name = doctor['name']!.toLowerCase();
      final specialization = doctor['specialization']!.toLowerCase();
      return name.contains(searchQuery.toLowerCase()) ||
          specialization.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Doctors List",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search by doctor name or specialization",
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF00796B)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00796B)),
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];

                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                          color: Color(0xFF00796B), width: 1.2),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF00796B),
                        child: Text(
                          doctor['name']![3],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        doctor['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Specialization: ${doctor['specialization']}"),
                          Text("Experience: ${doctor['experience']}"),
                          Text("Email: ${doctor['email']}"),
                        ],
                      ),

                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert, color: Colors.black),
                        onSelected: (value) {
                          if (value == "edit") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditDoctorPage(doctorData: doctor),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: "edit",
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.black),
                                SizedBox(width: 6),
                                Text("Edit Profile"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
