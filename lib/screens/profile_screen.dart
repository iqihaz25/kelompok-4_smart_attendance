import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ditambahkan untuk ambil data terbaru
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String employeeId;
  final String employeeNama;

  const ProfileScreen({
    super.key,
    required this.employeeId,
    required this.employeeNama,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Buat variabel baru untuk menampung nama yang bisa di-update di level State
  late String _currentNama;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi nama awal dari widget parameter
    _currentNama = widget.employeeNama;
  }

  // Fungsi untuk mengambil nama terbaru dari Firestore setelah edit sukses
  Future<void> _refreshProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('registered_employees')
          .doc(widget.employeeId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _currentNama = data['nama'] ?? _currentNama;
        });
      }
    } catch (e) {
      debugPrint("Gagal me-refresh data profil: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator()) // Efek loading saat refresh data
            : Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Avatar Profil
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF0B2F64),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Nama Karyawan (Sekarang otomatis berubah secara dinamis!)
              Text(
                _currentNama,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B2F64),
                ),
              ),

              // NIK Karyawan
              Text(
                'NIK Perusahaan: ${widget.employeeId}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Tombol Menu: Edit Profil
              ListTile(
                leading: const Icon(Icons.badge_outlined, color: Color(0xFF0B2F64)),
                title: const Text("Edit Profil"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  // MENUNGGU HASIL POP: Jika kembali membawa nilai 'true'
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        employeeId: widget.employeeId,
                        currentName: _currentNama, // Kirim nama terbaru saat ini
                      ),
                    ),
                  );

                  // Jika hasil pop adalah true, jalankan refresh data otomatis
                  if (result == true) {
                    _refreshProfileData();
                  }
                },
              ),
              const Divider(height: 1),

              // Tombol Menu: Ganti Password
              ListTile(
                leading: const Icon(Icons.lock_reset, color: Color(0xFF0B2F64)),
                title: const Text("Ganti Password"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangePasswordScreen(
                        employeeId: widget.employeeId,
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Tombol Keluar Aplikasi
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Keluar Aplikasi Portal',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}