class AuthResponse {
  final int id;
  final String? rollNumber;
  final String? employeeId;
  final String? department;
  final String fullName;
  final String accessToken;
  final String role;
  final int? classId;
  final int? studentId;
  final int? staffId;

  AuthResponse({
    required this.id,
    this.rollNumber,
    this.employeeId,
    this.department,
    required this.fullName,
    required this.accessToken,
    required this.role,
    this.classId,
    this.studentId,
    this.staffId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: (json['id'] as num).toInt(),
      rollNumber: json['rollNumber']?.toString(),
      employeeId: json['employeeId']?.toString(),
      department: json['department']?.toString(),
      fullName: json['fullName']?.toString() ?? '',
      accessToken: json['accessToken']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      classId: (json['classId'] as num?)?.toInt(),
      studentId: (json['studentId'] as num?)?.toInt(),
      staffId: (json['staffId'] as num?)?.toInt(),
    );
  }
}

