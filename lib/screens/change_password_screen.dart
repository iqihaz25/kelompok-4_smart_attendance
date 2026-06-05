import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String employeeId;

  const ChangePasswordScreen({
    super.key,
    required this.employeeId,
  });

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();

  bool _loading = false;

  Future<void> _changePassword() async {
    try {
      setState(() {
        _loading = true;
      });

      final doc = await FirebaseFirestore.instance
          .collection('registered_employees')
          .doc(widget.employeeId)
          .get();

      if (!doc.exists) {
        throw Exception("Data tidak ditemukan");
      }

      final data = doc.data()!;

      if (data['password'] != _oldPassword.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password lama salah"),
          ),
        );

        setState(() {
          _loading = false;
        });

        return;
      }

      await FirebaseFirestore.instance
          .collection('registered_employees')
          .doc(widget.employeeId)
          .update({
        'password': _newPassword.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password berhasil diubah"),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubah Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _oldPassword,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password Lama",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPassword,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password Baru",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                _loading ? null : _changePassword,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Update Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}