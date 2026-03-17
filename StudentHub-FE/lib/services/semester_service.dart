import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class SemesterService {
  Future<List<Map<String, dynamic>>> getSemesters() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/Semesters'));
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body);
      return list.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Error fetching semester list');
    }
  }
}
