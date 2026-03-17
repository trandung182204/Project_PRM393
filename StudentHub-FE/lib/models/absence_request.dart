class SlotModel {
  final int id;
  final String slotName;
  final String startTime;
  final String endTime;
  final String subjectName;

  SlotModel({
    required this.id,
    required this.slotName,
    required this.startTime,
    required this.endTime,
    required this.subjectName,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] ?? 0,
      slotName: json['slotName'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      subjectName: json['subjectName'] ?? 'N/A',
    );
  }
}

class AbsenceRequestModel {
  final int id;
  final String date;
  final String reason;
  final String status;
  final String createdDate;
  final int studentId;
  final String studentName;
  final String className;
  final List<SlotModel> slots;

  AbsenceRequestModel({
    required this.id,
    required this.date,
    required this.reason,
    required this.status,
    required this.createdDate,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.slots,
  });

  factory AbsenceRequestModel.fromJson(Map<String, dynamic> json) {
    return AbsenceRequestModel(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      createdDate: json['createdDate'] ?? '',
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      className: json['className'] ?? 'N/A',
      slots: (json['slots'] as List<dynamic>?)
              ?.map((s) => SlotModel.fromJson(s))
              .toList() ??
          [],
    );
  }
}
