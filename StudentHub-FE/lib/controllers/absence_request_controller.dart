import 'package:bai1/models/absence_request.dart';
import 'package:bai1/services/absence_request_service.dart';

class AbsenceRequestController {
  final AbsenceRequestService _service = AbsenceRequestService();

  Future<List<AbsenceRequestModel>> fetchAbsenceRequests({int? accountId, int? classId, int? staffId}) async {
    try {
      return await _service.getAbsenceRequests(accountId: accountId, classId: classId, staffId: staffId);
    } catch (e) {
      print("Error fetching absence requests: $e");
      return [];
    }
  }

  Future<AbsenceRequestModel?> submitAbsenceRequest({
    required DateTime date,
    required String reason,
    required int accountId,
    required List<int> slotIds,
  }) async {
    try {
      return await _service.createAbsenceRequest(
        date: date,
        reason: reason,
        accountId: accountId,
        slotIds: slotIds,
      );
    } catch (e) {
      print("Error creating absence request: $e");
      return null;
    }
  }

  Future<bool> updateAbsenceRequest({
    required int id,
    required DateTime date,
    required String reason,
    required List<int> slotIds,
  }) async {
    try {
      await _service.updateAbsenceRequest(
        id: id,
        date: date,
        reason: reason,
        slotIds: slotIds,
      );
      return true;
    } catch (e) {
      print("Error updating absence request: $e");
      return false;
    }
  }

  Future<bool> deleteAbsenceRequest(int id) async {
    try {
      await _service.deleteAbsenceRequest(id);
      return true;
    } catch (e) {
      print("Error deleting absence request: $e");
      return false;
    }
  }

  Future<bool> updateStatus(int id, String status) async {
    try {
      await _service.updateStatus(id, status);
      return true;
    } catch (e) {
      print("Error updating status: $e");
      return false;
    }
  }
}
