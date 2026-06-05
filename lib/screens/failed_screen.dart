import 'package:flutter/material.dart';
import 'camera_screen.dart';

class FailedScreen extends StatelessWidget {
  final String employeeId;
  final String employeeNama;
  final double? lat;
  final double? lng;
  final String? reason; // alasan kegagalan yang lebih deskriptif

  const FailedScreen({
    super.key,
    required this.employeeId,
    required this.employeeNama,
    this.lat,
    this.lng,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(
                child: Icon(Icons.error_outline, size: 80, color: Colors.red),
              ),
              const SizedBox(height: 20),
              const Text(
                'Verifikasi Wajah Gagal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B2F64),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reason ?? 'Wajah tidak dikenali atau NIK tidak sesuai.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CameraScreen(
                      employeeId: employeeId,
                      employeeNama: employeeNama,
                      lat: lat,
                      lng: lng,
                    ),
                  ),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Ulangi Pemindaian',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006B5E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Kembali ke Beranda',
                    style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
