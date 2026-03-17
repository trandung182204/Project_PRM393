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
      throw Exception('Error fetching subject list');
    }
  }

  Future<void> addSubject(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/Subjects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error adding subject');
    }
  }

  Future<void> updateSubject(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/Subjects/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error updating subject');
    }
  }

  Future<void> deleteSubject(int id) async {
    final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/Subjects/$id'));
    if (response.statusCode != 200) {
      String message = 'Error deleting subject';
      try {
        final error = jsonDecode(response.body);
        message = error.toString();
        if (error is Map && error.containsKey('message')) {
          message = error['message'];
        } else if (error is String) {
          message = error;
        }
      } catch (_) {
        message = response.body;
      }
      throw Exception(message);
    }
  }
}
