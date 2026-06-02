import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared_widgets/custom_sidebar.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const CustomSidebar(currentIndex: 2), // Pass index 2
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Rekapitulasi Absensi Bulanan", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text("EXPORT EXCEL"),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Berhasil mengekspor laporan timesheet ke format .xlsx")),
                          );
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Card(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: const [
                          ListTile(title: Text("Budi Santoso"), subtitle: Text("Divisi Produksi"), trailing: Text("Hadir: 22 hari | Alfa: 0")),
                          Divider(),
                          ListTile(title: Text("Andi Wijaya"), subtitle: Text("Divisi Logistik"), trailing: Text("Hadir: 20 hari | Terlambat: 2 kali")),
                          Divider(),
                          ListTile(title: Text("Siti Rahma"), subtitle: Text("Staf IT Office"), trailing: Text("Hadir: 21 hari | Ditangguhkan: 1 kali")),
                        ],
                      ),
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
