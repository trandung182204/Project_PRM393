import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bai1/config/api_config.dart';
import 'package:bai1/models/grade.dart';

class GradeService {
  Future<List<GradeModel>> getGradesByStudentId(int studentId, {String? semester, String? scholastic}) async {
    String url = '${ApiConfig.getGrades}/$studentId';
    List<String> params = [];
    if (semester != null) params.add('semester=$semester');
    if (scholastic != null) params.add('scholastic=$scholastic');
    
    if (params.isNotEmpty) {
      url += '?' + params.join('&');
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => GradeModel.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load grades');
    }
  }

  Future<Map<String, List<String>>> getFilterOptions() async {
    final response = await http.get(Uri.parse(ApiConfig.getSemesterFilters));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'years': (data['years'] as List).map((e) => e.toString()).toList(),
        'semesters': (data['semesters'] as List).map((e) => e.toString()).toList(),
      };
    } else {
      throw Exception('Failed to load filter options');
    }
  }

  Future<List<Map<String, dynamic>>> getClasses() async {
    final response = await http.get(Uri.parse(ApiConfig.getClasses));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load classes');
    }
  }

  Future<List<Map<String, dynamic>>> getSemesters() async {
    final response = await http.get(Uri.parse(ApiConfig.getSemesters));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load semesters');
    }
  }

  Future<List<Map<String, dynamic>>> getClassesByStaff(int staffId) async {
    final response = await http.get(Uri.parse('${ApiConfig.getClassesByStaff}/$staffId/classes'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load classes for staff');
    }
  }

  Future<List<Map<String, dynamic>>> getSubjectsByStaff(int staffId) async {
    final response = await http.get(Uri.parse('${ApiConfig.getSubjectsByStaff}/$staffId/subjects'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load subjects for staff');
    }
  }

  Future<List<Map<String, dynamic>>> getStudentsByClass(int classId) async {
    final response = await http.get(Uri.parse('${ApiConfig.getClasses}/$classId/students'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<List<Map<String, dynamic>>> getSubjects() async {
    final response = await http.get(Uri.parse(ApiConfig.getSubjects));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  Future<void> updateGrade(Map<String, dynamic> gradeData) async {
    final response = await http.post(
      Uri.parse(ApiConfig.updateGrade),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(gradeData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update grade');
    }
  }
}

