import '../services/registration_service.dart';

class RegistrationController {
  final RegistrationService _registrationService = RegistrationService();

  Future<void> registerSubject({
    required int studentId,
    required int subjectId,
    required int semesterId,
  }) async {
    await _registrationService.registerSubject(
      studentId: studentId,
      subjectId: subjectId,
      semesterId: semesterId,
    );
  }

  Future<void> assignToClass({
    required int studentId,
    required int classId,
  }) async {
    await _registrationService.assignToClass(
      studentId: studentId,
      classId: classId,
    );
  }

  Future<bool> batchAssignToClass({
    required int classId,
    required List<int> studentIds,
  }) async {
    try {
      await _registrationService.batchAssignToClass(
        classId: classId,
        studentIds: studentIds,
      );
      return true;
    } catch (e) {
      print("Error batch assigning: $e");
      return false;
    }
  }

  Future<bool> removeFromClass({
    required int classId,
    required int studentId,
  }) async {
    try {
      await _registrationService.removeFromClass(
        classId: classId,
        studentId: studentId,
      );
      return true;
    } catch (e) {
      print("Error removing from class: $e");
      return false;
    }
  }
}
