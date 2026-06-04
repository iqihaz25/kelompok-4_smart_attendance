import 'package:flutter/material.dart';
import '../../../core/network/websocket_service.dart';
import '../models/attendance_log_model.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController extends ChangeNotifier {
  final WebsocketService _wsService = WebsocketService();
  
  final List<AttendanceLogModel> _logs = [
    AttendanceLogModel(id: "1", employeeName: "Budi Pratama", initials: "BP", department: "Engineering", time: "07:55", status: "TEPAT WAKTU"),
    AttendanceLogModel(id: "2", employeeName: "Ani Sulastri", initials: "AS", department: "Human Resources", time: "08:05", status: "TERLAMBAT", isAnomaly: true, anomalyReason: "Fake GPS"),
    AttendanceLogModel(id: "3", employeeName: "Dedi Kurniawan", initials: "DK", department: "Marketing", time: "07:42", status: "TEPAT WAKTU"),
  ];

  DashboardController() {
    _wsService.simulateIncomingAttendance();
    _wsService.attendanceStream.listen((data) {
      bool isFraud = Random().nextDouble() < 0.3;
      final newLog = AttendanceLogModel(
        id: data['id'],
        employeeName: data['employee_name'],
        initials: data['employee_name'].substring(0, 2).toUpperCase(),
        department: "Operations",
        time: "Baru Saja",
        status: isFraud ? "TERLAMBAT" : "TEPAT WAKTU",
        isAnomaly: isFraud,
        anomalyReason: isFraud ? "Mock GPS Detected" : null,
      );
      
      _logs.insert(0, newLog);
      notifyListeners();
    });
  }

  List<AttendanceLogModel> get logs => _logs;

  int get totalPresent =>
      _logs.where((log) => !log.isAnomaly).length;

  int get totalAnomaly =>
      _logs.where((log) => log.isAnomaly).length;

  // ==== MANAJEMEN KARYAWAN STATE ====
  final List<Map<String, String>> _employees = [
    {"id": "1", "name": "Ahmad Syarif", "nik": "220104230091", "dept": "IT", "initials": "AS"},
    {"id": "2", "name": "Linda Putri", "nik": "220104230088", "dept": "HRD", "initials": "LP"},
    {"id": "3", "name": "Rizky Kurniawan", "nik": "220104230075", "dept": "Ops", "initials": "RK"},
  ];

  List<Map<String, String>> get employees => _employees;

  Future<void> addEmployee(
      String name,
      String nik,
      String dept,
      ) async {
    if (name.isEmpty || nik.isEmpty) return;

    String inits = name
        .trim()
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    await FirebaseFirestore.instance
        .collection('employees')
        .doc(nik)
        .set({
      'nama': name,
      'nik': nik,
      'departemen': dept,
      'initials': inits,
      'created_at': FieldValue.serverTimestamp(),
    });

    _employees.add({
      "id": nik,
      "name": name,
      "nik": nik,
      "dept": dept,
      "initials": inits,
    });

    notifyListeners();
  }

  Future<void> deleteEmployee(String nik) async {
    await FirebaseFirestore.instance
        .collection('employees')
        .doc(nik)
        .delete();

    _employees.removeWhere((e) => e["nik"] == nik);

    notifyListeners();
  }

  // ==== LOGIC KHUSUS APPROVE ====
  void approveLog(String id) {
    int index = _logs.indexWhere((element) => element.id == id);
    if (index != -1) {
      _logs[index] = _logs[index].copyWith(status: "TEPAT WAKTU", isAnomaly: false, anomalyReason: "");
      notifyListeners(); 
    }
  }

  void rejectLog(String id) {
    int index = _logs.indexWhere((element) => element.id == id);
    if (index != -1) {
      _logs[index] = _logs[index].copyWith(status: "ALPHA", isAnomaly: true, anomalyReason: "Fraud Dikonfirmasi");
      notifyListeners();
    }
  }
}
