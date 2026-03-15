class Club {
  final String id;
  final String name;
  final String category;
  final int members;
  final String? image;
  final String? description;
  final String? status;
  final String? foundedDate;

  Club({
    required this.id,
    required this.name,
    required this.category,
    required this.members,
    this.image,
    this.description,
    this.status,
    this.foundedDate,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      members: (json['members'] as num?)?.toInt() ?? 0,
      image: json['image']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      foundedDate: json['foundedDate']?.toString(),
    );
  }
}
