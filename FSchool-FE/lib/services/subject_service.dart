import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class SubjectService {
  Future<List<Map<String, dynamic>>> getSubjects() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/Subjects'));
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body);
      return list.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Lỗi khi lấy danh sách môn học');
    }
  }
}
