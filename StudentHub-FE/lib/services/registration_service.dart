import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class RegistrationService {
  Future<Map<String, dynamic>> registerSubject({
    required int studentId,
    required int subjectId,
    required int semesterId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/CourseRegistration/student/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'subjectId': subjectId,
        'semesterId': semesterId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error registering subject');
    }
  }

  Future<Map<String, dynamic>> assignToClass({
    required int studentId,
    required int classId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/CourseRegistration/staff/assign-class'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'classId': classId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error assigning to class');
    }
  }

  Future<void> batchAssignToClass({
    required int classId,
    required List<int> studentIds,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/CourseRegistration/staff/batch-assign-class'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'classId': classId,
        'studentIds': studentIds,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error in batch class assignment');
    }
  }

  Future<void> removeFromClass({
    required int classId,
    required int studentId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/CourseRegistration/staff/remove-class'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'classId': classId,
        'studentId': studentId,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error removing student from class');
    }
  }
}
