class EventRegistrationModel {
  final int studentId;
  final String fullName;
  final String rollNumber;
  final String registrationDate;
  final String attendanceStatus;

  EventRegistrationModel({
    required this.studentId,
    required this.fullName,
    required this.rollNumber,
    required this.registrationDate,
    required this.attendanceStatus,
  });

  factory EventRegistrationModel.fromJson(Map<String, dynamic> json) {
    return EventRegistrationModel(
      studentId: (json['studentId'] as num?)?.toInt() ?? 0,
      fullName: json['fullName']?.toString() ?? '',
      rollNumber: json['rollNumber']?.toString() ?? '',
      registrationDate: json['registrationDate']?.toString() ?? '',
      attendanceStatus: json['attendanceStatus']?.toString() ?? 'Registered',
    );
  }
}
