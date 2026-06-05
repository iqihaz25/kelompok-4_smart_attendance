import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_info_screen.dart';
import 'dashboard_screen.dart';
import '../features/auth/views/login_screen.dart' as admin_auth;
import '../features/dashboard/views/widgets/dashboard_screen.dart' as admin_dashboard;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pwdController = TextEditingController();

  void _handleLogin() async {
    String id = _idController.text.trim();
    String pwd = _pwdController.text.trim();

    if (id.isEmpty || pwd.isEmpty) {
      _showAlert("NIK dan Kata Sandi wajib diisi!");
      return;
    }

    // Bypass Firebase authentication untuk Admin
    if (id == "Admin" && pwd == "HanyaAdminYangTahu") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const admin_dashboard.AdminDashboardScreen()),
      );
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('registered_employees').doc(id).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (data['password'] == pwd) {
          await FirebaseAuth.instance.signInAnonymously();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen(employeeId: id, employeeNama: data['nama'])),
            );
          }
          return;
        }
      }
      _showAlert("NIK atau Kata Sandi salah / belum terdaftar!");
    } catch (e) {
      _showAlert("Gangguan server cloud: \$e");
    }
  }

  void _showAlert(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF0B2F64), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.fingerprint, size: 44, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Smart Attendance', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0B2F64))),
            const Text('Sistem Presensi Karyawan Terintegrasi', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 36),
            const Text('NIK (ID KARYAWAN)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0B2F64))),
            const SizedBox(height: 6),
            TextField(
              controller: _idController,
              decoration: InputDecoration(hintText: 'Contoh: 20240101 (atau Admin)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            const Text('KATA SANDI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0B2F64))),
            const SizedBox(height: 6),
            TextField(
              controller: _pwdController,
              decoration: InputDecoration(hintText: '••••••••', suffixIcon: const Icon(Icons.visibility_off_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B5E), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.login, color: Colors.white, size: 18), SizedBox(width: 8), Text('Masuk Ke Akun', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))],
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterInfoScreen())),
              child: const Text('Belum punya akun? Daftar di sini', style: TextStyle(color: Color(0xFF006B5E), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}