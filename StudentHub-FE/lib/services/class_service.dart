import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ClassService {
  Future<List<Map<String, dynamic>>> getClasses() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/Classes'));
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body);
      return list.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Error fetching class list');
    }
  }

  Future<List<Map<String, dynamic>>> getStudentsInClass(int classId) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/Classes/$classId/students'));
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body);
      return list.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Error fetching student list in class');
    }
  }

  Future<void> createClass({
    required String className,
    required String academicYear,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/Classes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'className': className,
        'academicYear': academicYear,
      }),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error creating class');
    }
  }

  Future<void> updateClass({
    required int classId,
    required String className,
    required String academicYear,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/Classes/$classId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'className': className,
        'academicYear': academicYear,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error updating class');
    }
  }

  Future<void> deleteClass(int classId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/Classes/$classId'),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error deleting class');
    }
  }
}
