import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bai1/config/api_config.dart';

class StaffService {
  Future<List<Map<String, dynamic>>> getStaffs() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/Staffs'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load staffs');
  }
}
