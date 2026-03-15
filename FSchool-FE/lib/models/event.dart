class EventModel {
  final String id;
  final String title;
  final String date;
  final String location;
  final String? image;
  final String? description;
  final String? status;
  final int? clubId;
  final double? budget;
  final int? maxParticipants;
  final int registrationCount;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    this.image,
    this.description,
    this.status,
    this.clubId,
    this.budget,
    this.maxParticipants,
    this.registrationCount = 0,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      image: json['image']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      clubId: json['clubId'] as int?,
      budget: (json['budget'] as num?)?.toDouble(),
      maxParticipants: json['maxParticipants'] as int?,
      registrationCount: (json['registrationCount'] as num?)?.toInt() ?? 0,
    );
  }
}
