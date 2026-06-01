import 'package:flutter/material.dart';
import 'camera_screen.dart';

class FailedScreen extends StatelessWidget {
  final String employeeId;
  final String employeeNama;
  final double? lat;
  final double? lng;

  const FailedScreen({super.key, required this.employeeId, required this.employeeNama, this.lat, this.lng});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Center(child: Icon(Icons.error_outline, size: 72, color: Colors.red)),
            const SizedBox(height: 20),
            const Text('Verifikasi Wajah Gagal', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B2F64))),
            const Text('Wajah tidak dikenali atau NIK tidak sesuai.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CameraScreen(employeeId: employeeId, employeeNama: employeeNama, lat: lat, lng: lng))),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B5E), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Ulangi Pemindaian', style: TextStyle(color: Colors.white)),
            ),
            TextButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), child: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}