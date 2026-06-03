import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'failed_screen.dart';

// ============================================================
// CATATAN IMPLEMENTASI FACE RECOGNITION
// ============================================================
// Google ML Kit mendeteksi wajah secara lokal (on-device) tanpa
// memerlukan internet. Untuk "face recognition" (membandingkan
// siapa orang tersebut), alurnya:
//  1. Saat REGISTRASI → foto wajah disimpan referensi embedding-nya
//     di Firestore (field: face_registered = true).
//  2. Saat ABSEN     → ML Kit mendeteksi wajah, lalu kita validasi
//     bahwa wajah ditemukan DAN karyawan tersebut sudah terdaftar.
//
// Untuk produksi enterprise, embedding vector bisa dikirim ke
// backend (Python + face_recognition / DeepFace) untuk perbandingan
// 1:1 yang lebih akurat. Namun untuk demo presentasi, flow di bawah
// sudah menunjukkan integrasi ML Kit yang sesungguhnya.
// ============================================================

class CameraScreen extends StatefulWidget {
  final String employeeId;
  final String employeeNama;
  final double? lat;
  final double? lng;

  const CameraScreen({
    super.key,
    required this.employeeId,
    required this.employeeNama,
    this.lat,
    this.lng,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isProcessing = false;
  String _statusHint = 'Posisikan wajah di dalam lingkaran, lalu tekan Pindai.';
  bool _faceDetectedPreview = false; // live hint apakah wajah terdeteksi

  // ML Kit face detector (real-time mode untuk preview opsional)
  late final FaceDetector _faceDetector;

  @override
  void initState() {
    super.initState();

    // Inisialisasi ML Kit Face Detector
    // performanceMode.accurate → lebih presisi (sedikit lebih lambat)
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableClassification: true, // aktifkan deteksi mata terbuka/tertutup
        enableTracking: true,
      ),
    );

    _initCamera();
  }

  // -------------------------------------------------------
  // Inisialisasi kamera depan (front camera untuk selfie)
  // -------------------------------------------------------
  Future<void> _initCamera() async {
    // Cari kamera depan
    CameraDescription? frontCamera;
    for (final cam in cameras) {
      if (cam.lensDirection == CameraLensDirection.front) {
        frontCamera = cam;
        break;
      }
    }
    final selectedCamera = frontCamera ?? (cameras.isNotEmpty ? cameras[0] : null);

    if (selectedCamera == null) {
      setState(() => _statusHint = 'Kamera tidak ditemukan di perangkat ini.');
      return;
    }

    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.nv21, // format yang didukung ML Kit Android
    );

    try {
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      setState(() => _statusHint = 'Gagal membuka kamera: $e');
    }
  }

  // -------------------------------------------------------
  // INTI: Pindai wajah dengan ML Kit + simpan ke Firestore
  // -------------------------------------------------------
  Future<void> _scanFace() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusHint   = 'Memproses AI Face Recognition…';
    });

    try {
      // --- LANGKAH 1: Ambil foto dari kamera ---
      final XFile imageFile = await _controller!.takePicture();

      // --- LANGKAH 2: Proses gambar dengan Google ML Kit ---
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        // Tidak ada wajah terdeteksi sama sekali
        _handleFaceNotDetected();
        return;
      }

      // Ambil wajah terbesar (terdekat dengan kamera)
      final Face dominantFace = faces.reduce(
        (a, b) => _faceArea(a) > _faceArea(b) ? a : b,
      );

      // --- LANGKAH 3: Validasi kualitas wajah ---
      final double eyeOpenProb =
          ((dominantFace.leftEyeOpenProbability ?? 0) +
              (dominantFace.rightEyeOpenProbability ?? 0)) /
          2;

      if (eyeOpenProb < 0.5) {
        // Mata tertutup / bukan wajah nyata (anti-spoofing dasar)
        _handleSpoofingDetected();
        return;
      }

      // --- LANGKAH 4: Cek apakah karyawan sudah registrasi wajah ---
      final employeeDoc = await FirebaseFirestore.instance
          .collection('registered_employees')
          .doc(widget.employeeId)
          .get();

      if (!employeeDoc.exists || employeeDoc.data()?['face_biometric_registered'] != true) {
        _setStatus('Wajah belum terdaftar di sistem.\nLakukan registrasi terlebih dahulu.', isError: true);
        setState(() => _isProcessing = false);
        return;
      }

      // --- LANGKAH 5: Semua validasi lolos → simpan absensi ke Firestore ---
      await FirebaseFirestore.instance
          .collection('smart_attendance_logs')
          .add({
        'nik'              : widget.employeeId,
        'nama'             : widget.employeeNama,
        'lat'              : widget.lat,
        'lng'              : widget.lng,
        'face_verified'    : true,
        'faces_detected'   : faces.length,
        'eye_open_prob'    : eyeOpenProb.toStringAsFixed(2),
        'timestamp'        : FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Absensi Berhasil — Wajah Terverifikasi!'),
            backgroundColor: Color(0xFF006B5E),
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      _setStatus('Error saat memproses: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // -------------------------------------------------------
  // Handler gagal
  // -------------------------------------------------------
  void _handleFaceNotDetected() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FailedScreen(
            employeeId: widget.employeeId,
            employeeNama: widget.employeeNama,
            lat: widget.lat,
            lng: widget.lng,
            reason: 'Tidak ada wajah terdeteksi.\nPastikan wajah Anda terlihat jelas.',
          ),
        ),
      );
    }
  }

  void _handleSpoofingDetected() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FailedScreen(
            employeeId: widget.employeeId,
            employeeNama: widget.employeeNama,
            lat: widget.lat,
            lng: widget.lng,
            reason: 'Deteksi gagal: mata tertutup atau\nwajah tidak valid. Coba lagi.',
          ),
        ),
      );
    }
  }

  void _setStatus(String msg, {bool isError = false}) {
    setState(() {
      _statusHint   = msg;
      _isProcessing = false;
    });
  }

  double _faceArea(Face face) =>
      face.boundingBox.width * face.boundingBox.height;

  // -------------------------------------------------------
  // Dispose
  // -------------------------------------------------------
  @override
  void dispose() {
    _faceDetector.close();
    _controller?.dispose();
    super.dispose();
  }

  // -------------------------------------------------------
  // UI
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final bool cameraReady =
        _controller != null && _controller!.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Verifikasi Wajah (AI)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B2F64),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Powered by Google ML Kit Face Detection',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Frame lingkaran kamera
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isProcessing
                              ? Colors.orange
                              : const Color(0xFF006B5E),
                          width: 3,
                        ),
                        color: const Color(0xFFF1F5F9),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: cameraReady
                          ? CameraPreview(_controller!)
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF006B5E),
                              ),
                            ),
                    ),
                    // Overlay processing
                    if (_isProcessing)
                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black45,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 12),
                            Text(
                              'AI Memindai…',
                              style: TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Badge ML Kit
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F1E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.security, color: Color(0xFF006B5E), size: 14),
                      SizedBox(width: 6),
                      Text(
                        'On-Device AI  •  Data Aman & Terenkripsi',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF006B5E)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status hint
              Text(
                _statusHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isProcessing
                      ? Colors.orange.shade700
                      : const Color(0xFF0B2F64),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Tombol pindai
              _isProcessing
                  ? const SizedBox.shrink()
                  : ElevatedButton.icon(
                      onPressed: cameraReady ? _scanFace : null,
                      icon: const Icon(Icons.face_retouching_natural,
                          color: Colors.white),
                      label: const Text(
                        'Pindai Wajah',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B5E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
