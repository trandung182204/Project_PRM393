import 'package:bai1/models/grade.dart';
import 'package:bai1/services/grade_service.dart';

class GradeController {
  final GradeService _service = GradeService();

  Future<List<GradeModel>> fetchGrades(int studentId, {String? semester, String? scholastic}) async {
    try {
      return await _service.getGradesByStudentId(studentId, semester: semester, scholastic: scholastic);
    } catch (e) {
      print("Error fetching grades: $e");
      return [];
    }
  }

  Future<Map<String, List<String>>> fetchFilterOptions() async {
    try {
      return await _service.getFilterOptions();
    } catch (e) {
      print("Error fetching filter options: $e");
      return {'years': [], 'semesters': []};
    }
  }

  Future<List<Map<String, dynamic>>> fetchClasses() async {
    try {
      return await _service.getClasses();
    } catch (e) {
      print("Error fetching classes: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchSemesters() async {
    try {
      return await _service.getSemesters();
    } catch (e) {
      print("Error fetching semesters: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchClassesByStaff(int staffId) async {
    try {
      return await _service.getClassesByStaff(staffId);
    } catch (e) {
      print("Error fetching staff classes: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchSubjectsByStaff(int staffId) async {
    try {
      return await _service.getSubjectsByStaff(staffId);
    } catch (e) {
      print("Error fetching staff subjects: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchStudentsByClass(int classId) async {
    try {
      return await _service.getStudentsByClass(classId);
    } catch (e) {
      print("Error fetching students: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchSubjects() async {
    try {
      return await _service.getSubjects();
    } catch (e) {
      print("Error fetching subjects: $e");
      return [];
    }
  }

  Future<bool> updateGrade(Map<String, dynamic> gradeData) async {
    try {
      await _service.updateGrade(gradeData);
      return true;
    } catch (e) {
      print("Error updating grade: $e");
      return false;
    }
  }
}

