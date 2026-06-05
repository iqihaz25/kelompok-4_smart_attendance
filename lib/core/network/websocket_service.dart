import 'dart:async';

class WebsocketService {
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get attendanceStream => _controller.stream;

  // Simulasi masuknya data absensi dari HP karyawan secara real-time
  void simulateIncomingAttendance() {
    Timer.periodic(const Duration(seconds: 15), (timer) {
      _controller.add({
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "employee_name": "Karyawan Lapangan ${timer.tick}",
        "time": "Sekarang",
        "status": "Tepat Waktu",
        "is_anomaly": false
      });
    });
  }

  void dispose() {
    _controller.close();
  }
}
