import 'package:bai1/models/club.dart';
import 'package:bai1/models/student_club_member.dart';
import 'package:bai1/services/club_service.dart';

class ClubController {
  final ClubService _clubService = ClubService();

  Future<List<Club>> fetchClubs() async {
    try {
      return await _clubService.getClubs();
    } catch (e) {
      print("Error fetching clubs: $e");
      return [];
    }
  }

  Future<List<Club>> fetchPendingClubs() async {
    try {
      return await _clubService.getPendingClubs();
    } catch (e) {
      print("Error fetching pending clubs: $e");
      return [];
    }
  }

  Future<List<Club>> fetchAllClubs() async {
    try {
      return await _clubService.getAllClubs();
    } catch (e) {
      print("Error fetching all clubs: $e");
      return [];
    }
  }

  Future<bool> proposeClub(Map<String, dynamic> data) async {
    try {
      return await _clubService.proposeClub(data);
    } catch (e) {
      print("Error proposing club: $e");
      return false;
    }
  }

  Future<bool> approveClub(int id) async {
    try {
      return await _clubService.approveClub(id);
    } catch (e) {
      print("Error approving club: $e");
      return false;
    }
  }

  Future<bool> joinClub(int clubId, int studentId) async {
    try {
      return await _clubService.joinClub(clubId, studentId);
    } catch (e) {
      print("Error joining club: $e");
      return false;
    }
  }

  Future<List<StudentClubMember>> fetchMembers(int clubId) async {
    try {
      return await _clubService.getMembers(clubId);
    } catch (e) {
      print("Error fetching members: $e");
      return [];
    }
  }

  Future<List<StudentClubMember>> fetchPendingMembers(int clubId) async {
    try {
      return await _clubService.getPendingMembers(clubId);
    } catch (e) {
      print("Error fetching pending members: $e");
      return [];
    }
  }

  Future<bool> approveMember(int clubId, int studentId) async {
    try {
      return await _clubService.approveMember(clubId, studentId);
    } catch (e) {
      print("Error approving member: $e");
      return false;
    }
  }

  Future<bool> rejectMember(int clubId, int studentId) async {
    try {
      return await _clubService.rejectMember(clubId, studentId);
    } catch (e) {
      print("Error rejecting member: $e");
      return false;
    }
  }

  Future<bool> assignRole(int clubId, int studentId, String role) async {
    try {
      return await _clubService.assignRole(clubId, studentId, role);
    } catch (e) {
      print("Error assigning role: $e");
      return false;
    }
  }

  Future<bool> leaveClub(int clubId, int studentId) async {
    try {
      return await _clubService.leaveClub(clubId, studentId);
    } catch (e) {
      print("Error leaving club: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> getMyStatus(int clubId, int studentId) async {
    try {
      return await _clubService.getMyStatus(clubId, studentId);
    } catch (e) {
      print("Error getting status: $e");
      return {"isMember": false, "status": "None", "role": "None"};
    }
  }
}
