import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../features/dashboard/views/widgets/dashboard_screen.dart';
import '../features/dashboard/views/attendance_screen.dart';
import '../features/employees/views/employee_screen.dart';
import '../features/reporting/report_screen.dart';
import '../screens/login_screen.dart';
import '../features/leave_approvals/views/admin_leave_screen.dart' as admin_leave;

class CustomSidebar extends StatelessWidget {
  final int currentIndex;
  
  const CustomSidebar({Key? key, this.currentIndex = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.primary,
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SmartAttendanceLogo(size: 60),
                  const SizedBox(height: 12),
                  const Text(
                    'Smart Attendance',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ]
              ),
            ),
          ),
          _buildMenuItem(context, Icons.dashboard_outlined, "Dashboard", 0, () {
            if (currentIndex != 0) Navigator.pushReplacement(context, _pageRoute(const AdminDashboardScreen()));
          }),
          _buildMenuItem(context, Icons.format_list_bulleted, "Daftar Absensi", 1, () {
            if (currentIndex != 1) Navigator.pushReplacement(context, _pageRoute(const AttendanceScreen()));
          }),
          _buildMenuItem(context, Icons.people_outline, "Manajemen Karyawan", 2, () {
            if (currentIndex != 2) Navigator.pushReplacement(context, _pageRoute(const EmployeeScreen()));
          }),
          _buildMenuItem(context, Icons.insert_chart_outlined, "Laporan", 3, () {
            if (currentIndex != 3) Navigator.pushReplacement(context, _pageRoute(const ReportScreen()));
          }),
          _buildMenuItem(context, Icons.approval, "Leave & Approvals", 4, () {
            if (currentIndex != 4) Navigator.pushReplacement(context, _pageRoute(const admin_leave.AdminLeaveScreen()));
          }),
          const Spacer(),
          const Divider(color: Colors.white24, height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text("Logout", style: TextStyle(color: Colors.white70)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, int index, VoidCallback onTap) {
    final bool isActive = currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isActive ? AppColors.success : Colors.white70),
      title: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      tileColor: isActive ? Colors.black12 : Colors.transparent,
      onTap: onTap,
    );
  }

  PageRouteBuilder _pageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}
