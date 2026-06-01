import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'failed_screen.dart';

class CameraScreen extends StatefulWidget {
  final String employeeId;
  final String employeeNama;
  final double? lat;
  final double? lng;

  const CameraScreen({super.key, required this.employeeId, required this.employeeNama, this.lat, this.lng});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      _controller!.initialize().then((_) { if (mounted) setState(() {}); });
    }
  }

  void _scanFace() async {
    setState(() { _isProcessing = true; });
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _isProcessing = false; });

    bool pass = int.tryParse(widget.employeeId.substring(widget.employeeId.length - 1))?.isEven ?? true;

    if (pass) {
      await FirebaseFirestore.instance.collection('smart_attendance_logs').add({
        'nik': widget.employeeId,
        'nama': widget.employeeNama,
        'lat': widget.lat,
        'lng': widget.lng,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Absensi Berhasil Diunggah Otomatis!")));
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FailedScreen(employeeId: widget.employeeId, employeeNama: widget.employeeNama, lat: widget.lat, lng: widget.lng)));
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
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
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF006B5E), width: 3)),
                clipBehavior: Clip.antiAlias,
                child: (_controller != null && _controller!.value.isInitialized) ? CameraPreview(_controller!) : const Icon(Icons.camera_front, size: 80),
              ),
            ),
            const Spacer(),
            _isProcessing 
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(onPressed: _scanFace, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B5E), padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Pindai Wajah', style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}