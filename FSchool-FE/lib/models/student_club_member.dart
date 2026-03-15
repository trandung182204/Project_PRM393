class StudentClubMember {
  final int studentId;
  final String fullName;
  final String rollNumber;
  final String? avatarUrl;
  final String clubRole;
  final String status;
  final String joinDate;
  final String? leftDate;

  StudentClubMember({
    required this.studentId,
    required this.fullName,
    required this.rollNumber,
    this.avatarUrl,
    required this.clubRole,
    required this.status,
    required this.joinDate,
    this.leftDate,
  });

  factory StudentClubMember.fromJson(Map<String, dynamic> json) {
    return StudentClubMember(
      studentId: (json['studentId'] as num?)?.toInt() ?? 0,
      fullName: json['fullName']?.toString() ?? '',
      rollNumber: json['rollNumber']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      clubRole: json['clubRole']?.toString() ?? 'Member',
      status: json['status']?.toString() ?? 'Pending',
      joinDate: json['joinDate']?.toString() ?? '',
      leftDate: json['leftDate']?.toString(),
    );
  }
}
