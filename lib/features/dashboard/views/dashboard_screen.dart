import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared_widgets/custom_sidebar.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import 'widgets/stat_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardController>(context);

    return Scaffold(
      body: Row(
        children: [
          const CustomSidebar(), // Sidebar Kiri
          
          // Konten Utama Kanan
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Live Attendance Feed & Monitoring",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  
                  // Row Kartu Statistik Angka
                  Row(
                    children: [
                      StatCard(title: "Total Hadir Valid", value: "${controller.totalPresent} Karyawan", color: AppColors.success),
                      const SizedBox(width: 16),
                      StatCard(title: "Perlu Tinjauan (Anomali)", value: "${controller.totalAnomaly} Kasus", color: AppColors.danger),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // List Feed Log Kehadiran harian
                  const Text("Log Aktivitas Real-time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.logs.length,
                      itemBuilder: (context, index) {
                        final log = controller.logs[index];
                        return Card(
                          color: log.isAnomaly ? Colors.red.shade50 : AppColors.surface,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: log.isAnomaly ? AppColors.danger : AppColors.primary,
                              child: Icon(log.isAnomaly ? Icons.warning : Icons.person, color: Colors.white),
                            ),
                            title: Text(log.employeeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Waktu: ${log.time}${log.isAnomaly ? '\nAlasan: ${log.anomalyReason}' : ''}"),
                            trailing: log.isAnomaly 
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_circle, color: AppColors.success),
                                      onPressed: () => controller.approveLog(log.id),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: AppColors.danger),
                                      onPressed: () => controller.rejectLog(log.id),
                                    ),
                                  ],
                                )
                              : Text(log.status, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
