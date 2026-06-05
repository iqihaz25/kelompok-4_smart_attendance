import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared_widgets/custom_sidebar.dart';
import '../controllers/dashboard_controller.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardController>(context);
    bool isMobile = MediaQuery.of(context).size.width < 800;

    // Filtered logs
    final filteredLogs = controller.logs.where((log) {
      return log.employeeName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile ? AppBar(backgroundColor: AppColors.primary, title: const Text("Smart Attendance", style: TextStyle(color: Colors.white))) : null,
      drawer: isMobile ? const CustomSidebar(currentIndex: 1) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) const CustomSidebar(currentIndex: 1),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Daftar Kehadiran", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  const Text("Pantau status kehadiran karyawan hari ini secara real-time.", style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 32),
                  
                  // Search Bar
                  TextField(
                    onChanged: (val) {
                      setState(() {
                         _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Cari nama karyawan...",
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Summary Badges
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                                  SizedBox(width: 8),
                                  Text("Hadir", style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text("${controller.logs.where((l) => l.status == 'TEPAT WAKTU').length}", style: const TextStyle(color: AppColors.success, fontSize: 28, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 18),
                                  SizedBox(width: 8),
                                  Text("Terlambat", style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text("${controller.logs.where((l) => l.status != 'TEPAT WAKTU').length}", style: const TextStyle(color: AppColors.danger, fontSize: 28, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // List Data
                  filteredLogs.isEmpty 
                    ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text("Tidak ada data log.")))
                    : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      bool isSuccess = log.status == "TEPAT WAKTU";
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue.shade50,
                              child: Text(log.initials, style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(log.employeeName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  const SizedBox(height: 4),
                                  Text("${log.time} WIB • Clock In", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSuccess ? AppColors.successLight : AppColors.dangerLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isSuccess ? "Hadir" : "Terlambat", 
                                style: TextStyle(color: isSuccess ? AppColors.success : AppColors.danger, fontSize: 10, fontWeight: FontWeight.bold)
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
