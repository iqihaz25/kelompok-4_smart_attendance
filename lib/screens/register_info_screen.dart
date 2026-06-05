import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_biometric_screen.dart';

class RegisterInfoScreen extends StatefulWidget {
  const RegisterInfoScreen({super.key});

  @override
  State<RegisterInfoScreen> createState() => _RegisterInfoScreenState();
}

class _RegisterInfoScreenState extends State<RegisterInfoScreen> {
  final _idController = TextEditingController();
  final _namaController = TextEditingController();
  final _pwdController = TextEditingController();

  Future<void> _nextStep() async {
    String id = _idController.text.trim();
    String nama = _namaController.text.trim();
    String pwd = _pwdController.text.trim();

    if (id.isEmpty || nama.isEmpty || pwd.isEmpty) {
      _showAlert("Mohon lengkapi semua data registrasi!");
      return;
    }

    try {
      DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
          .collection('employees')
          .doc(id)
          .get();

      if (!employeeDoc.exists) {
        _showAlert("NIK tidak ditemukan di database perusahaan!");
        return;
      }

      final data = employeeDoc.data() as Map<String, dynamic>;

      String namaDatabase =
      (data['nama'] ?? '').toString().trim().toLowerCase();

      if (namaDatabase != nama.toLowerCase()) {
        _showAlert(
          "Nama tidak sesuai dengan data yang didaftarkan admin!",
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterBiometricScreen(
            employeeId: id,
            nama: nama,
            password: pwd,
          ),
        ),
      );
    } catch (e) {
      _showAlert("Terjadi kesalahan: $e");
    }
  }

  void _showAlert(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _namaController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Smart Attendance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              'Langkah 1 dari 2 - Informasi Dasar',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),

            const LinearProgressIndicator(
              value: 0.5,
              color: Color(0xFF006B5E),
              backgroundColor: Colors.black12,
            ),

            const SizedBox(height: 28),

            const Text(
              'Registrasi Account',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B2F64),
              ),
            ),

            const Text(
              'Silakan lengkapi data diri Anda.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Nama Lengkap',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama sesuai data admin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Employee ID (NIK)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: _idController,
              decoration: InputDecoration(
                hintText: 'Contoh: 1111111111111111',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Kata Sandi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: _pwdController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Minimal 8 karakter',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B5E),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Lanjut →',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}