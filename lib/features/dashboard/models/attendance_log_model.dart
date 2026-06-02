class AttendanceLogModel {
  final String id;
  final String employeeName;
  final String initials;
  final String department;
  final String time;
  final String status;
  final bool isAnomaly;
  final String? anomalyReason;

  AttendanceLogModel({
    required this.id,
    required this.employeeName,
    required this.initials,
    required this.department,
    required this.time,
    required this.status,
    this.isAnomaly = false,
    this.anomalyReason,
  });

  AttendanceLogModel copyWith({String? status, bool? isAnomaly, String? anomalyReason}) {
    return AttendanceLogModel(
      id: this.id,
      employeeName: this.employeeName,
      initials: this.initials,
      department: this.department,
      time: this.time,
      status: status ?? this.status,
      isAnomaly: isAnomaly ?? this.isAnomaly,
      anomalyReason: anomalyReason ?? this.anomalyReason,
    );
  }
}
