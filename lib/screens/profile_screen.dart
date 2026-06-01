import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String employeeId;
  final String employeeNama;

  const ProfileScreen({super.key, required this.employeeId, required this.employeeNama});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          Text(employeeNama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B2F64))),
          Text('NIK Perusahaan: \$employeeId', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          ListTile(leading: const Icon(Icons.badge_outlined), title: const Text('Informasi Personal'), trailing: const Icon(Icons.chevron_right)),
          ListTile(leading: const Icon(Icons.lock_outline), title: const Text('Ubah Kata Sandi'), trailing: const Icon(Icons.chevron_right)),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], minimumSize: const Size.fromHeight(50)),
            child: const Text('Keluar Aplikasi Portal', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}