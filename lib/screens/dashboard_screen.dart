import 'package:flutter/material.dart';
import 'dashboard_home_tab.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String employeeId;
  final String employeeNama;

  const DashboardScreen({super.key, required this.employeeId, required this.employeeNama});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      DashboardHomeTab(employeeId: widget.employeeId, employeeNama: widget.employeeNama),
      HistoryScreen(employeeId: widget.employeeId),
      ProfileScreen(employeeId: widget.employeeId, employeeNama: widget.employeeNama),
    ];

    return Scaffold(
  body: Center(
    child: Container(
      constraints: const BoxConstraints(maxWidth: 450),
      child: tabs[_currentTab],
    ), // Container
  ), // Center
  bottomNavigationBar: Center( // Mengganti alignSelf menggunakan widget Center bawaan Flutter
    heightFactor: 1, // Agar area Center tidak memakan space ke atas
    child: Container(
      constraints: const BoxConstraints(maxWidth: 450),
      child: BottomNavigationBar(
        currentIndex: _currentTab,
        selectedItemColor: const Color(0xFF006B5E),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() { _currentTab = index; }),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history_toggle_off), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ), // BottomNavigationBar
    ), // Container
  ), // Center
);
}
}