class Schedule {
  final int? id;
  final int? slotId;
  final String date;
  final String time;
  final String subject;
  final String room;
  final String teacher;
  final String status;

  Schedule({
    this.id,
    this.slotId,
    required this.date,
    required this.time,
    required this.subject,
    required this.room,
    required this.teacher,
    required this.status,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      slotId: json['slotId'],
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      subject: json['subject'] ?? '',
      room: json['room'] ?? '',
      teacher: json['teacher'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
