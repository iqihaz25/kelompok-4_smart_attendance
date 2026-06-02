import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared_widgets/custom_sidebar.dart';

class GeofenceSetupScreen extends StatelessWidget {
  const GeofenceSetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const CustomSidebar(currentIndex: 1), // Pass index 1
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Konfigurasi Geofencing Wilayah", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Tentukan radius koordinat aman untuk absensi mobile karyawan."),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 64, color: AppColors.textSecondary),
                            SizedBox(height: 16),
                            Text("Peta Interaktif (Google Maps / OpenStreetMap Mockup)", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Radius Default Aktif: 50 Meter dari Pusat Koordinat Pabrik"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}