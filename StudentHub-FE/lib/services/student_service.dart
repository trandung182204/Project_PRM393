import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class StudentService {
  Future<List<Map<String, dynamic>>> getStudents() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/Students'));
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body);
      return list.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Lỗi khi lấy danh sách sinh viên');
    }
  }
}
