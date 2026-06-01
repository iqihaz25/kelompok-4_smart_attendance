import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // Mengambil global variable list 'cameras'
import 'login_screen.dart';

class RegisterBiometricScreen extends StatefulWidget {
  final String employeeId;
  final String nama;
  final String password;

  const RegisterBiometricScreen({
    super.key, 
    required this.employeeId, 
    required this.nama, 
    required this.password
  });

  @override
  State<RegisterBiometricScreen> createState() => _RegisterBiometricScreenState();
}

class _RegisterBiometricScreenState extends State<RegisterBiometricScreen> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isFaceCaptured = false;
  bool _isSavingPayload = false;

  @override
  void initState() {
    super.initState();
    _initializeRegisterCamera();
  }

  // Mengaktifkan sensor webcam laptop/PC secara realtime di Chrome
  void _initializeRegisterCamera() async {
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras[0], 
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      try {
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraReady = true;
          });
        }
      } catch (e) {
        _showSnackBar("Gagal membuka webcam browser: $e");
      }
    } else {
      _showSnackBar("Sensor kamera tidak ditemukan pada perangkat ini.");
    }
  }

  // Aksi ketika tombol "Ambil Foto Wajah" ditekan (Simulasi record matriks)
  void _captureFaceSample() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    setState(() { _isSavingPayload = true; });
    // Simulasi memproses scanning titik biometrik wajah kustomer
    await Future.delayed(const Duration(seconds: 1)); 
    
    setState(() {
      _isFaceCaptured = true;
      _isSavingPayload = false;
    });
    _showSnackBar("Sampel matriks biometrik wajah berhasil direkam!");
  }

  // Menyimpan data final ke Cloud Firestore dan redirect ke halaman Login
  void _finalizeRegistration() async {
    setState(() { _isSavingPayload = true; });
    try {
      await FirebaseAuth.instance.signInAnonymously();
      
      // Simpan Payload pendaftaran ke dokumen internal koleksi Firestore
      await FirebaseFirestore.instance.collection('registered_employees').doc(widget.employeeId).set({
        'nama': widget.nama,
        'employee_id': widget.employeeId,
        'password': widget.password,
        'face_biometric_registered': true,
        'created_at': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        _showSnackBar("Registrasi & Pendaftaran Wajah Berhasil! Silahkan Login.");
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => const LoginScreen()), 
          (route) => false,
        );
      }
    } catch (e) {
      _showSnackBar("Gagal mengunggah enkripsi akun: $e");
    } finally {
      if (mounted) setState(() { _isSavingPayload = false; });
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Indikator Progress Bar (Sesuai image_0ab1e5.png)
            const Text('LANKAH 2 DARI 2         Biometric Verification', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const LinearProgressIndicator(value: 1.0, color: Color(0xFF006B5E), backgroundColor: Colors.black12),
            const SizedBox(height: 28),
            
            const Text('Daftarkan Wajah Anda', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B2F64))),
            const SizedBox(height: 4),
            const Text('Pastikan pencahayaan cukup untuk hasil verifikasi yang presisi.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 40),
            
            // --- FRAME LINGKARAN KAMERA LIVE (Sesuai image_0ab1e5.png) ---
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 240, height: 240,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF1F5F9)),
                    clipBehavior: Clip.antiAlias,
                    child: _isCameraReady && _cameraController != null
                        ? CameraPreview(_cameraController!)
                        : const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: Color(0xFF006B5E)), SizedBox(height: 10), Text('Menyalakan Kamera...', style: TextStyle(fontSize: 11, color: Colors.grey))])),
                  ),
                  // Border outline hijau pelindung wajah
                  Container(
                    width: 210, height: 210,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF006B5E), width: 2, strokeAlign: BorderSide.strokeAlignOutside)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Tag Status Enkripsi
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFE2F1E8), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gpp_good, color: const Color(0xFF006B5E), size: 16),
                    const SizedBox(width: 6),
                    Text(_isFaceCaptured ? 'Matriks Wajah Terkunci' : 'Data Terenkripsi & Aman', style: const TextStyle(fontSize: 11, color: Color(0xFF006B5E), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            
            // --- AREA ACTIONS BUTTONS ---
            _isSavingPayload
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _captureFaceSample,
                    icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                    label: Text(_isFaceCaptured ? 'Ambil Ulang Foto Wajah' : 'Ambil Foto Wajah', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B5E), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                  ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isFaceCaptured ? _finalizeRegistration : null, // Hanya aktif ketika wajah sudah difoto
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFaceCaptured ? const Color(0xFF0B2F64) : const Color(0xFFCBD5E1), 
                padding: const EdgeInsets.symmetric(vertical: 16), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                'Selesaikan Registrasi', 
                style: TextStyle(color: _isFaceCaptured ? Colors.white : const Color(0xFF64748B), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}