import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'camera_screen.dart';

// ============================================================
// KONFIGURASI KANTOR — sesuaikan koordinat & radius ini
// ============================================================
const double _officeLatitude  = -6.9175;   // Ganti dengan latitude kantor
const double _officeLongitude = 107.6191;  // Ganti dengan longitude kantor
const double _radiusMeters    = 10000.0;     // Radius geofence dalam meter
// ============================================================

class GpsScreen extends StatefulWidget {
  final String employeeId;
  final String employeeNama;

  const GpsScreen({
    super.key,
    required this.employeeId,
    required this.employeeNama,
  });

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  // Status tampilan
  String _statusMessage = 'Tekan tombol untuk memverifikasi lokasi Anda.';
  double? _lat;
  double? _lng;
  double? _distanceFromOffice;

  // 3 kemungkinan state: idle | loading | valid | invalid
  _GpsState _gpsState = _GpsState.idle;

  // -------------------------------------------------------
  // Hitung jarak (meter) antara dua koordinat — Haversine
  // -------------------------------------------------------
  double _haversineDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const earthRadius = 6371000.0; // meter
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;

  // -------------------------------------------------------
  // Fungsi utama cek GPS + geofencing realtime
  // -------------------------------------------------------
  Future<void> _checkLocation() async {
    setState(() {
      _gpsState    = _GpsState.loading;
      _statusMessage = 'Meminta izin & mendeteksi lokasi…';
    });

    try {
      // 1. Cek apakah location service aktif di perangkat
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setError('GPS perangkat tidak aktif.\nAktifkan Location Services terlebih dahulu.');
        return;
      }

      // 2. Minta/cek izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setError('Izin lokasi ditolak.\nBuka Pengaturan → Izin Aplikasi untuk mengaktifkan.');
        return;
      }

      // 3. Ambil posisi akurat (akurasi tinggi, timeout 15 detik)
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // 4. Hitung jarak ke kantor dengan rumus Haversine
      final distance = _haversineDistance(
        position.latitude, position.longitude,
        _officeLatitude, _officeLongitude,
      );

      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _distanceFromOffice = distance;
      });

      // 5. Validasi apakah dalam radius geofence
      if (distance <= _radiusMeters) {
        setState(() {
          _gpsState      = _GpsState.valid;
          _statusMessage =
              '✅ Lokasi Terverifikasi\n'
              '${position.latitude.toStringAsFixed(5)}° LS, '
              '${position.longitude.toStringAsFixed(5)}° BT\n'
              'Jarak ke kantor: ${distance.toStringAsFixed(0)} m';
        });
      } else {
        setState(() {
          _gpsState      = _GpsState.invalid;
          _statusMessage =
              '❌ Di Luar Area Kantor\n'
              'Anda berada ${distance.toStringAsFixed(0)} m dari kantor.\n'
              'Maksimum radius: ${_radiusMeters.toStringAsFixed(0)} m';
        });
      }
    } on LocationServiceDisabledException {
      _setError('Layanan lokasi dinonaktifkan. Aktifkan GPS.');
    } catch (e) {
      _setError('Gagal mengambil lokasi: $e');
    }
  }

  void _setError(String msg) {
    setState(() {
      _gpsState      = _GpsState.invalid;
      _statusMessage = msg;
    });
  }

  // -------------------------------------------------------
  // UI
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Header
              Text(
                'Halo, ${widget.employeeNama}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF0B2F64),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Verifikasi lokasi sebelum absen.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 32),

              // Ikon animasi GPS
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _bgColor,
                  ),
                  child: _gpsState == _GpsState.loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF006B5E),
                          ),
                        )
                      : Icon(_iconData, size: 80, color: _iconColor),
                ),
              ),
              const SizedBox(height: 24),

              // Pesan status
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),

              // Badge akurasi (jika sudah dapat posisi)
              if (_distanceFromOffice != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.gps_fixed,
                            size: 14, color: Color(0xFF006B5E)),
                        const SizedBox(width: 6),
                        Text(
                          'Akurasi GPS aktif  •  '
                          'Lat ${_lat!.toStringAsFixed(4)}, '
                          'Lng ${_lng!.toStringAsFixed(4)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF006B5E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Tombol aksi
              if (_gpsState == _GpsState.valid)
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CameraScreen(
                        employeeId: widget.employeeId,
                        employeeNama: widget.employeeNama,
                        lat: _lat,
                        lng: _lng,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.face_retouching_natural,
                      color: Colors.white),
                  label: const Text(
                    'Lanjut Pemindaian Wajah',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B5E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _gpsState == _GpsState.loading
                      ? null
                      : _checkLocation,
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  label: Text(
                    _gpsState == _GpsState.idle
                        ? 'Cek Lokasi Saya'
                        : 'Coba Lagi',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B2F64),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Warna helper berdasarkan state
  Color get _bgColor {
    switch (_gpsState) {
      case _GpsState.valid:   return const Color(0xFFE8F5E9);
      case _GpsState.invalid: return const Color(0xFFFFEBEE);
      default:                return const Color(0xFFE3F2FD);
    }
  }

  Color get _iconColor {
    switch (_gpsState) {
      case _GpsState.valid:   return Colors.green;
      case _GpsState.invalid: return Colors.red;
      default:                return const Color(0xFF0B2F64);
    }
  }

  Color get _textColor {
    switch (_gpsState) {
      case _GpsState.valid:   return Colors.green.shade700;
      case _GpsState.invalid: return Colors.red.shade700;
      default:                return const Color(0xFF0B2F64);
    }
  }

  IconData get _iconData {
    switch (_gpsState) {
      case _GpsState.valid:   return Icons.check_circle_outline;
      case _GpsState.invalid: return Icons.location_off_outlined;
      default:                return Icons.radar;
    }
  }
}

enum _GpsState { idle, loading, valid, invalid }
