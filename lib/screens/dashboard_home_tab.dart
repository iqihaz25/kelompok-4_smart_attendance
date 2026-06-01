import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gps_screen.dart';

class DashboardHomeTab extends StatelessWidget {
  final String employeeId;
  final String employeeNama;

  const DashboardHomeTab({super.key, required this.employeeId, required this.employeeNama});

  @override
  Widget build(BuildContext context) {
    // Menggunakan StreamBuilder agar data ringkasan di dashboard berubah secara real-time saat database bertambah
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('smart_attendance_logs')
          .where('nik', isEqualTo: employeeId)
          .snapshots(),
      builder: (context, snapshot) {
        // 1. Ambil jumlah data asli dari database
        int totalHariMasuk = snapshot.hasData ? snapshot.data!.docs.length : 0;

        // 2. Simulasi hitung keterlambatan berdasarkan jam server dummy
        int totalTerlambat = 0;
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['timestamp'] != null) {
              Timestamp t = data['timestamp'];
              DateTime date = t.toDate();
              // Jika absen di atas jam 9, hitung sebagai terlambat
              if (date.hour >= 9) {
                totalTerlambat++;
              }
            }
          }
        }

        // 3. Hitung progress jam kerja (1 hari masuk = 8 jam kerja industri)
        int totalJamKerja = totalHariMasuk * 8;
        if (totalJamKerja > 40) totalJamKerja = 40; // Batas maksimal mingguan 40 jam
        double progressPercent = totalJamKerja / 40;

        // Format angka agar selalu dua digit (misal: 1 menjadi "01")
        String formattedHariMasuk = totalHariMasuk.toString().padLeft(2, '0');
        String formattedTerlambat = totalTerlambat.toString().padLeft(2, '0');

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // --- AREA PROFILE HEADER ---
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF0B2F64),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(employeeNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0B2F64))),
                      Text('NIK: $employeeId • Jun 1, 2026', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF0B2F64)),
                ],
              ),
              const SizedBox(height: 20),
              
              // --- AREA LOCATION INDICATOR ---
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFE2F1E8), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFF006B5E)),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Area Penugasan Kerja', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B2F64))),
                        Text('Sistem GPS Terbuka Aktif', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 36),
              
              // --- TOMBOL UTAMA ABSEN MASUK ---
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GpsScreen(employeeId: employeeId, employeeNama: employeeNama),
                    ),
                  ),
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFF006B5E).withOpacity(0.2), width: 10)),
                    child: Center(
                      child: Container(
                        width: 160, height: 160,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF006B5E)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fingerprint, color: Colors.white, size: 44),
                            SizedBox(height: 8),
                            Text('ABSEN\nMASUK', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: Text('Shift starts at 09:00 AM', style: TextStyle(fontSize: 12, color: Colors.grey))),
              const SizedBox(height: 32),
              
              // --- RINGKASAN MINGGUAN (DINAMIS & REAL-TIME) ---
              const Text('Ringkasan Mingguan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B2F64))),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Card Hari Masuk
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFE2F1E8), borderRadius: BorderRadius.circular(4)),
                              child: const Text('ON TRACK', style: TextStyle(fontSize: 9, color: Color(0xFF006B5E), fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            Text(formattedHariMasuk, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B2F64))),
                            const Text('Hari Masuk', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Card Terlambat
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFFFEAEB), borderRadius: BorderRadius.circular(4)),
                              child: const Text('ATTENDANCE', style: TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            Text(formattedTerlambat, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B2F64))),
                            const Text('Terlambat', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // --- PROGRES BAR JAM KERJA ---
              Card(
                color: Colors.white,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('PROGRES KERJA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          Text('${totalJamKerja}j / 40j', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B2F64))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progressPercent,
                        color: const Color(0xFF0B2F64),
                        backgroundColor: const Color(0xFFF1F5F9),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}