class GradeModel {
  final int id;
  final double oralScore;
  final double smallTestScore;
  final double middleTestScore;
  final double finalTestScore;
  final double score;
  final String status;
  final String subjectName;
  final String semesterName;

  GradeModel({
    required this.id,
    required this.oralScore,
    required this.smallTestScore,
    required this.middleTestScore,
    required this.finalTestScore,
    required this.score,
    required this.status,
    required this.subjectName,
    required this.semesterName,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: (json['id'] as num).toInt(),
      oralScore: (json['oralScore'] as num?)?.toDouble() ?? 0.0,
      smallTestScore: (json['smallTestScore'] as num?)?.toDouble() ?? 0.0,
      middleTestScore: (json['middleTestScore'] as num?)?.toDouble() ?? 0.0,
      finalTestScore: (json['finalTestScore'] as num?)?.toDouble() ?? 0.0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
      subjectName: json['subjectName']?.toString() ?? '',
      semesterName: json['semesterName']?.toString() ?? '',
    );
  }
}
