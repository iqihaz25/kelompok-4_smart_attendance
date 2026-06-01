import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'camera_screen.dart';

class GpsScreen extends StatefulWidget {
  final String employeeId;
  final String employeeNama;

  const GpsScreen({super.key, required this.employeeId, required this.employeeNama});

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  String _gpsStatus = "Mencari sinyal GPS...";
  double? _lat;
  double? _lng;
  bool _isValid = false;

  void _checkGps() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _isValid = true;
        _gpsStatus = "Dalam Area Kantor\n\${position.latitude}° N, \${position.longitude}° W";
      });
    } catch (e) {
      setState(() { _gpsStatus = "Gagal memindai GPS: \$e"; });
    }
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
            Text('Halo, \${widget.employeeNama}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Container(
              height: 220,
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.radar, size: 64, color: Color(0xFF0B2F64)),
            ),
            const SizedBox(height: 24),
            Text(_gpsStatus, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B2F64))),
            const Spacer(),
            if (_isValid)
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen(employeeId: widget.employeeId, employeeNama: widget.employeeNama, lat: _lat, lng: _lng))),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B5E), padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Lanjut Pemindaian Wajah', style: TextStyle(color: Colors.white)),
              )
            else
              ElevatedButton(
                onPressed: _checkGps,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B5E), padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Cek Lokasi', style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}