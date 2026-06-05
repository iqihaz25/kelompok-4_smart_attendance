import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared_widgets/custom_sidebar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../controllers/dashboard_controller.dart';
import '../attendance_screen.dart';
import 'stat_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardController>(context);

    // Karena ini Web Dashboard, Content akan responsive. Jika di HP, sidebar ditarik ke dalam Drawer.
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile ? AppBar(backgroundColor: AppColors.primary, title: const Text("Smart Attendance", style: TextStyle(color: Colors.white))) : null,
      drawer: isMobile ? const CustomSidebar(currentIndex: 0) : null,
      body: Row(
        children: [
          if (!isMobile) const CustomSidebar(currentIndex: 0), 
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Dashboard HR", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  const Text("Monitoring kehadiran karyawan hari ini, 24 Mei 2024.", style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 32),
                  
                  // Wrap Kartu Statistik Angka (menyesuaikan mockup)
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      StatCard(
                         title: "TOTAL HADIR", 
                         value: "1,248", 
                         subtitle: "↗ 4.2% dari kemarin", 
                         icon: Icons.check_circle_outline,
                         iconColor: AppColors.success,
                      ),
                      StatCard(
                         title: "TERLAMBAT", 
                         value: "42", 
                         subtitle: "— Stabil", 
                         icon: Icons.access_time,
                         iconColor: Colors.blue.shade700,
                      ),
                      StatCard(
                         title: "ALPHA", 
                         value: "12", 
                         subtitle: "↘ 2.1% perbaikan", 
                         icon: Icons.do_not_disturb_alt,
                         iconColor: AppColors.danger,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Header "Live Monitoring"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text("Live Monitoring", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                           backgroundColor: AppColors.secondary,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const AttendanceScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child: const Text("View Details →", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Table Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(flex: 3, child: Text("KARYAWAN", style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("WAKTU", style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Text("STATUS", style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  
                  // List Data (Mockup aesthetic)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.logs.take(4).length,
                    itemBuilder: (context, index) {
                      final log = controller.logs[index];
                      // Warnai badge sesuai status
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
                            // KARYAWAN
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                    child: Center(child: Text(log.initials, style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold))),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(log.employeeName, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                                      Text(log.department, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            // WAKTU
                            Expanded(
                              flex: 2,
                              child: Text(log.time, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ),
                            // STATUS
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSuccess ? AppColors.successLight : AppColors.dangerLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(log.status, textAlign: TextAlign.center, style: TextStyle(color: isSuccess ? AppColors.success : AppColors.danger, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Dark Blue Chart Section "Trend Kehadiran Minggu Ini"
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Trend Kehadiran Minggu Ini", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("Rata-rata kehadiran meningkat sebesar 3.2% dibandingkan periode sebelumnya. Efisiensi jam kerja mencapai titik tertinggi.", 
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5)),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("98.2%", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                                Text("Success Rate", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                              ],
                            ),
                            const SizedBox(width: 32),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("08:12", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                                Text("Avg Clock-In", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Barchart Mockup
                        SizedBox(
                          height: 120,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: false),
                              barGroups: [
                                _buildBar(1, 80),
                                _buildBar(2, 90),
                                _buildBar(3, 70),
                                _buildBar(4, 95),
                                _buildBar(5, 100),
                                _buildBar(6, 60),
                              ],
                            ),
                          ),
                        )
                      ],
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

  BarChartGroupData _buildBar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.secondary,
          width: 24,
          borderRadius: BorderRadius.circular(4),
        )
      ],
    );
  }
}