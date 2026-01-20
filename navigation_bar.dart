import 'package:flutter/material.dart';
import 'package:fypproject/screens/patient/dashboard/patient_dashboard.dart';
import 'package:fypproject/screens/patient/appointments/listofdoctors.dart';
import 'package:fypproject/screens/patient/profile/setting.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Map<String, dynamic>? bookingInfo;
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    this.bookingInfo,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF00897B),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == currentIndex) return;

        Widget nextPage;

        switch (index) {
          case 0:
            nextPage = PatientScreen(); 
            break;

          case 1:
            nextPage = const DoctorListScreen();
            break;

          case 2:
            nextPage = const PatientSettingsPage();
            break;

          default:
            return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: "Doctors"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}