class News {
  final String id;
  final String title;
  final String? content;
  final String? image;

  News({
    required this.id,
    required this.title,
    this.content,
    this.image,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'],
      image: json['image'],
    );
  }
}
